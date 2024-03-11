#!/usr/bin/env python
import os
import time
from subprocess import run, PIPE

dirs = [
    "Notes",
    "Agenda",
    "Sync",
    "Studies",
    "Sync-Current",
    "Sync-Current-rsync"
    #            "Applications/Docker/mediawiki",
    #            "Applications/AppImages",
]


def main():
    for comp in ["vale", "vidar"]:
        heading_1(comp)
        for dir in dirs:
            heading_2(dir)
            t = time.asctime(time.localtime(time.time()))
            # cmd = str(f"/usr/bin/unison ssh://{comp}/{dir} \t ~/{dir}")
            # status = os.system(cmd)
            cmd = ["unison", f"ssh://{comp}/{dir}", f"{dir}"]
            p = run(cmd, stdout=PIPE)
            status = p.returncode
            # Get the exit status of the command
            if status == 0:
                log_to_tmp(f"{t}: \t {cmd} \t OK \n")
            else:
                log_to_tmp(f"{t}: \t {cmd} \t FAILED status: {status} \n")


def heading_1(s: str):
    print(
        f"""

    {'=' * 20}

    {s}

    {'=' * 20}

    """
    )


def heading_2(s: str):
    print(
        f"""

    {'-' * 20}

    {s}

    {'-' * 20}

    """
    )


def log_to_tmp(s: str):
    with open("/tmp/unison_sync.log", "a") as f:
        f.write(s)


if __name__ == "__main__":
    main()
