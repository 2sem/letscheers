"""iOS 27 product-page header creative assets.

header_3840x1646.png    21:9 header         art safe area 1646x661 @ (1097,493)
universal_5244x2950.png 16:9 header+search  art safe area 1402x962 @ (1921,660)
Rules: no alpha, single focal point inside the safe area, short phrase, 4+ content.
Everything outside the safe area is decoration that may be cropped.
"""
import os, random
from PIL import Image, ImageDraw, ImageFilter
from make_images import font, rounded, ICON, HERE, WHITE, GOLD

BG_TOP, BG_BOTTOM = (0x2E, 0x15, 0x58), (0x12, 0x08, 0x1F)
CARD, CARD_LINE, DIM = (0x2A, 0x1A, 0x45), (0x4A, 0x34, 0x72), (0xD9, 0xCF, 0xF0)
TOASTS = ["(선)함께라면 (후)멀리간다", "(선)청춘은 (후)바로 지금", "(선)너와 나의 (후)타이밍",
          "몸도 마음도 건강하게", "(선)중요한 건 (후)꺾이지 않는 마음", "(선)나의 힘 (후)너의 힘",
          "(선)너나 (후)잘해!", "(선)우리 팀 (후)가보자고!", "고생하셨습니다 감사합니다",
          "(선)오늘도 (후)수고했어", "(선)위하여! (후)위하여!", "새해 복 많이 받으세요"]


def background(w, h):
    img = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / (h - 1)
        d.line([(0, y), (w, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)))
    return img.convert("RGBA")


def radial(img, center, radius, color, alpha):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    cx, cy = center
    ImageDraw.Draw(layer).ellipse([cx - radius, cy - radius, cx + radius, cy + radius], fill=color + (alpha,))
    return Image.alpha_composite(img, layer.filter(ImageFilter.GaussianBlur(radius * 0.55)))


