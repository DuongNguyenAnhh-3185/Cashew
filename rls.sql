-- ==============================================================================
-- RLS.SQL: HỆ THỐNG PHÂN QUYỀN ROW LEVEL SECURITY (RLS) TRÊN SUPABASE
-- Sử dụng Firebase Auth làm Third-Party Auth Provider.
-- Định danh người dùng hiện tại lấy từ JWT claim: auth.jwt() ->> 'sub'.
-- Thiết kế chống đệ quy vô hạn (Infinite Recursion) bằng các hàm SECURITY DEFINER.
-- ==============================================================================

-- Bật Row Level Security cho tất cả 3 bảng trong schema public
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;

-- Xóa các policy cũ nếu đã tồn tại để đảm bảo idempotency khi chạy lại
DROP POLICY IF EXISTS "users_select_authenticated" ON public.users;
DROP POLICY IF EXISTS "users_insert_own_profile" ON public.users;
DROP POLICY IF EXISTS "users_update_own_profile" ON public.users;

DROP POLICY IF EXISTS "documents_select_access" ON public.documents;
DROP POLICY IF EXISTS "documents_insert_own" ON public.documents;
DROP POLICY IF EXISTS "documents_update_owner_or_editor" ON public.documents;
DROP POLICY IF EXISTS "documents_delete_owner_only" ON public.documents;

DROP POLICY IF EXISTS "permissions_select_recipient_or_owner" ON public.permissions;
DROP POLICY IF EXISTS "permissions_insert_owner_only" ON public.permissions;
DROP POLICY IF EXISTS "permissions_update_owner_only" ON public.permissions;
DROP POLICY IF EXISTS "permissions_delete_owner_only" ON public.permissions;


-- ==============================================================================
-- 1. CÁC HÀM BỔ TRỢ AN TOÀN (SECURITY DEFINER HELPERS)
-- Cơ chế: Khi thực thi với SECURITY DEFINER và SET search_path = public, hàm
-- chạy với đặc quyền của người tạo hàm, bỏ qua RLS của các bảng bên trong thân hàm.
-- Điều này loại bỏ hoàn toàn nguy cơ đệ quy vô hạn khi bảng A gọi B và B gọi lại A.
-- ==============================================================================

-- Hàm lấy Firebase UID của người dùng từ Access Token JWT hiện hành
CREATE OR REPLACE FUNCTION public.current_auth_uid()
RETURNS TEXT
LANGUAGE sql
STABLE
AS $$
    SELECT COALESCE(
        (auth.jwt() ->> 'sub'),
        NULLIF(auth.uid()::text, '')
    );
$$;

-- Hàm kiểm tra xem người dùng hiện tại có phải là Chủ sở hữu (Owner) của tài liệu hay không
CREATE OR REPLACE FUNCTION public.is_document_owner(doc_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.documents
        WHERE id = doc_id
          AND owner_id = public.current_auth_uid()
    );
$$;

-- Hàm kiểm tra xem người dùng hiện tại có quyền truy cập tài liệu hay không (Owner hoặc có trong permissions)
-- required_role:
--   - NULL / 'viewer': Chỉ cần là owner hoặc có quyền viewer/editor
--   - 'editor': Phải là owner hoặc có quyền editor
CREATE OR REPLACE FUNCTION public.has_document_access(doc_id UUID, required_role TEXT DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.documents d
        WHERE d.id = doc_id
          AND (
              -- Trường hợp 1: Người dùng hiện tại chính là Chủ sở hữu tài liệu
              d.owner_id = public.current_auth_uid()
              OR
              -- Trường hợp 2: Người dùng hiện tại được chia sẻ với quyền tương ứng
              EXISTS (
                  SELECT 1
                  FROM public.permissions p
                  WHERE p.document_id = doc_id
                    AND p.user_id = public.current_auth_uid()
                    AND (
                        required_role IS NULL
                        OR (required_role = 'viewer' AND p.role IN ('viewer', 'editor'))
                        OR (required_role = 'editor' AND p.role = 'editor')
                    )
              )
          )
    );
$$;


-- ==============================================================================
-- 2. POLICIES CHO BẢNG USERS
-- ==============================================================================

-- [USERS - SELECT]: Bất kỳ người dùng nào đã đăng nhập đều có thể đọc danh sách users.
-- Mục đích: Để người dùng có thể tra cứu và tìm kiếm tài khoản theo email khi thực hiện chia sẻ.
CREATE POLICY "users_select_authenticated"
ON public.users
FOR SELECT
TO authenticated
USING (
    public.current_auth_uid() IS NOT NULL
);

