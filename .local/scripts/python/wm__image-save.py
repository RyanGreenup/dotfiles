#!/usr/bin/env python3
# /home/ryan/.local/scripts/python/wm__image-save.py

import argparse
import clipboard
from PIL import Image
import io
from datetime import datetime
import os


def main():
    parser = argparse.ArgumentParser(description="Script to save image from clipboard.")
    parser.add_argument("filepath", type=str, help="Path to save the image.")
    args = parser.parse_args()

    image_data = clipboard.paste("image/png")
    if image_data is None:
        print("No image data found on clipboard")
    else:
        image = Image.open(io.BytesIO(image_data))

        # create filename from current datetime
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        filename = os.path.join(args.filepath, f"{timestamp}.png")

        # save image to file
        image.save(filename)
        print(f"Saved image to {filename}")


if __name__ == "__main__":
    main()
