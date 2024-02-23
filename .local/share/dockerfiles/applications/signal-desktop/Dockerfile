#https://www.cogitri.dev/posts/12-fedora-toolbox/
FROM debian:latest

# The following packages are recommended by distrobox-init for a dnf sys
# Install them here so everything works without distrobox
RUN export DEBIAN_FRONTEND=noninteractive

RUN apt update  -y && \
    apt upgrade -y && \
    apt install -y apt-utils bash-completion bc bzip2 curl dialog diffutils findutils gnupg gnupg2 gpgsm hostname iproute2 iputils-ping keyutils less libcap2-bin libkrb5-3 libnss-mdns libnss-myhostname libvte-2.9*-common libvte-common locales lsof man-db manpages mtr ncurses-base openssh-client passwd pigz pinentry-curses procps rsync sudo tcpdump time traceroute tree tzdata unzip util-linux wget xauth xz-utils zip libgl1 libegl1-mesa libgl1-mesa-glx libegl1 libglx-mesa0 libvulkan1 mesa-vulkan-drivers apt-transport-https

RUN wget -O                                                             \
    /usr/share/keyrings/element-io-archive-keyring.gpg                  \
    https://packages.element.io/debian/element-io-archive-keyring.gpg &&\
    echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list &&\
    apt update  -y                                                     &&\
    apt install -y element-desktop


# Some more stuff done by distrobox

		# In case the locale is not available, install it
		# will ensure we don't fallback to C.UTF-8

# this is
# dpkg-reconfigure locales                                   &&\
RUN \
  export DEBIAN_FRONTEND=noninteractive                     &&\
  sed -i "s|#.*en_US.UTF-8|en_US.UTF-8|g" /etc/locale.gen    &&\
  locale-gen                                                 &&\
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8          &&\
  apt-get --reinstall install -y tzdata

# Taken from https://signal.org/download/#
# 1. Install our official public software signing key:
RUN wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg && \
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

# 2. Add our repository to your list of repositories:
RUN echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee /etc/apt/sources.list.d/signal-xenial.list

# Update and install Signal

RUN \
    apt update  -y                        &&\
    apt upgrade -y                        &&\
    apt install -y signal-desktop

