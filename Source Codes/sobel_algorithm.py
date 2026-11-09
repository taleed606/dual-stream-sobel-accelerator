import cv2
import numpy as np
import matplotlib.pyplot as plt

def sobel_edge_detector(image_path):
    # Read the image using OpenCV
    image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    # Apply Sobel operator
    sobel_x = cv2.Sobel(image, cv2.CV_64F, 1, 0, ksize=3)
    sobel_y = cv2.Sobel(image, cv2.CV_64F, 0, 1, ksize=3)

    # Calculate gradient magnitude
    magnitude = np.abs(sobel_x) + np.abs(sobel_y) # we can change it to |sobel_x| + |sobel_y|

    threshold = 300
    magnitude = magnitude > threshold

    return magnitude

# Example usage
edge_image = sobel_edge_detector("./input_image/img_input.png")

# Display the original and edge-detected images
original_image = cv2.imread("./input_image/img_input.png")
original_image_rgb = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)

mag = edge_image.astype(np.float32)
mag_norm = cv2.normalize(mag, None, 0, 255, cv2.NORM_MINMAX)
mag_norm = mag_norm.astype(np.uint8)

cv2.imwrite("./compare/software_output.png", mag_norm)
cv2.imwrite("./output_image/software_output.png", mag_norm)
# Plotting the images using matplotlib
plt.figure(figsize=(10, 5))

# Original Image
plt.subplot(1, 2, 1)
plt.imshow(original_image_rgb)
plt.title('Original Image')
plt.axis('off')

# Edge-detected Image
plt.subplot(1, 2, 2)
plt.imshow(edge_image, cmap='gray')
plt.title('Edge-detected Image (Sobel)')
plt.axis('off')

# Display the images
plt.show()