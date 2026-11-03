# Hướng Dẫn Cài Đặt & Sử Dụng KinG-Remote (Kết Nối Qua Tailscale)

KinG-Remote là ứng dụng điều khiển máy tính từ xa (phát triển từ RustDesk). Phiên bản này đã được thiết lập mặc định kết nối trực tiếp qua mạng riêng ảo Tailscale (IP dạng `100.x.x.x`, cổng TCP 21118) và xác thực bằng mật khẩu cố định mà không cần máy chủ trung gian.

---

## 1. Tải File Cài Đặt (Windows và Android)

1. Truy cập repo GitHub: `https://github.com/dinhviethoang/rustdesk`.
2. Vào thẻ **Actions** > chọn workflow **Flutter Nightly Build** (nhánh `king-remote`) > chọn lần chạy gần nhất để tải trong mục **Artifacts** (hoặc vào mục **Releases** tìm tag `nightly`).
3. Chọn file tải về phù hợp:
   - **Windows:** Tải file `.msi` (hoặc `.exe`) có tên dạng `rustdesk-<phiên bản>-x86_64.msi` (tên file là rustdesk, khi mở ứng dụng sẽ hiển thị tên **KinG-Remote**).
   - **Android:** Tải file cài đặt `.apk` bản `aarch64`.

---

## 2. Thiết Lập Trên Máy 24/24 (Windows Cần Điều Khiển)

1. **Cài Tailscale:**
   - Tải và cài đặt Tailscale từ trang chủ (`tailscale.com`).
   - Đăng nhập tài khoản cá nhân (Google, Microsoft,...).
   - Nhấp vào biểu tượng Tailscale ở khay hệ thống và ghi lại địa chỉ IP của máy (dạng `100.x.x.x`).
2. **Cài đặt KinG-Remote:**
   - Chạy file `.msi` để cài ứng dụng thành dịch vụ hệ thống (chạy ngầm tự động ngay cả khi chưa đăng nhập Windows).
3. **Đặt mật khẩu cố định:**
   - Mở KinG-Remote, vào **Cài đặt** > **Bảo mật** > **Mật khẩu**.
   - Đặt mật khẩu cố định để sử dụng khi kết nối từ xa.
4. **Kiểm tra truy cập IP trực tiếp:**
   - Kiểm tra tùy chọn **Cho phép truy cập IP trực tiếp** (Direct IP Access) đã được bật (mặc định đã bật trên cổng 21118).
5. **Tắt chế độ ngủ (Sleep) của máy:**
   - Vào **Settings** Windows > **System** > **Power & sleep**.
   - Tại mục **Sleep**, chọn **Never** để máy luôn hoạt động.

---

## 3. Điều Khiển Từ Máy Tính Khác

1. Cài đặt **Tailscale** và đăng nhập cùng tài khoản với máy 24/24.
2. Cài đặt và khởi chạy **KinG-Remote**.
3. Tại ô nhập **ID**, điền địa chỉ IP Tailscale (`100.x.x.x`) của máy 24/24 cần kết nối.
4. Nhấn kết nối và nhập mật khẩu cố định đã tạo ở Bước 2.

---

## 4. Điều Khiển Từ Điện Thoại Android

1. Cài đặt **Tailscale** từ CH Play và đăng nhập cùng tài khoản.
2. Cài file **KinG-Remote .apk** đã tải (bật xác nhận cho phép cài đặt từ nguồn không xác định nếu có cảnh báo).
3. Mở KinG-Remote, nhập IP Tailscale (`100.x.x.x`) vào ô ID rồi nhấn kết nối và nhập mật khẩu cố định.
4. **Mẹo thao tác trên màn hình điện thoại:**
   - Chạm 1 ngón: Nhấp chuột trái.
   - Chạm 2 ngón: Nhấp chuột phải.
   - Vuốt 2 ngón: Cuộn trang lên/xuống.
   - Vuốt cạnh màn hình để mở thanh công cụ hỗ trợ phím tắt và bàn phím ảo.

---

## 5. Điều Khiển Từ iPhone / iPad

1. Cài đặt **Tailscale** từ App Store và đăng nhập cùng tài khoản.
2. Cài đặt ứng dụng **RustDesk** chính thức từ App Store (tương thích hoàn toàn).
3. Mở ứng dụng, nhập địa chỉ IP Tailscale (`100.x.x.x`) của máy 24/24 vào ô ID.
4. Bấm kết nối và điền mật khẩu cố định.

---

## 6. Xử Lý Sự Cố Thường Gặp

- **Không kết nối được:**
  - Kiểm tra Tailscale đang được bật và cùng trạng thái online trên cả 2 thiết bị.
  - Thử kiểm tra đường truyền bằng cách ping IP `100.x.x.x`.
  - Kiểm tra tường lửa Windows (Windows Defender Firewall) trên máy 24/24 để đảm bảo đã cho phép cổng TCP `21118`.
- **Màn hình đen:**
  - Thường xảy ra khi máy tính đang khóa hoặc không có màn hình vật lý cắm trực tiếp. Cần mở khóa màn hình hoặc sử dụng đầu giả lập HDMI dummy plug.
- **Kết nối bị giật, lag:**
  - Kiểm tra lại tốc độ đường truyền Internet ở cả hai bên.
  - Trên thanh điều khiển phiên làm việc, chuyển chế độ hiển thị sang tối ưu tốc độ hoặc giảm chất lượng hình ảnh / FPS.
