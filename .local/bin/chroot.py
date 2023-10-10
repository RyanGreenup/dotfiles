#!/usr/bin/python

import sys
import os


class chroot_fs:
    def __init__(self, dir):
        self.kernel_dirs = {
            "proc": "proc",
            "sys":  "sysfs"
        }
        self.tempfs_dirs = ["dev", "dev/pts", "dev/shm", "run", "tmp"]
        self.location = dir

    def mount(self):
        auth = "doas"
        for dir, t in self.kernel_dirs.items():
            print(f"[on] {dir} .........", end='')
            c = f"{auth} mount --mkdir -t {t} none {self.location}/{dir}"
            if os.system(c) == 0:
                print("[DONE]")
            else:
                print("[----]")
        for dir in self.tempfs_dirs:
            print(f"[on] {dir} .........", end='')
            c = f"{auth} mount --mkdir --rbind /{dir} {self.location}/{dir}"
            if os.system(c) == 0:
                print("[DONE]")
            else:
                print("[----]")

    def umount(self):
        auth = "doas"

        dirs = list(self.kernel_dirs.keys()) + self.tempfs_dirs

        for dir in dirs:
            print(f"[off] {dir} .........", end='')
            d = f"{self.location}/{dir}"
            if os.system(f"{auth} umount -l {d}") == 0:
                print("[DONE]")
            else:
                print("[----]")

    def enter(self):
        os.system(f"doas chroot {self.location}")


def main():
    if len(sys.argv) != 2:
        help()
        sys.exit("ERROR: Incorrect Number of Arguments")
    dir = sys.argv[1]

    enter_chroot(dir)

    sys.exit()


def enter_chroot(dir: str):
    chroot = chroot_fs(dir)
    chroot.mount()
    chroot.enter()
    chroot.umount()

    sys.exit()


def help():
    print("""
          Enter a chroot environment by mounting directories and opening a
          shell the script will unmount the directories before returning.
          ---

          USAGE:
          ---

              """ + sys.argv[0] + """ [DIR]

          ---
          [DIR] : Directory containing the chroot environment
          """)


if __name__ == '__main__':
    main()
