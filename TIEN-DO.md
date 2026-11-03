# Tiến độ: rustdesk-rieng (RustDesk cá nhân hoá)

Fork: https://github.com/dinhviethoang/rustdesk (gốc: rustdesk/rustdesk, AGPL-3.0)

## Đã xong
- 2026-11-03: Đổi tên app thành KinG-Remote (APP_NAME đặt trong src/common.rs load_custom_client, không sửa submodule; metadata Cargo.toml, Runner.rc, main.cpp, macOS, Android). Giữ nguyên tên file rustdesk.exe/librustdesk để workflow build chạy.
- 2026-11-03: Thay 49 icon từ branding/logo-king-goc.png bằng branding/tao-icon.py (chạy lại khi đổi logo).
- 2026-11-03: Fork repo về GitHub dinhviethoang, clone (shallow, kèm submodule libs/hbb_common) về đây.

## Đang dở
- Nhánh king-remote đã commit local, CHƯA push lên GitHub, CHƯA build thử.

## Việc tiếp theo
- Push nhánh king-remote, chạy GitHub Actions flutter-build.yml, cài thử bản Windows.
- Tuỳ chỉnh tiếp: màu, cài đặt mặc định (direct IP, mật khẩu cố định), ẩn/thêm tính năng.
- Giao codex/agy sửa code; build bằng GitHub Actions (flutter-build.yml).
- Máy 24/24: cài app + Tailscale, remote qua IP 100.x.x.x.
