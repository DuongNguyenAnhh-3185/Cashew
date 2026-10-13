/**
 * ==============================================================================
 * SCRIPT GÁN CUSTOM CLAIMS: role = 'authenticated' CHO FIREBASE AUTH USERS
 * Sử dụng cho giải pháp: Supabase Third-Party Auth với Firebase làm JWT Issuer.
 * ==============================================================================
 * 
 * Lý do cần thiết:
 * Supabase sử dụng claim 'role' trong JWT để ánh xạ thành vai trò của PostgreSQL.
 * Để người dùng được PostgreSQL nhận diện là role 'authenticated' (thay vì 'anon'),
 * Firebase Auth token phải chứa custom claim: { role: 'authenticated' }.
 * 
 * Hướng dẫn sử dụng:
 * 1. Tải file khóa dịch vụ serviceAccountKey.json từ:
 *    Firebase Console -> Project Settings -> Service accounts -> Generate new private key
 * 2. Đặt file serviceAccountKey.json vào thư mục gốc của dự án (cùng cấp với scripts/).
 * 3. Cài đặt thư viện: npm install firebase-admin
 * 4. Chạy script:
 *    - Gán cho một User theo UID:
 *      node scripts/set-custom-claims.js <FIREBASE_UID>
 *    - Gán cho một User theo Email:
 *      node scripts/set-custom-claims.js --email user@example.com
 *    - Tự động gán cho TOÀN BỘ User trong Firebase Auth:
 *      node scripts/set-custom-claims.js --all
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Đường dẫn tới tệp Service Account Key
const serviceAccountPath = path.resolve(__dirname, '..', 'serviceAccountKey.json');

if (!fs.existsSync(serviceAccountPath)) {
  console.error('\n❌ LỖI: Không tìm thấy tệp serviceAccountKey.json!');
  console.error(`Vui lòng tải tệp Service Account từ Firebase Console và đặt tại: ${serviceAccountPath}\n`);
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();

async function setClaimsForUser(uid, email = '') {
  try {
    const user = await auth.getUser(uid);
    const existingClaims = user.customClaims || {};

    // Gán role 'authenticated' phục vụ Supabase RLS
    const updatedClaims = {
      ...existingClaims,
      role: 'authenticated'
    };

    await auth.setCustomUserClaims(uid, updatedClaims);
    console.log(`✅ Đã gán { role: 'authenticated' } cho user: [${uid}] ${email || user.email}`);
  } catch (error) {
    console.error(`❌ Thất bại khi gán claim cho [${uid}]:`, error.message);
  }
}

async function setAllUsers() {
  console.log('🔄 Đang quét danh sách người dùng trên Firebase Auth...');
  let nextPageToken;
  let count = 0;

  do {
    const listUsersResult = await auth.listUsers(100, nextPageToken);
    for (const userRecord of listUsersResult.users) {
      await setClaimsForUser(userRecord.uid, userRecord.email);
      count++;
    }
    nextPageToken = listUsersResult.pageToken;
  } while (nextPageToken);

  console.log(`\n🎉 Hoàn thành! Đã gán custom claim cho tổng cộng ${count} người dùng.`);
}

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log(`
Cách sử dụng:
  node scripts/set-custom-claims.js <UID>               : Gán claim cho 1 UID cụ thể
  node scripts/set-custom-claims.js --email <EMAIL>    : Gán claim theo email
  node scripts/set-custom-claims.js --all              : Gán claim cho TOÀN BỘ user
    `);
    process.exit(0);
  }

  if (args[0] === '--all') {
    await setAllUsers();
  } else if (args[0] === '--email' && args[1]) {
    try {
      const user = await auth.getUserByEmail(args[1]);
      await setClaimsForUser(user.uid, user.email);
    } catch (err) {
      console.error(`❌ Không tìm thấy user với email: ${args[1]} (${err.message})`);
    }
  } else {
    const uid = args[0];
    await setClaimsForUser(uid);
  }

  console.log('\n💡 Lưu ý quan trọng:');
  console.log('Sau khi gán Custom Claims, người dùng trên ứng dụng cần Đăng xuất và Đăng nhập lại');
  console.log('hoặc đợi token được làm mới (Firebase ID token refresh) để claim có hiệu lực trong JWT.');
  process.exit(0);
}

main().catch(err => {
  console.error('Lỗi thực thi:', err);
  process.exit(1);
});
