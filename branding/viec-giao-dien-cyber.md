Repo: C:\Users\KiNG_613\Projects\rustdesk-rieng (app Flutter "KinG-Remote", fork RustDesk). Build bằng GitHub Actions, máy này
KHÔNG có Flutter SDK nên không chạy thử được: sửa phải cẩn thận đúng cú pháp Dart.

MỤC TIÊU: đổi giao diện sang phong cách "cyber hacker công nghệ" cho cả desktop (Windows) và Android, bằng cách sửa THEME
chung, không viết lại từng màn hình.

Bảng màu (dùng đúng các mã này):
- Nền chính #0A0E14, nền thẻ/khung #111821, nền ô nhập #0D131B, viền #1F2A37 (hover/focus: #00FF9F).
- Màu nhấn chính xanh neon #00FF9F (nút, link, ô được chọn, thanh tiến trình, switch/checkbox bật).
- Màu nhấn phụ cyan #00E5FF (ID máy, tiêu đề phụ, icon).
- Chữ chính #D6FFE9, chữ phụ #7A8B99, lỗi #FF3B5C, cảnh báo #FFB020.

LÀM (flutter/lib/common.dart, class MyTheme từ khoảng dòng 248; darkTheme ~dòng 471; lightTheme ~dòng 372):
1. Đổi các hằng màu MyTheme.accent/accent50/accent80/button/idColor/cmIdColor/canvasColor... sang bảng màu trên.
2. darkTheme: áp bảng màu vào colorScheme, scaffoldBackgroundColor, cardColor, dialogBackgroundColor, inputDecorationTheme
   (viền mảnh, focus neon), elevatedButton/textButton/outlinedButton theme (nền #00FF9F chữ #0A0E14, bo góc 4 — vuông vức
   kiểu terminal), switch/checkbox/radio theme, tabBarTheme, tooltip, scrollbar, divider #1F2A37.
3. lightTheme: cho giống hệt darkTheme (app luôn tối), để người dùng chọn sáng/tối gì cũng ra giao diện cyber.
4. Font: dùng font monospace có sẵn của hệ thống cho chữ số/ID và tiêu đề (fontFamily 'Consolas' trên Windows,
   'monospace' trên Android, fallback 'Courier New'); KHÔNG thêm package/font file mới, KHÔNG sửa pubspec.yaml.
5. Mặc định theme tối: tìm chỗ đọc tuỳ chọn theme (grep "theme" trong flutter/lib/common.dart, flutter/lib/models/...,
   ví dụ MyTheme.currentThemeMode / getThemeModePreference) và cho mặc định là ThemeMode.dark khi chưa đặt.
6. Hiệu ứng nhẹ (tuỳ chọn, chỉ khi chắc chắn đúng cú pháp): viền phát sáng neon (BoxShadow #00FF9F alpha thấp) cho nút chính.

KHÔNG ĐỤNG: Rust (src/, libs/), pubspec.yaml, android/ios native, logo/icon, chuỗi dịch. Không đổi logic, chỉ đổi giao diện.
Có file khác đang được sửa song song (README, docs/, .github/) — không động vào chúng.

XONG KHI: `git diff --stat` chỉ có file trong flutter/lib; ngoặc/dấu phẩy Dart cân bằng (tự soát lại từng ThemeData).
TRẢ LỜI: danh sách file đã sửa + tóm tắt 3-5 dòng, chỗ nào không chắc chắn về cú pháp.
