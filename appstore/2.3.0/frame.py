"""Compose App Store marketing frames from raw simulator screenshots.

usage: python3 frame.py <raw_dir> <out_dir> <width> <height>
"""
import sys, os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

RAW, OUT, W, H = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
os.makedirs(OUT, exist_ok=True)

TOP, BOTTOM = (0x3A, 0x1B, 0x6B), (0x14, 0x0A, 0x22)
WHITE, GOLD = (255, 255, 255), (0xFF, 0xC8, 0x57)
FONT_PATH = "/System/Library/Fonts/AppleSDGothicNeo.ttc"

# (file, [line, line]) — segments wrapped in [] are gold
FRAMES = [
    ("01_home.png",   ["건배사 차례?", "이제 [당황하지 마세요]"]),
    ("02_random.png", ["[탭 한 번에]", "건배사 완성"]),
    ("03_detail.png", ["[크게, 한눈에]", "낭독하세요"]),
    ("04_list.png",   ["상황별 건배사를", "[쉽고 빠르게]"]),
    ("05_share.png",  ["건배사를 [카드로]", "센스 있게 공유"]),
]


def font(size):
    # index 8 = Heavy in AppleSDGothicNeo.ttc; fall back to bold variants
    for idx in (6,):
        try:
            f = ImageFont.truetype(FONT_PATH, size, index=idx)
            return f
        except Exception:
            continue
    return ImageFont.truetype(FONT_PATH, size)


def gradient():
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / (H - 1)
        d.line([(0, y), (W, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(TOP, BOTTOM)))
    return img


def segments(line):
    out, gold, buf = [], False, ""
    for ch in line:
        if ch in "[]":
            if buf:
                out.append((buf, gold))
            buf, gold = "", ch == "["
        else:
            buf += ch
    if buf:
        out.append((buf, gold))
    return out


def draw_headline(img, lines, top, size):
    d = ImageDraw.Draw(img)
    f = font(size)
    y = top
    for line in lines:
        segs = segments(line)
        total = sum(d.textlength(t, font=f) for t, _ in segs)
        x = (W - total) / 2
        for text, gold in segs:
            d.text((x, y), text, font=f, fill=GOLD if gold else WHITE)
            x += d.textlength(text, font=f)
        y += int(size * 1.25)
    return y


def rounded(shot, radius):
    mask = Image.new("L", shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, *shot.size], radius=radius, fill=255)
    shot.putalpha(mask)
    return shot


for name, lines in FRAMES:
    src = os.path.join(RAW, name)
    if not os.path.exists(src):
        print("missing", src)
        continue
    canvas = gradient().convert("RGBA")
    size = int(W * 0.082)
    text_bottom = draw_headline(canvas, lines, int(H * 0.055), size)

    shot = Image.open(src).convert("RGBA")
    avail_h = H - text_bottom - int(H * 0.04)
    scale = min(avail_h / shot.height, (W * 0.86) / shot.width)
    shot = shot.resize((int(shot.width * scale), int(shot.height * scale)), Image.LANCZOS)
    shot = rounded(shot, int(shot.width * 0.075))

    x = (W - shot.width) // 2
    y = text_bottom + int(H * 0.025)
    if shot.height < avail_h * 0.8:
        y = text_bottom + (H - text_bottom - shot.height) // 2
    # soft glow behind the device
    glow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(glow).rounded_rectangle(
        [x - 10, y - 10, x + shot.width + 10, y + shot.height + 10],
        radius=int(shot.width * 0.08), fill=(0xD0, 0xA0, 0xFF, 70))
    canvas = Image.alpha_composite(canvas, glow.filter(ImageFilter.GaussianBlur(40)))
    canvas.alpha_composite(shot, (x, y))
    canvas.convert("RGB").save(os.path.join(OUT, name), "PNG")
    print("wrote", os.path.join(OUT, name), canvas.size)
