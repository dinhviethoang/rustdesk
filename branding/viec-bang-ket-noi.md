Repo: C:\Users\KiNG_613\Projects\rustdesk-rieng (app Flutter "KinG-Control", fork RustDesk). Máy này KHÔNG có Flutter SDK:
code Dart phải đúng cú pháp, tự soát kỹ (ngoặc, dấu phẩy, import, null-safety, const).

MỤC TIÊU: làm lại giao diện CỬA SỔ KẾT NỐI (connection manager — cửa sổ nhỏ hiện trên máy bị điều khiển khi có người vào:
avatar + tên + ID + "Connected" + thời gian, khối "Permissions" 8 nút, nút "Disconnect") theo mẫu đã duyệt
branding/mau-bang-dieu-khien.html (đọc kỹ CSS/HTML, làm giống nhất có thể). File chính: flutter/lib/desktop/pages/server_page.dart
(grep "Permissions", "Disconnect", "_buildPermission" để tìm đúng chỗ). Dùng lại widget có sẵn trong
flutter/lib/common/widgets/cyber_widgets.dart (CyberFrame, CyberGridBackground, CyberScanLine, CyberLabel, CyberIcon,
CyberPing...) nếu file đó đã có; thiếu gì thì thêm vào chính file đó, KHÔNG viết trùng.

Chi tiết theo mẫu (màu: nền #04070B, panel #070D14, viền #12303A, cyan #00E5FF, chữ #CFF8FF, phụ #5C7A86,
xanh lá #00FF9F, đỏ #FF3B5C):
1. Nền cửa sổ: CyberGridBackground + CyberScanLine.
2. Khối thông tin trong CyberFrame: avatar ô vuông vát góc viền cyan, chữ cái đầu cyan (thay khối gradient xanh cũ);
   tên VIẾT HOA giãn chữ; dòng "NODE <id>" kiểu CyberLabel; dòng trạng thái: chấm xanh lá nhấp nháy + "LINKED" (khi đã kết
   nối, giữ nguyên logic trạng thái cũ, chỉ đổi chữ hiển thị) + đồng hồ thời gian bên phải màu cyan; nút chat thành ô vuông
   viền mảnh icon cyan. Bên dưới 2 dòng key-value: "CIPHER  E2E" và "ROUTE  DIRECT" (chỉ là nhãn tĩnh trang trí; nếu có sẵn
   dữ liệu kiểu kết nối direct/relay thì hiển thị đúng giá trị thật).
3. Khối quyền trong CyberFrame, tiêu đề CyberLabel "// PERMISSIONS" màu cyan: lưới 4 cột, mỗi quyền là ô vuông vát góc
   46x46: BẬT = viền cyan mờ + nền cyan 8% + icon cyan; TẮT = viền #12303A, nền trong suốt, icon #5C7A86. Dưới mỗi ô là nhãn
   ngắn VIẾT HOA cỡ 8: INPUT, CLIP, AUDIO, FILES, REBOOT, REC, BLOCK, PRIVACY (map đúng theo quyền tương ứng hiện có; quyền nào
   không có thì bỏ). Giữ nguyên hành vi bấm bật/tắt và tooltip cũ. Icon dùng biến thể _outlined/_sharp có thật trong Flutter SDK.
4. Nút ngắt kết nối: viền đỏ #FF3B5C, nền đỏ 8%, chữ đỏ "TERMINATE LINK" giãn chữ, icon nguồn, góc vát. Giữ nguyên hành vi.
   Các nút khác trong cửa sổ (Accept/Dismiss khi chờ duyệt...) cũng đổi sang style nút cyan vát góc cho đồng bộ.

KHÔNG ĐỤNG: Rust (src/, libs/), pubspec.yaml, native, logo, chuỗi dịch, logic. Không xoá tính năng.

XONG KHI: `git diff --stat` chỉ trong flutter/lib; import dạng package:flutter_hbb/...; không dùng API không tồn tại; cân bằng
ngoặc. TRẢ LỜI: file đã sửa + mỗi file 1 dòng, chỗ nào không chắc.
