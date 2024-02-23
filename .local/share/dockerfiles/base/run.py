#!/usr/bin/env python
# This script walks through a tree of Dockerfiles and builds them
# It is assumed the script lies at the root of that tree.
# The script walks through the tree to collect the dockerfiles, sorts them
# by heirarchy and then builds them.
# The path relative to the script becomes the name of the image and distrobox
#
# The logic is basically:
#
#  podman build --layers -t $image_name . &&\
# 	 toolbox create -c $cont_name -i $image_name $toolbox_name
#
#  podman build --layers -t $image_name . &&\
# 	 distrobox create -c $cont_name -i $image_name $toolbox_name
#
# Although I have simply put `distrobox create -i $image_name.
#
# NOTE how is distrobox turning an image into a container? I think:
# Is it using tail -f /dev/null

import os
import sys
from subprocess import run
import re

# change directory to script location (Assume this is the bottom of the tree)
dockerfiles_path = os.path.dirname(os.path.realpath(__file__))
os.chdir(dockerfiles_path)


# Helper functions for class
def camel_to_snake(name):
    name = re.sub("(.)([A-Z][a-z]+)", r"\1_\2", name)
    return re.sub("([a-z0-9])([A-Z])", r"\1_\2", name).lower()


def snake_to_camel(snake_str):
    components = snake_str.split("_")
    return "".join(x.title() for x in components)


# Class to represent the Dockerfile and directory


class Container:
    def __init__(self, abspath, container_manager="podman"):
        self.full_path = abspath
        self.image_built = False
        self.image_name = os.path.relpath(self.full_path, dockerfiles_path)
        self.container_manager = container_manager
        # NOTE separate container name was too tricky with /'s
        # self.container_name = snake_to_camel(self.image_name)

        if not self.image_name.islower():
            print(
                "Podman repositories must be lower case, use snake case for "
                "directory names, e.g. "
                + camel_to_snake(self.image_name)
                + " Note that the current container manager is"
                + self.container_manager
            )

    def build_image(self) -> Exception | None:
        """
        Build a podman / docker image out of the Dockerfile

        """
        try:
            run(
                [
                    self.container_manager,
                    "build",
                    "--layers",
                    "-t",
                    self.image_name,
                    self.full_path,
                ],
                check=True,
            )
            self.image_built = True
            return None
        except Exception as e:
            e.add_note("Error building {container.image_name}, SKIPPED")
            print(e, file=sys.stderr)
            return e

    def create_distrobox(self):
        # Remove the previous container, image name == container name == distrobox name
        run(["distrobox", "rm", "-f", self.image_name], check=False)
        run(["distrobox", "create", "-i", self.image_name], check=False)

    def build_image_and_create_distrobox(self):
        """
        Build a distrobox container out of the image
        """
        # If the image hasn't been built yet
        if not self.image_built:
            # Build the image
            if self.build_image() is None:
                # Then create the distrobox
                self.create_distrobox()


def main():
    # Get all the Dockerfiles and make instantiate objects
    # The object contains the parent directory + methods to build image
    containers: list[Container] = get_dockerfiles(dockerfiles_path)
    # Sort by heirarchy so parent containers are built first (sort by / count)
    containers = sorted(containers, key=lambda s: s.image_name.count("/"))
    # Build each container
    for container in containers:
        print("# " + container.image_name)
        container.build_image_and_create_distrobox()


def get_dockerfiles(directory_path) -> list[Container]:
    containers = []
    for root, dirs, files in os.walk(directory_path):
        if "Dockerfile" in files:
            image_name = os.path.abspath(root)
            containers.append(Container(image_name))
    return containers


def get_dirname() -> str:
    return os.path.basename(os.getcwd())


if __name__ == "__main__":
    main()

# * TODO What is missing
# I need to know which containers build and which don't
# If an image does not build I need to know why
#
# It's pointless if images appear to build, I don't care, the output needs to be
#
# ```
# Image Name                        Image          Distrobox
# ................................................................
# Building [base]                  [DONE]          [DONE]
# Building [base/text_editors]     [DONE]            ...
#
# For more detail, tail -f /tmp/dockerfile_builds.txt
#
