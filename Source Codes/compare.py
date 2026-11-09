import os
import cv2
import math
import numpy as np
import logging
from typing import List, Dict

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


# -------------------------
# Helpers
# -------------------------

def _assert_image_shapes_equal(a: np.ndarray, b: np.ndarray, metric: str):
    if a.shape != b.shape:
        raise ValueError(
            f"Cannot calculate {metric}. Input shapes not identical. "
            f"img1 shape={a.shape}, img2 shape={b.shape}"
        )

def read_gray(path: str) -> np.ndarray:
    """Read image as grayscale (2D uint8)."""
    img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        raise FileNotFoundError(f"Cannot read image: {path}")
    return img

def center_crop_to_match(a: np.ndarray, b: np.ndarray):
    """If shapes differ, center-crop both to the smallest common HxW."""
    h = min(a.shape[0], b.shape[0])
    w = min(a.shape[1], b.shape[1])

    def crop(img):
        y0 = (img.shape[0] - h) // 2
        x0 = (img.shape[1] - w) // 2
        return img[y0:y0+h, x0:x0+w]

    return crop(a), crop(b)

def crop_border(img: np.ndarray, border: int) -> np.ndarray:
    """Remove border pixels (useful if your pipeline drops edges)."""
    if border <= 0:
        return img
    if img.shape[0] <= 2 * border or img.shape[1] <= 2 * border:
        raise ValueError("Border crop too large for the image size.")
    return img[border:-border, border:-border]


# -------------------------
# Metrics (difference-based)
# -------------------------

def mse(a: np.ndarray, b: np.ndarray) -> float:
    _assert_image_shapes_equal(a, b, "MSE")
    # float32 prevents uint8 wrap-around
    af = a.astype(np.float32)
    bf = b.astype(np.float32)
    return float(np.mean((af - bf) ** 2))

def psnr(a: np.ndarray, b: np.ndarray, max_p: float = 255.0) -> float:
    _assert_image_shapes_equal(a, b, "PSNR")
    m = mse(a, b)
    if m == 0:
        return float("inf")
    return 10.0 * math.log10((max_p ** 2) / m)

# Optional: SSIM-like measure without skimage (global SSIM, not windowed)
# NOTE: For original-vs-edge, SSIM is generally not meaningful, but provided if needed.
def ssim_global(a: np.ndarray, b: np.ndarray, max_p: float = 255.0) -> float:
    _assert_image_shapes_equal(a, b, "SSIM")
    x = a.astype(np.float32)
    y = b.astype(np.float32)

    mu_x = x.mean()
    mu_y = y.mean()
    var_x = x.var()
    var_y = y.var()
    cov_xy = ((x - mu_x) * (y - mu_y)).mean()

    C1 = (0.01 * max_p) ** 2
    C2 = (0.03 * max_p) ** 2

    num = (2 * mu_x * mu_y + C1) * (2 * cov_xy + C2)
    den = (mu_x**2 + mu_y**2 + C1) * (var_x + var_y + C2)
    return float(num / den)


metric_functions = {
    "mse": mse,
    "psnr": psnr,
    "ssim": ssim_global,  # optional; remove if you don't want it
}


# -------------------------
# Evaluation
# -------------------------

def evaluation(original_path: str,
               edge_path: str,
               metrics: List[str],
               border: int = 0,
               auto_crop: bool = True) -> Dict[str, float]:

    orig = read_gray(original_path)
    edge = read_gray(edge_path)

    # If sizes differ (common in hardware), crop to match
    if auto_crop and orig.shape != edge.shape:
        logger.info(f"Shape mismatch: orig={orig.shape}, edge={edge.shape}. Center-cropping to match.")
        orig, edge = center_crop_to_match(orig, edge)

    # Optional border removal (use if your edge output is invalid at boundaries)
    orig = crop_border(orig, border)
    edge = crop_border(edge, border)

    # Final strict check
    _assert_image_shapes_equal(orig, edge, "Metrics")

    results = {}
    for m in metrics:
        if m not in metric_functions:
            raise ValueError(f"Unknown metric: {m}. Choose from {list(metric_functions.keys())}")
        results[m] = float(metric_functions[m](orig, edge))
        logger.info(f"{m.upper()} = {results[m]}")
    return results


def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))

    # ORIGINAL input image (before Sobel)
    original_path = os.path.join(base_dir, "./compare/true_value.png")

    # EDGE output image (Python Sobel or Verilog Sobel output)
    edge_path = os.path.join(base_dir, "./compare/img_output.png")

    metrics = ["mse", "psnr"]  # add "ssim" only if you really need it

    results = evaluation(
        original_path=original_path,
        edge_path=edge_path,
        metrics=metrics,
        border=0,        # set to 1 if you want to ignore borders
        auto_crop=True
    )

    print("\n=== ORIGINAL vs EDGE (Difference-Based) ===")
    print(f"MSE  : {results['mse']:.4f}")
    print(f"PSNR : {results['psnr']:.4f} dB")


if __name__ == "__main__":
    main()
