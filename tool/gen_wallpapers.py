#!/usr/bin/env python3
"""Original depth-effect fonlar: assets/wallpapers/wN.jpg (to'liq) + wN_fg.webp (cutout)."""
import math, random, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

W, H, SS = 1080, 2400, 2
OUT = sys.argv[1] if len(sys.argv) > 1 else 'assets/wallpapers'

def grad(stops):
    ys = np.linspace(0, 1, H)[:, None]
    out = np.zeros((H, W, 3))
    for c in range(3):
        out[:, :, c] = np.interp(ys, [p for p, _ in stops], [s[c] for _, s in stops])
    return out

def mask(draw_fn):
    m = Image.new('L', (W * SS, H * SS), 0)
    draw_fn(ImageDraw.Draw(m), lambda p: (p[0] * W * SS, p[1] * H * SS))
    return np.asarray(m.resize((W, H), Image.LANCZOS), dtype=np.float32) / 255

def poly_mask(pts):
    return mask(lambda d, s: d.polygon([s(p) for p in pts], fill=255))

def jag(pts, rough, depth, seed):
    rnd = random.Random(seed)
    for _ in range(depth):
        new = []
        for a, b in zip(pts, pts[1:]):
            m = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2 +
                 rnd.uniform(-1, 1) * rough * math.hypot(b[0] - a[0], (b[1] - a[1]) * .5))
            new += [a, m]
        new.append(pts[-1]); pts = new; rough *= .72
    return pts

def ridge_mask(ctrl, rough, depth, seed):
    pts = jag(ctrl, rough, depth, seed)
    return poly_mask(pts + [(1.05, 1.02), (-.05, 1.02)])

def blend(base, color, m, a=1.0):
    col = np.array(color, dtype=np.float32) if np.ndim(color) == 1 else color
    return base * (1 - m[..., None] * a) + col * (m[..., None] * a)

def glow(cx, cy, r, color, strength):
    y, x = np.mgrid[0:H, 0:W]
    d = np.sqrt(((x - cx * W)) ** 2 + ((y - cy * H)) ** 2) / (r * W)
    g = np.clip(1 - d, 0, 1) ** 2 * strength
    return g, np.array(color, dtype=np.float32)

def stars(img, n, seed, ymax=.5):
    rnd = random.Random(seed)
    im = Image.fromarray(img.astype('uint8')); d = ImageDraw.Draw(im)
    for _ in range(n):
        x, y = rnd.randint(0, W), int(rnd.random() * ymax * H)
        v = rnd.randint(150, 255); r = rnd.choice([1, 1, 2])
        d.ellipse([x - r, y - r, x + r, y + r], fill=(v, v, min(255, v + 10)))
    return np.asarray(im, dtype=np.float32)

def finish(bg, fg_rgb, fg_a, idx):
    rnd = np.random.default_rng(idx)
    bg = np.clip(bg + rnd.normal(0, 2.2, bg.shape), 0, 255)
    fg_rgb = np.clip(fg_rgb + rnd.normal(0, 1.6, fg_rgb.shape), 0, 255)
    bgi = Image.fromarray(bg.astype('uint8'))
    fgi = Image.fromarray(np.dstack([fg_rgb, fg_a[..., None] * 255]).astype('uint8'), 'RGBA')
    full = bgi.convert('RGBA'); full.alpha_composite(fgi)
    full.convert('RGB').save(f'{OUT}/w{idx}.jpg', quality=86, optimize=True)
    fgi.save(f'{OUT}/w{idx}_fg.webp', quality=90, alpha_quality=100, method=6)

def shade_sides(rgb, m, apex, lit_dir=-1, amt=.55, tint=(40, 50, 90)):
    """apex dan pastga vertikal chiziq: o'ng tomon soya."""
    xs = np.linspace(0, 1, W)[None, :] * np.ones((H, 1))
    ys = np.linspace(0, 1, H)[:, None] * np.ones((1, W))
    line = apex[0] + (ys - apex[1]) * .18
    sh = np.clip((xs - line) * 40, 0, 1) * m
    return rgb * (1 - sh[..., None] * amt) + np.array(tint) * (sh[..., None] * amt * .5)

# ---------------------------------------------------------------- 1 Alps
def alps():
    bg = grad([(0, (8, 48, 150)), (.45, (30, 110, 220)), (.8, (150, 200, 245)), (1, (210, 232, 250))])
    for i, (col, ctrl) in enumerate([((90, 130, 200), [(-.05, .62), (.2, .5), (.5, .58), (.8, .46), (1.05, .6)]),
                                      ((60, 95, 160), [(-.05, .7), (.3, .6), (.6, .66), (1.05, .58)])]):
        bg = blend(bg, col, ridge_mask(ctrl, .12, 6, i), .85)
    ctrl = [(-.1, .72), (.1, .60), (.24, .48), (.36, .40), (.47, .30), (.53, .36), (.62, .35), (.78, .5), (.95, .6), (1.1, .66)]
    m = ridge_mask(ctrl, .05, 7, 11)
    rgb = grad([(0, (255, 255, 255)), (.4, (225, 238, 252)), (.6, (120, 140, 175)), (.8, (50, 62, 88)), (1, (25, 32, 50))])
    rgb = shade_sides(rgb, m, (.5, .3))
    mist, mc = glow(.5, 1.0, .9, (235, 245, 255), .85)
    rgb = rgb * (1 - mist[..., None]) + mc * mist[..., None]
    finish(bg, rgb, m, 1)

