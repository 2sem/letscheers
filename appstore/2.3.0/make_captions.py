"""Caption backgrounds (886x1920) + rounded mask for the recorded-preview composite."""
import os
from PIL import Image, ImageDraw
from make_images import gradient, glow, font, draw_segments, HERE

W, H = 886, 1920
PHONE_W, PHONE_H, PHONE_Y = 700, 1520, 360  # recording is scaled to this box
CAPTIONS = [
    ["건배사 차례?", "이제 [당황하지 마세요]"],
    ["[탭 한 번에]", "건배사 완성"],
    ["[크게, 한눈에]", "낭독하세요"],
    ["상황별 건배사를", "[쉽고 빠르게]"],
    ["건배사를 [카드로]", "센스 있게 공유"],
]
OUT = os.path.join(HERE, "build")
os.makedirs(OUT, exist_ok=True)

for i, lines in enumerate(CAPTIONS, 1):
    img = gradient(W, H).convert("RGBA")
    img = glow(img, (W // 2, 1100), 420, (0x8A, 0x4F, 0xFF), 70)
    d = ImageDraw.Draw(img)
    for j, line in enumerate(lines):
        draw_segments(d, (0, 110 + j * 104), line, font(84, 14), center_w=W)
    # bezel behind the recording
    x = (W - PHONE_W) // 2
    b = 14
    d.rounded_rectangle([x - b, PHONE_Y - b, x + PHONE_W + b, PHONE_Y + PHONE_H + b], 96,
                        fill=(18, 12, 28, 255), outline=(90, 70, 130, 255), width=3)
    img.convert("RGB").save(os.path.join(OUT, f"cap{i}.png"))

mask = Image.new("L", (PHONE_W, PHONE_H), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, PHONE_W - 1, PHONE_H - 1], 84, fill=255)
mask.save(os.path.join(OUT, "mask.png"))
