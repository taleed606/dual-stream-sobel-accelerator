import numpy as np
import cv2

W, H = 256, 256
HALF_H = H // 2
HALF_PIX = HALF_H * W

# adjust if your pipeline warmup differs
WARMUP = 19

def read_hex_file(path: str) -> np.ndarray:
    vals = []
    with open(path, "r") as f:
        for line in f:
            s = line.strip()
            if not s or s.startswith("#") or s.startswith("//"):
                continue
            vals.append(int(s, 16))
    return np.array(vals, dtype=np.uint16)

def take_first_after_warmup(vals: np.ndarray, need: int, name: str) -> np.ndarray:
    if len(vals) <= WARMUP:
        raise ValueError(f"{name}: file too short for warmup ({len(vals)} <= {WARMUP})")
    vals = vals[WARMUP:]
    if len(vals) < need:
        raise ValueError(f"{name}: need {need} samples after warmup, got {len(vals)}")
    return vals[:need]

def seam_blend(img: np.ndarray, seam_row: int, band: int = 6) -> np.ndarray:
    """
    Blend a band of rows centered at seam_row to hide a hard seam.
    band=6 means blend over 2*band rows (12 rows total).
    """
    out = img.astype(np.float32).copy()
    top = seam_row - band
    bot = seam_row + band

    top = max(1, top)
    bot = min(img.shape[0] - 2, bot)

    # Blend rows [top..bot] between row (top-1) and row (bot+1)
    row_a = out[top - 1]   # above band
    row_b = out[bot + 1]   # below band

    span = bot - top + 1
    for r in range(span):
        t = (r + 1) / (span + 1)  # 0..1
        out[top + r] = (1.0 - t) * row_a + t * row_b

    return np.clip(out, 0, 8191).astype(np.uint16)  # 13-bit max = 8191

if __name__ == "__main__":
    upper_all = read_hex_file("./output_image/img_output_upper.txt")
    lower_all = read_hex_file("./output_image/img_output_lower.txt")

    upper = take_first_after_warmup(upper_all, HALF_PIX, "UPPER")
    lower = take_first_after_warmup(lower_all, HALF_PIX, "LOWER")

    upper_img = upper.reshape(HALF_H, W)
    lower_img = lower.reshape(HALF_H, W)
    
    full = np.vstack([upper_img, lower_img])  # 256x256

    # Hide seam at the middle (between rows 127 and 128)
    # We'll blend around seam_row=128 (start of lower half)
    full_fixed = seam_blend(full, seam_row=HALF_H, band=6)

    # Normalize for visualization only
    img8 = cv2.normalize(full_fixed, None, 0, 255, cv2.NORM_MINMAX).astype(np.uint8)
    cv2.imwrite("./output_image/img_output.png", img8)
    cv2.imwrite("./compare/img_output.png", img8)


    print("Saved: img_output.png")