# ---------------------------------------------------------------- 2 City
def city():
    bg = grad([(0, (22, 16, 70)), (.35, (96, 42, 120)), (.55, (230, 110, 110)), (.66, (255, 175, 100)), (1, (60, 30, 80))])
    g, c = glow(.5, .6, .8, (255, 190, 120), .7); bg = bg * (1 - g[..., None]) + c * g[..., None]
    bg = stars(bg, 140, 3, .3)
    rnd = random.Random(5)
    def skyline(n, hmin, hmax, y0=.9):
        x, pts = -.02, []
        while x < 1.05:
            w = rnd.uniform(.05, .11); top = rnd.uniform(hmin, hmax)
            pts += [(x, top), (x + w, top)]; x += w
        return pts
    far = skyline(0, .52, .62); far = [(-.05, 1.02)] + far + [(1.1, 1.02)]
    bg = blend(bg, (120, 70, 120), poly_mask(far), .75)
    # old qatlam: baland binolar
    blds = [(-.02, .13, .55), (.12, .27, .42), (.26, .40, .50), (.39, .55, .31), (.54, .68, .45), (.67, .82, .38), (.81, 1.03, .52)]
    m = mask(lambda d, s: [d.rectangle([s((a, t)), s((b, 1.02))], fill=255) for a, b, t in blds] and
             d.polygon([s((.46, .31)), s((.47, .27)), s((.48, .31))], fill=255))
    rgb = grad([(0, (28, 28, 64)), (.6, (18, 18, 44)), (1, (8, 8, 22))])
    im = Image.fromarray(rgb.astype('uint8')); d = ImageDraw.Draw(im)
    for a, b, t in blds:
        for yy in np.arange(t + .012, .98, .0105):
            for xx in np.arange(a + .008, b - .012, .014):
                if rnd.random() < .42:
                    col = rnd.choice([(255, 210, 120), (255, 235, 170), (140, 200, 255)])
                    d.rectangle([xx * W, yy * H, xx * W + 9, yy * H + 13], fill=col)
    rgb = np.asarray(im, dtype=np.float32)
    finish(bg, rgb, m, 2)

# ---------------------------------------------------------------- 3 Mesa
def mesa():
    bg = grad([(0, (70, 40, 110)), (.3, (200, 90, 110)), (.55, (255, 170, 100)), (.7, (255, 214, 150)), (1, (210, 120, 80))])
    g, c = glow(.7, .56, .5, (255, 240, 190), 1.0); bg = bg * (1 - g[..., None]) + c * g[..., None]
    bg = blend(bg, (170, 90, 100), ridge_mask([(-.05, .66), (.3, .6), (.55, .64), (.85, .58), (1.05, .65)], .05, 6, 2), .8)
    top = [(.06, .50), (.12, .42), (.20, .36), (.34, .335), (.50, .33), (.62, .34), (.72, .40), (.78, .52), (.84, .6)]
    pts = jag(top, .015, 5, 21)
    m_butte = poly_mask([(.04, 1.02)] + pts + [(.9, 1.02)])
    stripes = np.zeros((H, W, 3), dtype=np.float32)
    ys = np.linspace(0, 1, H)[:, None] * np.ones((1, W))
    t = (np.sin(ys * 90) * .5 + .5) * .5 + (np.sin(ys * 23) * .5 + .5) * .5
    stripes = np.array((150, 62, 40)) * (1 - t[..., None]) + np.array((205, 105, 62)) * t[..., None]
    stripes = shade_sides(stripes, m_butte, (.45, .33), amt=.6, tint=(60, 20, 40))
    rgb = blend(stripes, (0, 0, 0), np.zeros((H, W), np.float32), 0)
    m_dune = ridge_mask([(-.05, .86), (.3, .8), (.6, .84), (1.05, .78)], .03, 6, 4)
    dune = grad([(0, (240, 170, 110)), (1, (150, 80, 60))])
    rgb = rgb * (1 - m_dune[..., None]) + dune * m_dune[..., None]
    finish(bg, rgb, np.maximum(m_butte, m_dune), 3)

