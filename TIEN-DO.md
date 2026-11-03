# Tiến độ: rustdesk-rieng (RustDesk cá nhân hoá)

Fork: https://github.com/dinhviethoang/rustdesk (gốc: rustdesk/rustdesk, AGPL-3.0)

## Đã xong
- 04/11: HUONG-DAN-CAI-DAT.md (agy Flash High viết, Claude kiểm tra): tải file, máy 24/24, máy tính khác, Android, iPhone, sự cố.
- 04/11: Mặc định bật direct-server=Y, verification-method=use-permanent-password, approve-mode=password (DEFAULT_SETTINGS trong load_custom_client; code do Gemini web viết, Claude kiểm tra).
- 2026-11-03: Đổi tên app thành KinG-Remote (APP_NAME đặt trong src/common.rs load_custom_client, không sửa submodule; metadata Cargo.toml, Runner.rc, main.cpp, macOS, Android). Giữ nguyên tên file rustdesk.exe/librustdesk để workflow build chạy.
- 2026-11-03: Thay 49 icon từ branding/logo-king-goc.png bằng branding/tao-icon.py (chạy lại khi đổi logo).
- 2026-11-03: Fork repo về GitHub dinhviethoang, clone (shallow, kèm submodule libs/hbb_common) về đây.

## Đang dở
- 04/11: build #3 (run 41681411560, commit d006ffd = icon trong suốt + mặc định direct-server/mật khẩu cố định) đang chạy. Build #2 đã chứng minh bản Windows x86_64 + Android build OK.
- 04/11: icon đã tách nền trong suốt (commit d5a3a2e, đã push). Build #2 đang chạy dùng icon CŨ (nền trắng) → khi xong phải chạy lại Flutter Nightly trên king-remote.
- Build GitHub Actions run 41671568005 (nightly, nhánh king-remote) đang chạy từ 23:11 03/11.
- Quy ước: việc thực thi GIAO agy, Claude chỉ hướng dẫn/kiểm tra. Quota agy Flash rất nhỏ: 04/11 ~01:10 viết xong 1 file 77 dòng là hết, hồi sau ~77h (07/11). Opus hồi ~07:15 04/11. Codex hồi 17/11. Gemini CLI chỉ chạy với API key (chưa tạo).

## Việc tiếp theo
- Sau build: tải artifact Windows + Android, cài thử; tắt workflow Flutter Nightly (lịch đêm chạy master).
- Push nhánh king-remote, chạy GitHub Actions flutter-build.yml, cài thử bản Windows.
- Tuỳ chỉnh tiếp: màu, cài đặt mặc định (direct IP, mật khẩu cố định), ẩn/thêm tính năng.
- Giao codex/agy sửa code; build bằng GitHub Actions (flutter-build.yml).
- Máy 24/24: cài app + Tailscale, remote qua IP 100.x.x.x.
