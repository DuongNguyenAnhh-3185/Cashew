-- ==============================================================================
-- SCHEMA.SQL: THIẾT KẾ CƠ SỞ DỮ LIỆU CASHEW STUDYDOCS TRÊN SUPABASE (POSTGRESQL)
-- Xác thực thông qua Firebase Auth (Third-Party Auth Provider).
-- ID người dùng là Firebase UID (kiểu text), trích xuất từ auth.jwt() ->> 'sub'.
-- ==============================================================================

-- Bật extension pg_trgm phục vụ tìm kiếm mờ (fuzzy/ilike) hiệu năng cao
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------------------------
-- 1. BẢNG USERS: Lưu trữ thông tin người dùng được đồng bộ từ Firebase Auth
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
    id TEXT PRIMARY KEY,                       -- Firebase UID (chuỗi text)
    email TEXT UNIQUE NOT NULL,                -- Email đăng nhập Google của người dùng
    display_name TEXT,                         -- Tên hiển thị từ hồ sơ Google
    photo_url TEXT,                            -- Ảnh đại diện Google
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- Chỉ mục tìm kiếm người dùng theo email khi thực hiện chức năng chia sẻ tài liệu
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);


-- ------------------------------------------------------------------------------
-- 2. BẢNG DOCUMENTS: Lưu trữ metadata của tài liệu học tập
-- Tệp tin vật lý được lưu trữ tương ứng trên Firebase Storage:
-- documents/{owner_id}/{id}/{file_name}
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,                                -- Tiêu đề tài liệu
    description TEXT,                                   -- Mô tả chi tiết
    file_name TEXT NOT NULL,                            -- Tên tệp gốc kèm phần mở rộng
    file_type TEXT NOT NULL,                            -- Định dạng tệp (PDF, DOCX, ZIP, v.v.)
    file_size BIGINT NOT NULL DEFAULT 0,                -- Dung lượng tính bằng bytes
    storage_path TEXT NOT NULL,                         -- Đường dẫn lưu trên Firebase Storage
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- Chỉ mục tối ưu hóa truy vấn tài liệu theo chủ sở hữu và tìm kiếm từ khóa
CREATE INDEX IF NOT EXISTS idx_documents_owner_id ON public.documents(owner_id);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON public.documents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_documents_title_trgm ON public.documents USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_documents_desc_trgm ON public.documents USING gin (description gin_trgm_ops);


-- ------------------------------------------------------------------------------
-- 3. BẢNG PERMISSIONS: Quản lý phân quyền chia sẻ tài liệu
-- Vai trò: 'viewer' (chỉ đọc) hoặc 'editor' (đọc và chỉnh sửa tiêu đề/mô tả)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES public.documents(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('viewer', 'editor')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT unique_document_user_permission UNIQUE(document_id, user_id)
);

-- Chỉ mục tăng tốc kiểm tra quyền truy cập và liệt kê tài liệu được chia sẻ
CREATE INDEX IF NOT EXISTS idx_permissions_doc_user ON public.permissions(document_id, user_id);
CREATE INDEX IF NOT EXISTS idx_permissions_user_id ON public.permissions(user_id);
CREATE INDEX IF NOT EXISTS idx_permissions_document_id ON public.permissions(document_id);


-- ------------------------------------------------------------------------------
-- 4. TRIGGER TỰ ĐỘNG CẬP NHẬT updated_at KHI BẢNG DOCUMENTS CÓ THAY ĐỔI
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_documents_updated_at ON public.documents;
CREATE TRIGGER trigger_documents_updated_at
    BEFORE UPDATE ON public.documents
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