# ---------------------------------------------------------------- 4 Sea stack
def sea():
    bg = grad([(0, (14, 30, 84)), (.3, (70, 70, 140)), (.52, (250, 150, 110)), (.58, (255, 205, 150)),
               (.6, (90, 90, 140)), (.75, (26, 52, 100)), (1, (10, 26, 56))])
    g, c = glow(.5, .57, .4, (255, 230, 180), .9); bg = bg * (1 - g[..., None]) + c * g[..., None]
    bg = stars(bg, 90, 6, .35)
    im = Image.fromarray(bg.astype('uint8')); d = ImageDraw.Draw(im)
    rnd = random.Random(8)
    for _ in range(260):
        y = rnd.uniform(.61, .98); x = rnd.uniform(0, 1); l = (y - .58) * 400
        d.line([x * W, y * H, x * W + l, y * H], fill=(120, 150, 190) if y > .7 else (255, 200, 150), width=2)
    bg = np.asarray(im.filter(ImageFilter.GaussianBlur(1.2)), dtype=np.float32)
    ctrl = [(.22, 1.02), (.26, .78), (.30, .60), (.36, .46), (.42, .36), (.48, .31), (.56, .33), (.62, .42), (.66, .56), (.70, .75), (.74, 1.02)]
    m = poly_mask(jag(ctrl, .02, 5, 31))
    rgb = grad([(0, (70, 62, 82)), (.5, (38, 34, 50)), (1, (14, 14, 24))])
    rgb = shade_sides(rgb, m, (.48, .31), amt=.5, tint=(10, 10, 30))
    # kichik tosh va ko'pik
    m2 = poly_mask(jag([(-.05, 1.02), (-.02, .86), (.06, .82), (.14, .88), (.2, 1.02)], .02, 5, 33))
    m3 = poly_mask(jag([(.82, 1.02), (.86, .90), (.94, .86), (1.05, .92), (1.05, 1.02)], .02, 5, 34))
    a = np.maximum(m, np.maximum(m2, m3))
    foam = mask(lambda dd, s: [dd.ellipse([s((x - w, y - .008)), s((x + w, y + .012))], fill=255)
                               for x, y, w in [(.48, .97, .30), (.10, .93, .16), (.9, .95, .16), (.5, 1.0, .5)]])
    foam = np.asarray(Image.fromarray((foam * 255).astype('uint8')).filter(ImageFilter.GaussianBlur(10)), dtype=np.float32) / 255 * .85
    rgb = rgb * (1 - foam[..., None]) + np.array((235, 245, 255)) * foam[..., None]
    finish(bg, rgb, np.maximum(a, foam), 4)

# ---------------------------------------------------------------- 5 Pines + aurora
def tree(d, s, cx, base, h, w, tiers=8):
    top = base - h; R = [(cx, top)]; L = []
    for i in range(1, tiers + 1):
        y = top + h * i / tiers; wi = w / 2 * (i / tiers)
        R += [(cx + wi, y), (cx + wi * .5, y)]; L += [(cx - wi, y), (cx - wi * .5, y)]
    pts = R + [(cx + w * .03, base + .01), (cx - w * .03, base + .01)] + L[::-1]
    d.polygon([s(p) for p in pts], fill=255)

def forest():
    bg = grad([(0, (4, 8, 28)), (.4, (8, 30, 52)), (.7, (14, 60, 70)), (1, (6, 20, 28))])
    ys, xs = np.mgrid[0:H, 0:W]
    band = np.zeros((H, W), np.float32)
    for k, (amp, ph, y0, wd) in enumerate([(.07, 0, .28, .09), (.05, 2, .36, .07)]):
        cy = (y0 + amp * np.sin(xs / W * 5 + ph)) * H
        band += np.exp(-((ys - cy) / (wd * H)) ** 2)
    band = np.asarray(Image.fromarray((np.clip(band, 0, 1) * 255).astype('uint8')).filter(ImageFilter.GaussianBlur(28)), dtype=np.float32) / 255
    green = np.array((60, 255, 150)); purple = np.array((150, 80, 255))
    mixc = green * (1 - (ys / H)[..., None]) + purple * (ys / H)[..., None] * .8
    bg = bg + mixc * band[..., None] * .75
    bg = stars(np.clip(bg, 0, 255), 200, 9, .4)
    rnd = random.Random(12)
    far = mask(lambda d, s: [tree(d, s, rnd.uniform(0, 1), .86, rnd.uniform(.12, .2), .07) for _ in range(26)])
    bg = blend(bg, (8, 34, 40), far, .9)
    spec = [(.50, .86, .55, .17), (.20, .90, .38, .14), (.80, .90, .42, .15), (.05, .95, .28, .12),
            (.95, .95, .30, .12), (.34, .96, .24, .11), (.68, .97, .22, .10)]
    m = mask(lambda d, s: ([tree(d, s, cx, base, h, w) for cx, base, h, w in spec] +
                           [d.polygon([s((-.05, 1.02)), s((-.05, .93)), s((.5, .9)), s((1.05, .93)), s((1.05, 1.02))], fill=255)]))
    rgb = grad([(0, (14, 40, 48)), (.5, (8, 22, 30)), (1, (3, 8, 12))])
    finish(bg, rgb, m, 5)

if __name__ == '__main__':
    for f in (alps, city, mesa, sea, forest):
        f(); print('ok', f.__name__)
