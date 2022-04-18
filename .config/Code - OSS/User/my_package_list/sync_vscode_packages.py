#!/usr/bin/python3

import sys
import os

package_list = "code_packages.txt"

def main():
    if len(sys.argv) != 2:
        help_page()
    elif sys.argv[1] == "-w" or sys.argv[1] == "--write":
        os.system("code --list-extensions > "+package_list)
    elif sys.argv[1] == "-i" or sys.argv[1] == "--install":
        try:
            with open(package_list) as f:
                for package in f:
                    os.system("code --install-extension "+package)
        except FileNotFoundError:
            print("The file "+package_list+" does not exist")
            print("Create one with:\n\t "+sys.argv[0]+" -w")
    else:
        help_page()

def help_page():
    print("Usage: ", sys.argv[0], " [OPTION]")
    print("\n")
    print("  -w  --write     Write installed apm packages to atomPackages.txt")
    print("  -i  --install   Install packages saved in atomPackages.txt")
    print("\n")

main()



