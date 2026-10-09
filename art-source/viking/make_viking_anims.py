import json, base64, io, os, sys
from PIL import Image, ImageDraw
from collections import Counter

# Builds the Viking run and attack sheets from the hand-drawn idle sprite.
#   python make_viking_anims.py
# Reads  ../../vaporwave-vikings-idle/assets/sprites/viking/viking_idle.png
# Writes sheets next to it, .piskel files here, previews to ../previews, debug parts to ./_debug
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
ASSETS = os.path.join(ROOT, 'vaporwave-vikings-idle', 'assets', 'sprites', 'viking')
PREVIEWS = os.path.join(HERE, '..', 'previews')
DEBUG = os.path.join(HERE, '_debug')
SRC = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ASSETS, 'viking_idle.png')
for d in (ASSETS, PREVIEWS, DEBUG): os.makedirs(d, exist_ok=True)
W = H = 64

SKIN = {(195,167,156),(235,200,167),(156,128,126),(237,213,202),(150,108,108),(123,98,104)}
OUTLINE = {(46,34,47),(34,28,26)}
SHAFT = {(155,171,178),(139,147,175),(179,185,209),(76,62,36)}
AXE_DARK = {(34,28,26),(74,84,98),(62,53,70)}
LSLEEVE = {(92,66,85)}
RSLEEVE = {(69,46,63),(66,36,51)}

def poly_mask(poly):
    m = Image.new('1', (W, H), 0)
    ImageDraw.Draw(m).polygon(poly, fill=1)
    return m.load()

def extract(im, fn):
    part = Image.new('RGBA', (W, H), (0,0,0,0))
    rest = im.copy()
    pp, pr, src = part.load(), rest.load(), im.load()
    for y in range(H):
        for x in range(W):
            p = src[x, y]
            if p[3] and fn(x, y, p[:3]):
                pp[x, y] = p; pr[x, y] = (0,0,0,0)
    return part, rest

def neighbours(x, y, r=1):
    for dx in range(-r, r+1):
        for dy in range(-r, r+1):
            if (dx or dy) and 0 <= x+dx < W and 0 <= y+dy < H:
                yield x+dx, y+dy

def inpaint(im, holes, fill_cols=None):
    px = im.load(); holes = set(holes)
    for _ in range(12):
        if not holes: break
        new = {}
        for (x, y) in holes:
            c = Counter()
            for nx, ny in neighbours(x, y):
                if (nx, ny) not in holes:
                    q = px[nx, ny]
                    if q[3] and (fill_cols is None or q[:3] in fill_cols): c[q] += 1
            if c: new[(x, y)] = c.most_common(1)[0][0]
        for k, v in new.items(): px[k] = v
        holes -= set(new)
    return im

