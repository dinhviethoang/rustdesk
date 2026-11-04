# Tiến độ: rustdesk-rieng (RustDesk cá nhân hoá)

Fork: https://github.com/dinhviethoang/rustdesk (gốc: rustdesk/rustdesk, AGPL-3.0)

## Đã xong
- 04/11: Build #3 (run 41681411560, commit d006ffd) xong: Windows .exe/.msi + Android .apk mới (icon trong suốt + mặc định) trên release nightly. Chỉ macOS lỗi (không cần). Đã push 861a451.
- 04/11: HUONG-DAN-CAI-DAT.md (agy Flash High viết, Claude kiểm tra): tải file, máy 24/24, máy tính khác, Android, iPhone, sự cố.
- 04/11: Mặc định bật direct-server=Y, verification-method=use-permanent-password, approve-mode=password (DEFAULT_SETTINGS trong load_custom_client; code do Gemini web viết, Claude kiểm tra).
- 2026-11-03: Đổi tên app thành KinG-Remote (APP_NAME đặt trong src/common.rs load_custom_client, không sửa submodule; metadata Cargo.toml, Runner.rc, main.cpp, macOS, Android). Giữ nguyên tên file rustdesk.exe/librustdesk để workflow build chạy.
- 2026-11-03: Thay 49 icon từ branding/logo-king-goc.png bằng branding/tao-icon.py (chạy lại khi đổi logo).
- 2026-11-03: Fork repo về GitHub dinhviethoang, clone (shallow, kèm submodule libs/hbb_common) về đây.

## Đang dở
- Quy ước: việc thực thi GIAO agy, Claude chỉ hướng dẫn/kiểm tra. Quota agy Flash rất nhỏ (hồi ~07/11), Opus hồi ~07:15 04/11, Codex hồi 17/11. Gemini CLI chỉ chạy với API key (chưa tạo).

## Việc tiếp theo
- Người dùng cài thử theo HUONG-DAN-CAI-DAT.md (máy 24/24 .msi + Tailscale, điện thoại .apk).
- 04/11: workflow Flutter Nightly đã tắt (Disabled manually). Muốn build lại: Actions → Flutter Nightly Build → Enable workflow → Run workflow trên nhánh king-remote.
- Tuỳ chỉnh tiếp: màu, cài đặt mặc định (direct IP, mật khẩu cố định), ẩn/thêm tính năng.
- Giao codex/agy sửa code; build bằng GitHub Actions (flutter-build.yml).
- Máy 24/24: cài app + Tailscale, remote qua IP 100.x.x.x.
