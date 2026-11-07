# KinG-Remote

<p align="center">
  <img src="res/icon.png" alt="KinG-Remote Logo" width="128" height="128">
</p>

KinG-Remote là phần mềm điều khiển máy tính từ xa cá nhân, tối ưu cho kết nối trực tiếp P2P qua mạng riêng ảo (như Tailscale) mà không cần cấu hình máy chủ trung gian phức tạp.

## Tải về

Tải bản cài đặt mới nhất (Windows MSI/EXE & Android APK) tại:
👉 [KinG-Remote Releases (Nightly)](https://github.com/dinhviethoang/rustdesk/releases/tag/nightly)

## Cài đặt & Sử dụng

Xem tài liệu hướng dẫn chi tiết từng bước:
👉 [Hướng dẫn cài đặt & sử dụng (HUONG-DAN-CAI-DAT.md)](HUONG-DAN-CAI-DAT.md)

## Cách build lại trên GitHub Actions

Để kích hoạt build lại bộ cài đặt mới nhất:
1. Vào mục **Actions** trên GitHub repository.
2. Chọn workflow **Flutter Nightly Build**.
3. Bấm **Enable workflow** (nếu đang bị tắt).
4. Chọn **Run workflow** trên nhánh `king-remote`.
5. Sau khi build hoàn tất, tải file cài đặt trong mục **Artifacts** hoặc **Releases**, sau đó tắt (Disable workflow) lại để tránh tiêu tốn tài nguyên.

## Giấy phép

Dựa trên mã nguồn mở RustDesk (https://github.com/rustdesk/rustdesk), giấy phép AGPL-3.0 — xem LICENCE.