-- [USERS - INSERT]: Chỉ người dùng có UID trùng khớp với token mới được ghi danh chính mình.
-- Mục đích: Thực hiện upsert thông tin cá nhân lần đầu khi người dùng đăng nhập bằng Google.
CREATE POLICY "users_insert_own_profile"
ON public.users
FOR INSERT
TO authenticated
WITH CHECK (
    id = public.current_auth_uid()
);

-- [USERS - UPDATE]: Chỉ người dùng sở hữu tài khoản mới được cập nhật thông tin của mình.
CREATE POLICY "users_update_own_profile"
ON public.users
FOR UPDATE
TO authenticated
USING (
    id = public.current_auth_uid()
)
WITH CHECK (
    id = public.current_auth_uid()
);


-- ==============================================================================
-- 3. POLICIES CHO BẢNG DOCUMENTS
-- ==============================================================================

-- [DOCUMENTS - SELECT]: Người dùng đọc được tài liệu nếu họ là Chủ sở hữu (owner_id = uid)
-- HOẶC họ có mặt trong bảng permissions (với vai trò viewer hoặc editor).
-- Sử dụng hàm has_document_access() để tránh đệ quy vòng tròn với bảng permissions.
CREATE POLICY "documents_select_access"
ON public.documents
FOR SELECT
TO authenticated
USING (
    owner_id = public.current_auth_uid()
    OR public.has_document_access(id, 'viewer')
);

-- [DOCUMENTS - INSERT]: Người dùng chỉ được tạo tài liệu mới khi gán owner_id chính là UID của mình.
CREATE POLICY "documents_insert_own"
ON public.documents
FOR INSERT
TO authenticated
WITH CHECK (
    owner_id = public.current_auth_uid()
);

-- [DOCUMENTS - UPDATE]: Chỉ Chủ sở hữu tài liệu HOẶC người được cấp quyền 'editor' mới được phép sửa.
CREATE POLICY "documents_update_owner_or_editor"
ON public.documents
FOR UPDATE
TO authenticated
USING (
    owner_id = public.current_auth_uid()
    OR public.has_document_access(id, 'editor')
)
WITH CHECK (
    -- Đảm bảo sau khi cập nhật, chủ sở hữu không bị hoán đổi trái phép
    owner_id = public.current_auth_uid()
    OR public.has_document_access(id, 'editor')
);

-- [DOCUMENTS - DELETE]: Chỉ DUY NHẤT Chủ sở hữu (Owner) mới có quyền xóa tài liệu.
-- Editor và Viewer tuyệt đối không thể xóa tài liệu.
CREATE POLICY "documents_delete_owner_only"
ON public.documents
FOR DELETE
TO authenticated
USING (
    owner_id = public.current_auth_uid()
);


-- ==============================================================================
-- 4. POLICIES CHO BẢNG PERMISSIONS
-- ==============================================================================

-- [PERMISSIONS - SELECT]: Cho phép đọc quyền nếu:
--   1. Người dùng chính là người nhận quyền (user_id = uid) -> để biết mình có quyền gì trên tài liệu.
--   2. Người dùng là Chủ sở hữu của tài liệu (is_document_owner(document_id)) -> để quản lý danh sách chia sẻ.
CREATE POLICY "permissions_select_recipient_or_owner"
ON public.permissions
FOR SELECT
TO authenticated
USING (
    user_id = public.current_auth_uid()
    OR public.is_document_owner(document_id)
);

-- [PERMISSIONS - INSERT]: Chỉ Chủ sở hữu tài liệu mới có quyền chia sẻ tài liệu cho người khác.
CREATE POLICY "permissions_insert_owner_only"
ON public.permissions
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_document_owner(document_id)
);

-- [PERMISSIONS - UPDATE]: Chỉ Chủ sở hữu tài liệu mới có quyền thay đổi cấp độ quyền (viewer <-> editor).
CREATE POLICY "permissions_update_owner_only"
ON public.permissions
FOR UPDATE
TO authenticated
USING (
    public.is_document_owner(document_id)
)
WITH CHECK (
    public.is_document_owner(document_id)
);

-- [PERMISSIONS - DELETE]: Chỉ Chủ sở hữu tài liệu mới có quyền thu hồi quyền chia sẻ của người khác.
CREATE POLICY "permissions_delete_owner_only"
ON public.permissions
FOR DELETE
TO authenticated
USING (
    public.is_document_owner(document_id)
);
