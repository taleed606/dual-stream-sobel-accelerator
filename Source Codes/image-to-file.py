import cv2
import numpy as np


img = cv2.imread("./input_image/img_input.png", cv2.IMREAD_COLOR) # BGR

img = cv2.resize(img, (256, 256), interpolation=cv2.INTER_AREA) # rescale

cv2.imwrite(
    "./input_image/img_input.png", img  # OpenCV expects BGR
)
cv2.imwrite(
    "./compare/true_value.png", img
)

Height, Width, Depth = img.shape

# save the RGB image into a .mem file to read it using verilog (each line in this file is 1 pixel (1 byte))
rgb_flat = img.reshape(-1, 3)

# each line in the file is one pixel (3 bytes (RGB))
with open("./input_image/img_input.mem", "w") as f:
    for r, g, b in rgb_flat:
        f.write(f"{r:02X}{g:02X}{b:02X}\n")


print("Size:", Width, "x", Height)