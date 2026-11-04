Repo: C:\Users\KiNG_613\Projects\rustdesk-rieng (fork RustDesk, nhánh king-remote). App đã đổi tên hiển thị thành "KinG-Remote"
(APP_NAME đặt trong src/common.rs load_custom_client; src/lang.rs đã tự thay chữ "RustDesk" bằng tên app trong giao diện).

MỤC TIÊU: người dùng cuối không còn thấy chữ "rustdesk"/"RustDesk" ở file tải về, tên app đã cài, tên gói, tên dịch vụ, giao diện.

LÀM:
1. .github/workflows/flutter-build.yml (chỉ các job Windows flutter và Android): đổi tên file phát hành cuối cùng thành
   KinG-Remote-<version>-<arch>.exe / .msi và KinG-Remote-<version>-<arch>.apk (kể cả universal). Chỉ đổi tên ở bước mv/đặt tên
   file đầu ra cuối, đường dẫn upload-artifact và danh sách file gửi lên release (glob rustdesk-*.msi/exe/apk phải khớp tên mới).
   KHÔNG đổi tên rustdesk.exe/librustdesk bên trong quá trình build (các bước sau và generate.py/preprocess.py phụ thuộc nó),
   trừ khi chắc chắn mọi chỗ tham chiếu đều đổi theo.
2. Bộ cài MSI (res/msi/): tên sản phẩm, tên thư mục cài (Program Files), shortcut Start Menu/Desktop, tên dịch vụ Windows,
   mục Add/Remove Programs hiển thị "KinG-Remote". Xem preprocess.py nhận tham số tên app (vd --app-name) rồi truyền
   "KinG-Remote" từ workflow nếu có cách đó; ưu tiên cách ít sửa nhất. Kiểm tra tên dịch vụ Windows và thư mục cấu hình lấy
   từ APP_NAME (hbb_common) thì không cần sửa thêm.
3. Android: flutter/android/app/build.gradle đổi applicationId thành "com.king.remote" (giữ nguyên namespace/package Kotlin
   com.carriez.flutter_hbb để không phải đổi mã nguồn). Kiểm tra AndroidManifest/strings không còn chữ RustDesk hiển thị.
4. Rà các chuỗi hiển thị còn sót (flutter/lib/**/*.dart chuỗi literal có "RustDesk" hiện ra UI mà không qua translate,
   tiêu đề cửa sổ, tray tooltip, thông báo Android). Đổi sang tên app (dùng biến tên app có sẵn nếu có, vd bind.mainGetAppNameSync()).

KHÔNG ĐƯỢC ĐỤNG: libs/hbb_common (submodule, CI tải lại bản gốc nên sửa sẽ mất); tên crate/package Rust trong Cargo.toml
(rustdesk, librustdesk); LICENCE và ghi công bản quyền RustDesk (AGPL bắt buộc giữ); URL máy chủ mặc định; job macOS/iOS/Linux.

XONG KHI: `cargo metadata --no-deps --format-version 1 >NUL` chạy được (nếu có cargo), YAML hợp lệ
(python -c "import yaml,sys;yaml.safe_load(open('.github/workflows/flutter-build.yml',encoding='utf-8'))"), không commit.
TRẢ LỜI: danh sách file đã sửa + mỗi file 1 dòng tóm tắt; liệt kê chỗ còn chữ rustdesk mà người dùng vẫn thấy được nhưng bạn
không đổi (kèm lý do).
