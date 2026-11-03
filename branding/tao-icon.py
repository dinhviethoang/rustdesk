"""Tạo lại toàn bộ icon của app từ branding/logo-king-goc.png.

Chạy từ thư mục gốc repo:  python branding/tao-icon.py
Mỗi file icon được ghi đè đúng tên, đúng kích thước pixel, đúng định dạng.
"""
import base64
import io
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent


def xoa_nen(img, tol=30):
    """Biến nền trắng ngà liền với mép ảnh thành trong suốt, làm mềm mép, rồi cắt sát logo."""
    arr = np.asarray(img.convert("RGB")).astype(np.float32)
    border = np.concatenate([arr[0], arr[-1], arr[:, 0], arr[:, -1]])
    bg = np.median(border, axis=0)
    dist = np.abs(arr - bg).max(axis=2)
    # Chỉ xoá vùng gần màu nền nối liền với mép (giữ phần trắng bên trong logo).
    cand = Image.fromarray(((dist < tol * 2) * 255).astype(np.uint8))
    pad = Image.new("L", (cand.width + 2, cand.height + 2), 255)
    pad.paste(cand, (1, 1))
    ImageDraw.floodfill(pad, (0, 0), 128)
    noi_mep = np.asarray(pad)[1:-1, 1:-1] == 128
    a = np.where(noi_mep, np.clip((dist - tol) / tol, 0, 1), 1.0)
    # Trừ màu nền khỏi điểm bán trong suốt để không còn viền trắng.
    safe = np.maximum(a, 1e-3)[..., None]
    rgb = np.clip((arr - bg * (1 - a[..., None])) / safe, 0, 255)
    out = Image.fromarray(np.dstack([rgb, a * 255]).astype(np.uint8), "RGBA")
    bbox = out.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
    out = out.crop(bbox)
    side = int(max(out.size) * 1.04)
    sq = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    sq.paste(out, ((side - out.width) // 2, (side - out.height) // 2))
    return sq


LOGO = xoa_nen(Image.open(ROOT / "branding" / "logo-king-goc.png"))
ICO_SIZES = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]


def logo(size, scale=1.0):
    """Logo vuông `size`, thu nhỏ theo `scale` và đặt giữa nền trong suốt."""
    w, h = size
    inner = max(1, int(min(w, h) * scale))
    img = LOGO.resize((inner, inner), Image.LANCZOS)
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    canvas.paste(img, ((w - inner) // 2, (h - inner) // 2), img)
    return canvas


def mono(size, color, scale=1.0):
    """Hình đơn sắc `color` theo kênh alpha của logo (icon khay hệ thống/thông báo)."""
    alpha = logo(size, scale).getchannel("A")
    out = Image.new("RGBA", size, color + (0,))
    out.putalpha(alpha)
    return out


def main_color(path):
    """Màu trung bình các điểm không trong suốt của icon cũ, để giữ tông sáng/tối."""
    old = Image.open(path).convert("RGBA")
    px = [p for p in old.getdata() if p[3] > 128]
    if not px:
        return (255, 255, 255)
    return tuple(sum(p[i] for p in px) // len(px) for i in range(3))


def write_png(path, monochrome=False, scale=1.0):
    size = Image.open(path).size
    if monochrome:
        img = mono(size, main_color(path), scale)
    else:
        img = logo(size, scale)
    img.save(path, "PNG", optimize=True)
    return path


def write_ico(path):
    logo((256, 256)).save(path, format="ICO", sizes=ICO_SIZES)
    return path


def write_svg(path):
    buf = io.BytesIO()
    logo((512, 512)).save(buf, "PNG", optimize=True)
    data = base64.b64encode(buf.getvalue()).decode()
    path.write_text(
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512" '
        'width="512" height="512">'
        f'<image width="512" height="512" xlink:href="data:image/png;base64,{data}"/>'
        "</svg>\n",
        encoding="utf-8",
    )
    return path


def main():
    done = []
    res = ROOT / "res"
    for name in ["32x32.png", "64x64.png", "128x128.png", "128x128@2x.png", "icon.png", "mac-icon.png"]:
        done.append(write_png(res / name))
    for name in ["mac-tray-dark-x2.png", "mac-tray-light-x2.png"]:
        done.append(write_png(res / name, monochrome=True))
    for p in [res / "icon.ico", res / "tray-icon.ico",
              ROOT / "flutter/windows/runner/resources/app_icon.ico"]:
        done.append(write_ico(p))
    for p in [res / "logo.svg", res / "scalable.svg", ROOT / "flutter/assets/icon.svg"]:
        done.append(write_svg(p))

    android = ROOT / "flutter/android/app/src/main/res"
    for p in android.glob("mipmap-*/ic_launcher.png"):
        done.append(write_png(p))
    for p in android.glob("mipmap-*/ic_launcher_round.png"):
        done.append(write_png(p))
    # Icon thích ứng: phần nhìn thấy chỉ là vùng giữa ~66% của khung 108dp.
    for p in android.glob("mipmap-*/ic_launcher_foreground.png"):
        done.append(write_png(p, scale=0.62))
    # Icon thanh thông báo Android bắt buộc là hình trắng trên nền trong suốt.
    for p in android.glob("mipmap-*/ic_stat_logo.png"):
        size = Image.open(p).size
        mono(size, (255, 255, 255)).save(p, "PNG", optimize=True)
        done.append(p)

    for base in ["flutter/macos", "flutter/ios"]:
        for p in (ROOT / base).rglob("AppIcon.appiconset/*.png"):
            done.append(write_png(p))

    for p in done:
        print(p.relative_to(ROOT).as_posix())
    print(f"Tong: {len(done)} file")


if __name__ == "__main__":
    main()
