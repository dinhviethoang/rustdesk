Repo: C:\Users\KiNG_613\Projects\rustdesk-rieng (app Flutter "KinG-Control", fork RustDesk). Máy này KHÔNG có Flutter SDK:
code Dart phải đúng cú pháp, tự soát kỹ (ngoặc, dấu phẩy, import, null-safety, const).

MẪU THIẾT KẾ ĐÃ DUYỆT: branding/mau-giao-dien-hud.html (đọc kỹ CSS + HTML, làm giống nhất có thể trong Flutter).
Phong cách HUD công nghệ: lưới kẻ ô mờ, khung có 4 góc ngoặc vuông cyan, nút/ô nhập vát góc chéo, nhãn VIẾT HOA giãn chữ.

1. ĐỔI BẢNG MÀU trong flutter/lib/common.dart (MyTheme + ColorThemeExtension + darkTheme; lightTheme đang trỏ về darkTheme,
   giữ vậy). Màu chính giờ là CYAN, không còn xanh neon làm màu chính:
   nền #04070B, panel #070D14, ô nhập #03080D, viền/đường kẻ #12303A, màu chính #00E5FF (nút, focus, link, switch bật,
   tiêu đề), màu chính mờ rgba(0,229,255,.55), chữ #CFF8FF, chữ phụ #5C7A86, xanh lá #00FF9F CHỈ cho trạng thái online/ok,
   cảnh báo #FFB020, lỗi/ngắt #FF3B5C. Chữ trên nút cyan: #02060A, đậm, letterSpacing 3. Bo góc nút/ô nhập = 0
   (dùng BeveledRectangleBorder radius ~8 cho góc vát). Font monospace giữ như hiện tại.

2. TẠO flutter/lib/common/widgets/cyber_widgets.dart (chỉ Flutter SDK, không package mới, không sửa pubspec.yaml):
   a. CyberFrame({child, padding}): khung nền panel, viền #12303A, 4 góc ngoặc cyan 12px dày 2px (CustomPainter).
   b. CyberGridBackground({child}): nền #04070B + lưới kẻ ô 24px màu rgba(0,229,255,.12) (CustomPainter).
   c. CyberRadar({size}): vạch chia độ quanh viền (mỗi 10°), vòng nét đứt xoay chậm 30s/vòng ngược chiều, 2 vòng trong,
      chữ thập, tia quét SweepGradient cyan xoay 3s/vòng, 2 chấm xanh lá phát sáng nhấp nháy. Dispose controller.
   d. CyberSignalBars({level 0..5}): 5 cột cao dần; màu: 5-4 cyan, 3 vàng, 2-1 đỏ, cột tắt #12303A; animate.
   e. CyberPing({int? ms}): "PING 023ms" (3 chữ số, null -> "PING ---"), màu theo ngưỡng như cột; hàm levelFromPing(ms):
      <40→5, <80→4, <150→3, <250→2, còn lại 1.
   f. CyberScanLine: vạch sáng cyan 1px chạy dọc trên xuống 5s/lượt, IgnorePointer, opacity .6.
   g. CyberLabel(text): chữ VIẾT HOA cỡ 10, letterSpacing 2.5, màu #5C7A86.
   h. CyberIcon({icon, color, danger=false}): ô vuông 30x30 viền #12303A, icon nét mảnh 15px cyan (đỏ khi danger).

3. GẮN VÀO MÀN HÌNH (giữ nguyên logic, chỉ bọc/thêm giao diện):
   - Desktop màn hình chính flutter/lib/desktop/pages/desktop_home_page.dart: bọc trang bằng CyberGridBackground +
     CyberScanLine; cột trái dùng CyberLabel cho nhãn ("NODE ID", "ACCESS KEY") và thêm khối trạng thái kiểu key-value
     (STATUS ● ONLINE xanh lá nếu dịch vụ đang chạy, có sẵn biến trạng thái thì dùng, không có thì bỏ dòng đó);
     thêm CyberRadar size ~160 + CyberLabel "SCANNING_" ở khu vực kết nối (flutter/lib/desktop/pages/connection_page.dart
     nếu ô nhập nằm ở đó). Nút kết nối chữ "CONNECT" dùng style nút mới.
   - Mobile flutter/lib/mobile/pages/connection_page.dart: CyberRadar size ~130 phía trên ô nhập, CyberLabel "SCANNING_".
   - Trong phiên điều khiển: tìm dữ liệu độ trễ (grep "delay" / QualityMonitor / qualityMonitorModel trong flutter/lib),
     thêm cụm CyberSignalBars + CyberPing vào thanh công cụ (desktop flutter/lib/desktop/widgets/remote_toolbar.dart;
     mobile flutter/lib/mobile/pages/remote_page.dart). Parse delay an toàn sang int; chưa có thì "PING ---".
   - Icon: trong các file trên đổi icon Material sang biến thể _outlined/_sharp có thật trong Flutter SDK, bọc CyberIcon
     ở thanh công cụ; nút ngắt kết nối danger=true.

KHÔNG ĐỤNG: Rust (src/, libs/), pubspec.yaml, android/ios/windows native, logo/app icon, chuỗi dịch, logic kết nối,
.github/, README, HUONG-DAN-CAI-DAT.md.

XONG KHI: `git diff --stat` chỉ trong flutter/lib; import dạng package:flutter_hbb/...; không dùng API không tồn tại;
mọi file Dart cân bằng ngoặc. TRẢ LỜI: file đã sửa/tạo + mỗi file 1 dòng, chỗ nào không chắc về API/cú pháp.
