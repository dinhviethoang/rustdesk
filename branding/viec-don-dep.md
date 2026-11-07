Repo: C:\Users\KiNG_613\Projects\rustdesk-rieng (fork RustDesk, nhánh king-remote, app đã đổi tên "KinG-Remote").
MỤC TIÊU: xoá mọi tài liệu/tệp phụ mang thương hiệu RustDesk mà KHÔNG làm hỏng build Windows + Android trên GitHub Actions.

LÀM (dùng `git rm`, không commit):
1. Xoá toàn bộ thư mục docs/ (README/CONTRIBUTING/CODE_OF_CONDUCT/SECURITY các thứ tiếng), AGENTS.md, GEMINI.md,
   .github/FUNDING.yml, .github/ISSUE_TEMPLATE/, fastlane/ (metadata F-Droid của RustDesk).
   Trước khi xoá mỗi thứ: `git grep -n "<tên>"` trong .github/workflows, build.py, flutter/, res/, Cargo.toml để chắc không
   bước build nào dùng tới. Nếu có chỗ dùng thì KHÔNG xoá thứ đó, ghi lại lý do.
2. Workflow thừa trong .github/workflows/: GIỮ flutter-nightly.yml, flutter-build.yml và mọi workflow mà hai file này gọi
   (uses: ./.github/workflows/...), kể cả gọi gián tiếp. Xoá các workflow còn lại (CI, tag build, fdroid, playground,
   clear-cache, winget, ...). Kiểm tra lại bằng grep "uses: ./.github/workflows" sau khi xoá.
3. Viết lại README.md (tiếng Việt, ngắn, ~30 dòng): tên KinG-Remote, ảnh logo res/icon.png, mô tả "phần mềm điều khiển
   máy tính từ xa cá nhân", cách tải (https://github.com/dinhviethoang/rustdesk/releases/tag/nightly), trỏ tới
   HUONG-DAN-CAI-DAT.md, cách build lại (Actions → Flutter Nightly Build → Enable → Run workflow trên king-remote → tắt lại).
   Cuối README BẮT BUỘC có mục "Giấy phép": "Dựa trên mã nguồn mở RustDesk (https://github.com/rustdesk/rustdesk),
   giấy phép AGPL-3.0 — xem LICENCE." (giấy phép AGPL bắt buộc giữ ghi công này).

KHÔNG ĐỤNG: LICENCE; libs/ (submodule); src/, flutter/ (code); res/; Cargo.toml; appimage/, flatpak/, Dockerfile,
entrypoint.sh, examples/, build.py (có thể được build dùng); HUONG-DAN-CAI-DAT.md, TIEN-DO.md, branding/.

XONG KHI: python -c "import yaml,glob;[yaml.safe_load(open(f,encoding='utf-8')) for f in glob.glob('.github/workflows/*.yml')]"
chạy không lỗi. TRẢ LỜI: danh sách đã xoá (gộp theo thư mục), workflow giữ lại, thứ định xoá nhưng giữ (kèm lý do).
