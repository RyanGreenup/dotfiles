#!/usr/bin/env python3
# /home/ryan/.local/scripts/python/wm__image-save.py

"""
This script takes an image from the clipboard and:

    1. Saves it under the given directory (sys.argv[1]), with
        - filename as the current datetime
        - file format as the clipboard image format detected by Pillow
    2. Prints a markdown link to the saved image file
"""

from PIL import ImageGrab, Image

import argparse
import clipboard
from PIL import Image
import io
from datetime import datetime
import os


def main(dir: str, filename: str | None = None):
    # Try to get any type of image data from clipboard
    image = ImageGrab.grabclipboard()
    img_format = image.format.lower()
    assert img_format, "Image format not found"

    # create filename from current datetime
    if filename:
        filename = filename.strip()
        if not filename.endswith(f".{img_format}"):
            filename = f"{filename}.{img_format}"
        filename = os.path.join(dir, filename)
    else:
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        filename = os.path.join(dir, f"{timestamp}.{img_format}")

    # save image to file
    image.save(filename)
    print(f"![{filename}]({filename})")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Script to save image from clipboard.")
    parser.add_argument("filepath", type=str, help="Path to save the image.")
    parser.add_argument(
        "--filename",
        "-f",
        type=str,
        default=None,
        help="File Name. Default is current datetime.",
    )
    args = parser.parse_args()

    main(args.filepath, args.filename)
