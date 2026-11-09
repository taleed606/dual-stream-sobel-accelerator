# Dual-Stream Sobel Edge Detection Accelerator (SystemVerilog RTL)

Advanced Computer Architecture research project.

**Authors:**
- Taleed Hamadneh
- Qasim Batrawi

A hardware edge detector built as a pipeline. It takes one RGB pixel per clock
for each stream. Two copies of the pipeline run side by side: one handles the
upper half of the image and the other handles the lower half, so the
throughput is doubled.

## Pipeline stages
1. **RGB_to_grayscale** – turns 24-bit RGB into 8-bit gray
2. **Fetch_Stage** – uses line buffers to build a sliding 3×3 window (256×256 image)
3. **Convolution_Stage** – computes the Sobel Gx and Gy kernels
4. **Absolute_Stage** – takes |Gx| and |Gy|
5. **Magnitude_Stage** – adds them: |Gx| + |Gy|
6. **Thresholding_Stage** – outputs a binary edge map

Top modules: `Top_One_Wide` (one stream), `Top_Two_Wide` (two parallel streams), plus a testbench.

## Python tools
- `image-to-file.py` – converts an image into the `.mem` file the simulation reads
- `file-to-image.py` – rebuilds the output image from the simulation's result files
- `sobel_algorithm.py` – the reference version in software (OpenCV)
- `compare.py` – compares the hardware output with the software output
