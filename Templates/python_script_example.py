#!/usr/bin/env python3
# Path: ~/Templates/python_script_example.py
# -*- coding: utf-8 -*-

"""
This script accepts a string as a command-line argument and prints it out.
"""

# Import necessary standard Python libraries
import os

# Import argparse for command line arguments
import argparse


def print_arg(arg):
    """
    Prints the passed argument to the console.
    """
    print(f"The passed argument is: {arg}")


def main(args):
    """
    Prints the passed argument by calling the print_arg function with the
    received argument
    """
    HOME = os.getenv("HOME")
    assert HOME, "The HOME environment variable is not set"
    print(f"$HOME: {HOME}")
    print_arg(args.argument)


def parse_args():
    """
    Parse command line arguments
    """
    parser = argparse.ArgumentParser(description="Display user-supplied string")
    parser.add_argument(
        "--argument", type=str, help="Enter a string you want to display"
    )
    args = parser.parse_args()
    return args


if __name__ == "__main__":

    args = parse_args()

    main(args)