def split(im):
    orig = im.load()
    # axe: shaft (light greys + grip wrap) and head (darks) inside polygon
    ap = poly_mask([(20,34),(31,33),(38,38),(63,39),(63,58),(45,58),(43,50),(36,44),(20,40)])
    def is_axe(x, y, c):
        if not ap[x, y]: return False
        if c in SHAFT: return True
        if c in AXE_DARK and x >= 36: return True
        if c == (74,84,98) and x >= 36: return True
        return False
    axe, rest = extract(im, is_axe)
    holes = [(x,y) for y in range(33,46) for x in range(20,40) if ap[x,y] and rest.getpixel((x,y))[3]==0 and orig[x,y][3]]
    rest = inpaint(rest, holes, {(69,46,63),(66,36,51),(46,34,47),(103,102,51),(179,165,85)})

    # hands
    lp = poly_mask([(11,31),(22,31),(23,42),(12,42)])
    rp = poly_mask([(31,32),(41,32),(41,39),(31,39)])
    def is_hand(x, y, c):
        if c in SKIN and (lp[x,y] or rp[x,y]): return True
        if c in OUTLINE and (lp[x,y] or rp[x,y]):
            return any(orig[nx,ny][:3] in SKIN for nx,ny in neighbours(x,y))
        return False
    hands, rest = extract(rest, is_hand)
    # left sleeve (lighter purple) + its outline
    sp = poly_mask([(7,25),(17,25),(17,34),(7,37)])
    def is_lsleeve(x, y, c):
        if not sp[x,y]: return False
        if c in LSLEEVE: return True
        if c in OUTLINE: return any(orig[nx,ny][:3] in LSLEEVE for nx,ny in neighbours(x,y))
        return False
    lsleeve, rest = extract(rest, is_lsleeve)
    # right sleeve: the shaded column on the viewer-right arm
    rsp = poly_mask([(32,24),(38,24),(39,33),(31,33)])
    def is_rsleeve(x, y, c):
        if not rsp[x,y]: return False
        return c in RSLEEVE or (c in OUTLINE and x >= 35)
    rsleeve, rest = extract(rest, is_rsleeve)
    # fill torso behind the arms with tunic so the silhouette stays solid when arms move
    holes = [(x,y) for y in range(24,42) for x in range(7,40) if rest.getpixel((x,y))[3]==0 and orig[x,y][3]]
    rest = inpaint(rest, holes, {(69,46,63),(66,36,51),(57,41,69)})
    # re-outline the filled area where it meets transparency
    px = rest.load()
    for (x,y) in holes:
        if px[x,y][3] and any((not (0<=nx<W and 0<=ny<H)) or px[nx,ny][3]==0 for nx,ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]):
            px[x,y] = (46,34,47,255)

    leg_l, rest = extract(rest, lambda x,y,c: y >= 47 and x < 26)
    leg_r, rest = extract(rest, lambda x,y,c: y >= 47 and x >= 26)
    return {'body': rest, 'leg_l': leg_l, 'leg_r': leg_r, 'lsleeve': lsleeve, 'rsleeve': rsleeve, 'hands': hands, 'axe': axe}

def xf(layer, angle=0, pivot=(32,32), dx=0, dy=0):
    """rotate (deg, CCW positive) about pivot, then translate. Nearest-neighbour so pixels stay crisp."""
    out = layer
    if angle:
        out = out.rotate(angle, resample=Image.NEAREST, center=pivot)
    if dx or dy:
        out = out.transform((W,H), Image.AFFINE, (1,0,-dx,0,1,-dy), resample=Image.NEAREST)
    return out

def compose(layers):
    f = Image.new('RGBA', (W,H), (0,0,0,0))
    for l in layers: f.alpha_composite(l)
    return f

def merge(*layers):
    return compose(layers)

# ---------------- animations ----------------
def run_frames(P):
    frames = []
    n = 8
    # leg swing angles (deg) over one cycle; +ve = foot forward (to the right)
    swing = [36, 18, -2, -22, -36, -18, 2, 22]
    bob =   [0, -1, -2, -1, 0, -1, -2, -1]
    hipL, hipR = (18,46), (32,46)
    arms = merge(P['lsleeve'], P['rsleeve'], P['hands'], P['axe'])
    for i in range(n):
        a = swing[i]; b = swing[(i+4) % n]
        # lift the leg that is swinging forward (recovery) by tucking it up a pixel
        liftL = -2 if 0 < a < 20 and swing[(i-1)%n] < a else 0
        liftR = -2 if 0 < b < 20 and swing[(i-1+4)%n] < b else 0
        lean = 1  # constant slight forward lean of the upper body
        ll = xf(P['leg_l'], a, hipL, 0, bob[i] + liftL)
        lr = xf(P['leg_r'], b, hipR, 0, bob[i] + liftR)
        body = xf(P['body'], 0, dx=lean, dy=bob[i])
        ar = xf(arms, 6 - 2*(i%4), (34,28), lean, bob[i])  # small axe bounce
        frames.append(compose([lr, ll, body, ar]) if a < b else compose([ll, lr, body, ar]))
    return frames

