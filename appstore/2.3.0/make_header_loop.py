"""Seamless-loop header video, 3840x1646 @30fps, muted, same composition as header_3840x1646.png.

Every motion is periodic in the loop length T, so frame N == frame 0 and the loop has no seam.
The focal block (icon + phrase) stays fixed so it's always readable; only decoration moves.
"""
import math, os, random, subprocess, sys
from PIL import Image, ImageDraw, ImageFilter
from make_header import background, chip, radial, focal, TOASTS, GOLD, HERE

W, H, FPS, T = 3840, 1646, 30, 10.0
SAFE = (1097, 493, 1646, 661)
N = int(FPS * T)
TAU = 2 * math.pi


def layout(seed=7, scale=1.0):
    """Same placement algorithm as the still, kept as sprites so they can move."""
    rnd = random.Random(seed)
    sx, sy, sw, sh = SAFE
    keep_out = (sx - 140, sy - 110, sx + sw + 140, sy + sh + 110)  # extra margin for drift
    hit = lambda a, b, m=0: not (a[2] + m < b[0] or b[2] + m < a[0] or a[3] + m < b[1] or b[3] + m < a[1])
    sprites, placed = [], []
    for _ in range(4000):
        if len(placed) >= 26:
            break
        size = int(rnd.uniform(46, 78) * scale)
        c = chip(rnd.choice(TOASTS), size)
        x = rnd.randint(-c.width // 3, W - c.width * 2 // 3)
        y = rnd.randint(-c.height // 3, H - c.height * 2 // 3)
        box = (x, y, x + c.width, y + c.height)
        if hit(box, keep_out) or any(hit(box, p, 30) for p in placed):
            continue
        placed.append(box)
        cx, cy = x + c.width / 2, y + c.height / 2
        dist = (((cx - (sx + sw / 2)) / W) ** 2 + ((cy - (sy + sh / 2)) / H) ** 2) ** 0.5
        alpha = max(0.15, 0.55 - dist * 0.9)
        c = c.rotate(rnd.uniform(-6, 6), resample=Image.BICUBIC, expand=True)
        if dist > 0.35:
            c = c.filter(ImageFilter.GaussianBlur(dist * 6))
        c.putalpha(c.split()[3].point(lambda v: int(v * alpha)))
        # closer cards drift less (parallax); 1 or 2 orbits per loop keeps it periodic
        amp = 18 + dist * 60
        sprites.append(dict(img=c, x=x, y=y, ax=amp * rnd.uniform(0.6, 1.0), ay=amp * rnd.uniform(0.3, 0.6),
                            k=rnd.choice([1, 1, 2]), ph=rnd.uniform(0, TAU)))
    return sprites


def main():
    rnd = random.Random(99)
    base = background(W, H)
    sprites = layout()
    focal_layer = focal(Image.new("RGBA", (W, H), (0, 0, 0, 0)), SAFE, 1.0)
    sx, sy, sw, sh = SAFE
    dots = []
    while len(dots) < 110:
        x, y = rnd.randint(0, W), rnd.randint(0, H)
        if not (sx < x < sx + sw and sy < y < sy + sh):
            dots.append((x, y, rnd.uniform(2, 7), rnd.randint(1, 3), rnd.uniform(0, TAU)))

    out = os.path.join(HERE, "header_loop_3840x1646.mp4")
    ff = subprocess.Popen(["ffmpeg", "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "rgb24",
                           "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
                           "-c:v", "libx264", "-profile:v", "high", "-level", "5.1", "-pix_fmt", "yuv420p",
                           "-crf", "16", "-preset", "slow", "-tune", "animation", "-movflags", "+faststart",
                           "-an", out], stdin=subprocess.PIPE)
    for f in range(N):
        t = f / N  # 0..1, frame N would equal frame 0
        img = base.copy()
        # breathing glow behind the focal block
        pulse = 0.5 + 0.5 * math.sin(TAU * t)
        img = radial(img, (sx + sw // 2, sy + sh // 2), int(sw * (0.6 + 0.05 * pulse)), (0x8A, 0x4F, 0xFF),
                     int(40 + 40 * pulse))
        d = ImageDraw.Draw(img)
        for x, y, r, k, ph in dots:
            a = int(30 + 150 * (0.5 + 0.5 * math.sin(TAU * k * t + ph)))
            d.ellipse([x - r, y - r, x + r, y + r], fill=GOLD + (a,))
        for s in sprites:
            ang = TAU * s["k"] * t + s["ph"]
            img.alpha_composite(s["img"], (int(s["x"] + s["ax"] * math.sin(ang)),
                                           int(s["y"] + s["ay"] * math.sin(2 * ang))))
        img.alpha_composite(focal_layer)
        ff.stdin.write(img.convert("RGB").tobytes())
        if f % 30 == 0:
            print(f"frame {f}/{N}", file=sys.stderr, flush=True)
    ff.stdin.close()
    ff.wait()
    print(out)


if __name__ == "__main__":
    main()
