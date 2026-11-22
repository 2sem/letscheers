"""Header (1920x1080) + preview end card (886x1920) for 술마셔 건배사 2.3.0."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
FRAMED = os.path.join(HERE, "src/raw")
ICON = "/Users/LYJ/Projects/leesam/letscheers/src/letscheers/Projects/App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
FONT = "/System/Library/Fonts/AppleSDGothicNeo.ttc"
TOP, BOTTOM = (0x3A, 0x1B, 0x6B), (0x14, 0x0A, 0x22)
WHITE, GOLD, DIM = (255, 255, 255), (0xFF, 0xC8, 0x57), (0xC9, 0xBE, 0xE0)


def font(size, idx=6):
    return ImageFont.truetype(FONT, size, index=idx)


def gradient(w, h, diagonal=False):
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        for x in range(0, w, 1) if diagonal else [None]:
            t = ((x / w) * 0.4 + (y / h) * 0.6) if diagonal else y / (h - 1)
            c = tuple(int(a + (b - a) * t) for a, b in zip(TOP, BOTTOM))
            if diagonal:
                px[x, y] = c
        if not diagonal:
            ImageDraw.Draw(img).line([(0, y), (w, y)], fill=c)
    return img


def glow(img, center, radius, color, alpha=110):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    cx, cy = center
    d.ellipse([cx - radius, cy - radius, cx + radius, cy + radius], fill=color + (alpha,))
    layer = layer.filter(ImageFilter.GaussianBlur(radius * 0.6))
    return Image.alpha_composite(img.convert("RGBA"), layer)


def rounded(img, r):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, *img.size], r, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def phone(shot_path, width):
    """Raw screenshot inside a dark bezel with rounded corners."""
    shot = Image.open(shot_path).convert("RGB")
    h = int(shot.height * width / shot.width)
    shot = shot.resize((width, h), Image.LANCZOS)
    bezel = int(width * 0.035)
    body = Image.new("RGBA", (width + bezel * 2, h + bezel * 2), (0, 0, 0, 0))
    ImageDraw.Draw(body).rounded_rectangle([0, 0, *body.size], int(width * 0.15), fill=(18, 12, 28, 255),
                                           outline=(90, 70, 130, 255), width=max(2, bezel // 5))
    body.alpha_composite(rounded(shot, int(width * 0.12)), (bezel, bezel))
    return body


def with_shadow(base, item, pos, blur=40, offset=(0, 30)):
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0))
    a = item.split()[3].point(lambda v: int(v * 0.6))
    sh.paste((0, 0, 0, 255), (pos[0] + offset[0], pos[1] + offset[1]), a)
    sh = sh.filter(ImageFilter.GaussianBlur(blur))
    base = Image.alpha_composite(base, sh)
    base.alpha_composite(item, pos)
    return base


def draw_segments(d, xy, text, f, anchor_left=True, center_w=None):
    """`[gold]` segments; left-aligned at xy, or centered in center_w."""
    parts, gold, buf = [], False, ""
    for ch in text:
        if ch in "[]":
            if buf:
                parts.append((buf, gold))
            buf, gold = "", ch == "["
        else:
            buf += ch
    if buf:
        parts.append((buf, gold))
    total = sum(d.textlength(p, font=f) for p, _ in parts)
    x, y = xy
    if center_w is not None:
        x = (center_w - total) / 2
    for p, g in parts:
        d.text((x, y), p, font=f, fill=GOLD if g else WHITE)
        x += d.textlength(p, font=f)


def header():
    W, H = 1920, 1080
    img = gradient(W, H).convert("RGBA")
    img = glow(img, (1420, 520), 420, (0x8A, 0x4F, 0xFF), 90)
    img = glow(img, (300, 900), 300, (0xFF, 0xC8, 0x57), 40)
    d = ImageDraw.Draw(img)

    icon = rounded(Image.open(ICON).convert("RGB").resize((150, 150), Image.LANCZOS), 34)
    img = with_shadow(img, icon, (140, 250), blur=20, offset=(0, 12))
    d = ImageDraw.Draw(img)
    d.text((140, 440), "술마셔 건배사", font=font(64, 4), fill=DIM)
    draw_segments(d, (140, 530), "건배사 차례?", font(104, 14))
    draw_segments(d, (140, 655), "이제 [당황하지 마세요]", font(104, 14))
    d.text((144, 810), "상황별 건배사를 쉽고 빠르게 · 랜덤 뽑기 · 카드 공유", font=font(38, 4), fill=DIM)

    # three phones, centre one raised
    specs = [("02_random.png", 330, (1060, 250), -7), ("01_home.png", 380, (1290, 150), 0),
             ("03_detail.png", 330, (1550, 250), 7)]
    order = [0, 2, 1]
    for i in order:
        f, w, pos, rot = specs[i]
        p = phone(os.path.join(FRAMED, f), w)
        if rot:
            p = p.rotate(rot, resample=Image.BICUBIC, expand=True)
        img = with_shadow(img, p, pos)
    img.convert("RGB").save(os.path.join(HERE, "header_1920x1080.png"))


def endcard():
    W, H = 886, 1920
    img = gradient(W, H).convert("RGBA")
    img = glow(img, (W // 2, 820), 380, (0x8A, 0x4F, 0xFF), 100)
    icon = rounded(Image.open(ICON).convert("RGB").resize((260, 260), Image.LANCZOS), 58)
    img = with_shadow(img, icon, ((W - 260) // 2, 640), blur=24, offset=(0, 14))
    d = ImageDraw.Draw(img)
    draw_segments(d, (0, 960), "술마셔 [건배사]", font(84, 14), center_w=W)
    for i, line in enumerate(["회식·술자리 건배제의,", "이제 당황하지 마세요."]):
        w = d.textlength(line, font=font(44, 4))
        d.text(((W - w) / 2, 1100 + i * 64), line, font=font(44, 4), fill=DIM)
    img.convert("RGB").save(os.path.join(HERE, "endcard.png"))


if __name__ == "__main__":
    header()
    endcard()