def chip(text, size):
    f = font(size, 6)
    pad_x, pad_y = int(size * 0.9), int(size * 0.6)
    tw = int(ImageDraw.Draw(Image.new("RGBA", (1, 1))).textlength(text, font=f))
    w, h = tw + pad_x * 2, size + pad_y * 2
    c = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(c)
    d.rounded_rectangle([0, 0, w - 1, h - 1], h // 2 if size < 60 else int(size * 0.7), fill=CARD + (255,),
                        outline=CARD_LINE + (255,), width=max(2, size // 18))
    d.text((pad_x, pad_y - size * 0.12), text, font=f, fill=DIM)
    return c


def scatter_chips(img, safe, scale, seed):
    """Toast-title cards around (never inside) the safe area; farther = smaller, dimmer, blurrier."""
    rnd = random.Random(seed)
    W, H = img.size
    sx, sy, sw, sh = safe
    keep_out = (sx - 80 * scale, sy - 60 * scale, sx + sw + 80 * scale, sy + sh + 60 * scale)
    placed = []
    for attempt in range(4000):
        if len(placed) >= 26:
            break
        size = int(rnd.uniform(46, 78) * scale)
        c = chip(rnd.choice(TOASTS), size)
        x = rnd.randint(-c.width // 3, W - c.width * 2 // 3)
        y = rnd.randint(-c.height // 3, H - c.height * 2 // 3)
        box = (x, y, x + c.width, y + c.height)
        hit = lambda a, b, m=0: not (a[2] + m < b[0] or b[2] + m < a[0] or a[3] + m < b[1] or b[3] + m < a[1])
        if hit(box, keep_out) or any(hit(box, p, 30 * scale) for p in placed):
            continue
        placed.append(box)
        cx, cy = x + c.width / 2, y + c.height / 2
        dist = (((cx - (sx + sw / 2)) / W) ** 2 + ((cy - (sy + sh / 2)) / H) ** 2) ** 0.5
        alpha = max(0.15, 0.55 - dist * 0.9)
        c = c.rotate(rnd.uniform(-6, 6), resample=Image.BICUBIC, expand=True)
        if dist > 0.35:
            c = c.filter(ImageFilter.GaussianBlur(dist * 6 * scale))
        c.putalpha(c.split()[3].point(lambda v: int(v * alpha)))
        img.alpha_composite(c, (int(x), int(y)))
    return img


def sparkles(img, safe, scale, seed):
    rnd = random.Random(seed)
    d = ImageDraw.Draw(img)
    W, H = img.size
    sx, sy, sw, sh = safe
    for _ in range(90):
        x, y = rnd.randint(0, W), rnd.randint(0, H)
        if sx < x < sx + sw and sy < y < sy + sh:
            continue
        r = rnd.uniform(2, 7) * scale
        d.ellipse([x - r, y - r, x + r, y + r], fill=GOLD + (rnd.randint(60, 170),))
    return img


def focal(img, safe, scale):
    """Icon + phrase, fitted inside the safe area."""
    sx, sy, sw, sh = safe
    l1, l2 = "건배사,", "고민 끝!"
    f1, f2 = font(int(150 * scale), 14), font(int(250 * scale), 16)
    icon_s = int(430 * scale)
    gap = int(80 * scale)
    d = ImageDraw.Draw(img)
    tw = max(d.textlength(l1, font=f1), d.textlength(l2, font=f2))
    total_w = icon_s + gap + tw
    th = int(150 * scale) + int(30 * scale) + int(250 * scale)
    x0 = sx + (sw - total_w) / 2
    assert total_w <= sw and max(th, icon_s) <= sh, (total_w, sw, th, sh)

    cy = sy + sh / 2
    img = radial(img, (int(sx + sw / 2), int(cy)), int(sw * 0.55), (0x8A, 0x4F, 0xFF), 120)
    img = radial(img, (int(x0 + icon_s / 2), int(cy)), int(icon_s * 0.75), GOLD, 70)
    icon = rounded(Image.open(ICON).convert("RGB").resize((icon_s, icon_s), Image.LANCZOS), int(icon_s * 0.225))
    sh_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sh_layer.paste((0, 0, 0, 170), (int(x0), int(cy - icon_s / 2 + 24 * scale)), icon.split()[3])
    img = Image.alpha_composite(img, sh_layer.filter(ImageFilter.GaussianBlur(28 * scale)))
    img.alpha_composite(icon, (int(x0), int(cy - icon_s / 2)))

    d = ImageDraw.Draw(img)
    tx, ty = x0 + icon_s + gap, cy - th / 2
    d.text((tx, ty - 20 * scale), l1, font=f1, fill=WHITE)
    d.text((tx - 6 * scale, ty + 150 * scale + 30 * scale - 40 * scale), l2, font=f2, fill=GOLD)
    return img


def focal_stack(img, safe, scale):
    sx, sy, sw, sh = safe
    l1, l2 = "건배사,", "고민 끝!"
    s1, s2, icon_s = int(170 * scale), int(290 * scale), int(400 * scale)
    f1, f2 = font(s1, 14), font(s2, 16)
    d = ImageDraw.Draw(img)
    total_h = icon_s + int(50 * scale) + s1 + int(20 * scale) + s2
    assert d.textlength(l2, font=f2) <= sw and total_h <= sh
    cx = sx + sw / 2
    y = sy + (sh - total_h) / 2
    img = radial(img, (int(cx), int(sy + sh / 2)), int(sw * 0.6), (0x8A, 0x4F, 0xFF), 120)
    img = radial(img, (int(cx), int(y + icon_s / 2)), int(icon_s * 0.75), GOLD, 70)
    icon = rounded(Image.open(ICON).convert("RGB").resize((icon_s, icon_s), Image.LANCZOS), int(icon_s * 0.225))
    shl = Image.new("RGBA", img.size, (0, 0, 0, 0))
    shl.paste((0, 0, 0, 170), (int(cx - icon_s / 2), int(y + 24 * scale)), icon.split()[3])
    img = Image.alpha_composite(img, shl.filter(ImageFilter.GaussianBlur(28 * scale)))
    img.alpha_composite(icon, (int(cx - icon_s / 2), int(y)))
    d = ImageDraw.Draw(img)
    y += icon_s + 50 * scale
    d.text((cx - d.textlength(l1, font=f1) / 2, y - 0.15 * s1), l1, font=f1, fill=WHITE)
    y += s1 + 20 * scale
    d.text((cx - d.textlength(l2, font=f2) / 2, y - 0.15 * s2), l2, font=f2, fill=GOLD)
    return img


def render(w, h, safe, scale, name, seed, stack=False):
    img = background(w, h)
    img = sparkles(img, safe, scale, seed)
    img = scatter_chips(img, safe, scale, seed)
    img = (focal_stack if stack else focal)(img, safe, scale)
    img.convert("RGB").save(os.path.join(HERE, name))
    # review copy with the safe area outlined
    dbg = img.copy()
    sx, sy, sw, sh = safe
    ImageDraw.Draw(dbg).rectangle([sx, sy, sx + sw, sy + sh], outline=(0, 255, 120, 255), width=int(6 * scale))
    dbg.convert("RGB").save(os.path.join(HERE, "build", name.replace(".png", "_safearea.png")))


if __name__ == "__main__":
    os.makedirs(os.path.join(HERE, "build"), exist_ok=True)
    render(3840, 1646, (1097, 493, 1646, 661), 1.0, "header_3840x1646.png", 7)
    render(5244, 2950, (1921, 660, 1402, 962), 1.0, "universal_5244x2950.png", 11, stack=True)