def limb(a, b, col, outline=(46,34,47), L1=9, L2=10):
    """two-bone arm shoulder a -> elbow -> hand b, elbow solved so it hangs back/down"""
    import math
    ax, ay = a; bx, by = b
    d = math.hypot(bx-ax, by-ay)
    if d < 1: d = 1
    ux, uy = (bx-ax)/d, (by-ay)/d
    dd = min(d, L1+L2-0.5)
    p = (L1*L1 - L2*L2 + dd*dd) / (2*dd)
    h = math.sqrt(max(L1*L1 - p*p, 0))
    c1 = (ax + ux*p - uy*h, ay + uy*p + ux*h)
    c2 = (ax + ux*p + uy*h, ay + uy*p - ux*h)
    e = max((c1, c2), key=lambda c: c[1] - 0.3*c[0])   # elbow hangs down, slightly back
    e = (max(round(e[0]), ax - 1), round(e[1]))         # never outside the torso line
    l = Image.new('RGBA', (W,H), (0,0,0,0)); dr = ImageDraw.Draw(l)
    for w, c in ((6, outline), (4, col)):
        dr.line([a, e], fill=c+(255,), width=w); dr.line([e, b], fill=c+(255,), width=w-1)
        r = w//2 - 1
        for q in (a, e):
            dr.ellipse((q[0]-r, q[1]-r, q[0]+r, q[1]+r), fill=c+(255,))
    return l

def attack_frames(P):
    import math
    frames = []
    G0 = (36, 37)
    #            idle    lift     wind     wind     hold     hold     mid      strike   impact   impact   recov    recov
    grip   = [(36,37), (38,34), (41,29), (43,26), (43,25), (43,25), (39,27), (35,30), (38,36), (38,36), (37,37), (36,37)]
    angles = [0,       45,      95,      115,     120,     120,     80,      35,      -22,     -22,     -12,     -5]
    leanx  = [0,       -1,      -2,      -2,      -2,      -2,      0,       2,       3,       3,       1,       0]
    leany  = [0,       0,       -1,      -1,      -1,      -1,      0,       0,       1,       1,       0,       0]
    legL   = [0,       0,       3,       4,       4,       4,       0,       -5,      -6,      -6,      -3,      0]
    legR   = [0,       0,       -3,      -4,      -4,      -4,      0,       6,       8,       8,       4,       0]
    arc    = 7
    LH_REF, RH_REF = (17, 37), (36, 36)
    SH_L, SH_R = (12, 27), (39, 27)
    BUTT = (-15, -1)
    hp = P['hands'].load()
    hl = Image.new('RGBA',(W,H)); hr = Image.new('RGBA',(W,H)); pl, pr = hl.load(), hr.load()
    for y in range(H):
        for x in range(W):
            if hp[x,y][3]: (pl if x < 27 else pr)[x,y] = hp[x,y]
    def rot(v, a):
        t = math.radians(a); return (v[0]*math.cos(t)+v[1]*math.sin(t), -v[0]*math.sin(t)+v[1]*math.cos(t))
    for i, ang in enumerate(angles):
        dx, dy = leanx[i], leany[i]
        legs = [xf(P['leg_l'], legL[i], (18,46)), xf(P['leg_r'], legR[i], (32,46))]
        if i == 0 or i == len(angles)-1 and ang == 0:
            frames.append(compose(legs + [P['body'], P['lsleeve'], P['rsleeve'], P['axe'], P['hands']]))
            continue
        G = (grip[i][0]+dx, grip[i][1]+dy)
        body = xf(P['body'], 0, dx=dx, dy=dy)
        axe = xf(P['axe'], ang, G0, G[0]-G0[0], G[1]-G0[1])
        rh = xf(hr, 0, dx=G[0]-RH_REF[0], dy=G[1]-RH_REF[1])
        # hands spaced like the idle grip when the axe is low; they slide together for the overhead windup
        t = min(max((abs(ang) - 45) / 75, 0), 1)
        d = 17*(1-t) + 7*t
        bx, by = rot(BUTT, ang); n = math.hypot(bx, by)
        tx, ty = round(G[0] + bx/n*d), round(G[1] + by/n*d)
        lh = xf(hl, 0, dx=tx-LH_REF[0], dy=ty-LH_REF[1])
        shl, shr = (SH_L[0]+dx, SH_L[1]+dy), (SH_R[0]+dx, SH_R[1]+dy)
        larm = limb(shl, (tx,ty), (92,66,85)); rarm = limb(shr, G, (69,46,63))
        far_behind = ang > 90
        order = legs + ([larm, lh, body, axe, rarm, rh] if far_behind else [body, larm, axe, lh, rarm, rh])
        f = compose(order)
        if i == arc:
            ov = Image.new('RGBA', (W,H), (0,0,0,0)); R = 26
            ImageDraw.Draw(ov).arc((G[0]-R, G[1]-R, G[0]+R, G[1]+R), 230, 350, fill=(210,220,245,120), width=2)
            ImageDraw.Draw(ov).arc((G[0]-R+3, G[1]-R+3, G[0]+R-3, G[1]+R-3), 245, 345, fill=(210,220,245,60), width=1)
            fp, op = f.load(), ov.load()
            for y in range(H):
                for x in range(W):
                    if op[x,y][3] and not fp[x,y][3]: fp[x,y] = op[x,y]
        frames.append(f)
    return frames

