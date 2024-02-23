#https://www.cogitri.dev/posts/12-fedora-toolbox/
FROM fedora:latest

# Fix default container stuff
RUN \
    dnf update  -y                        &&\
    dnf upgrade -y                        &&\
    dnf install -y passwd                 &&\
   # This is what distrobox-init does:
    sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf

# The following packages are recommended by distrobox-init for a dnf sys
# Install them here for posterity
RUN dnf install -y bash-completion bc bzip2 curl diffutils dnf-plugins-core findutils glibc-all-langpacks glibc-locale-source gnupg2 gnupg2-smime hostname iproute iputils keyutils krb5-libs less lsof man-db man-pages mtr ncurses nss-mdns openssh-clients pam passwd pigz pinentry procps-ng rsync shadow-utils sudo tcpdump time traceroute tree tzdata unzip util-linux vte-profile wget which whois words xorg-x11-xauth xz zip mesa-dri-drivers mesa-vulkan-drivers vulkan
RUN

# Fix timezone (adapted from distrobox-init)
RUN dnf reinstall -y tzdata

# Get some shells
RUN dnf install -y firefox mozilla-ublock-origin

# I don't think I actually need these
# CMD /bin/bash
# CMD tail -f /dev/null