# ---------------- output ----------------
def sheet(frames):
    s = Image.new('RGBA', (W*len(frames), H), (0,0,0,0))
    for i, f in enumerate(frames): s.paste(f, (i*W, 0))
    return s

def piskel(name, frames, fps):
    strip = sheet(frames)
    buf = io.BytesIO(); strip.save(buf, 'PNG')
    b64 = 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()
    layer = {"name": "Layer 1", "opacity": 1, "frameCount": len(frames),
             "chunks": [{"layout": [[i] for i in range(len(frames))], "base64PNG": b64}]}
    doc = {"modelVersion": 2, "piskel": {"name": name, "description": "generated from viking_idle.png by make_viking_anims.py",
           "fps": fps, "height": H, "width": W, "layers": [json.dumps(layer)]}}
    return json.dumps(doc)

def preview(frames, path, fps, scale=4):
    big = [f.resize((W*scale, H*scale), Image.NEAREST) for f in frames]
    bg = []
    for b in big:
        c = Image.new('RGBA', b.size, (24, 16, 40, 255)); c.alpha_composite(b); bg.append(c.convert('P', palette=Image.ADAPTIVE))
    bg[0].save(path, save_all=True, append_images=bg[1:], duration=int(1000/fps), loop=0, disposal=2)

if __name__ == '__main__':
    im = Image.open(SRC).convert('RGBA')
    P = split(im)
    for k, v in P.items(): v.save(f'{DEBUG}/part_{k}.png')
    run = run_frames(P); atk = attack_frames(P)
    sheet(run).save(f'{ASSETS}/viking_run.png')
    sheet(atk).save(f'{ASSETS}/viking_attack.png')
    open(f'{HERE}/viking_run.piskel', 'w').write(piskel('viking_run', run, 12))
    open(f'{HERE}/viking_attack.piskel', 'w').write(piskel('viking_attack', atk, 12))
    preview(run, f'{PREVIEWS}/viking_run.gif', 12)
    preview(atk, f'{PREVIEWS}/viking_attack.gif', 12)
    # contact sheets for inspection
    for nm, fr in (('run', run), ('attack', atk)):
        sheet(fr).resize((W*len(fr)*4, H*4), Image.NEAREST).save(f'{DEBUG}/contact_{nm}.png')
    print('ok')
