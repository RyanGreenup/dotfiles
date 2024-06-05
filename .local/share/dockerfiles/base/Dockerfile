#https://www.cogitri.dev/posts/12-fedora-toolbox/
# FROM fedora:latest
# 39 is required for https://copr.fedorainfracloud.org/coprs/deathwish/emacs-pgtk-nativecomp/
FROM fedora:39

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

# Fix timezone (adapted from distrobox-init)
RUN dnf reinstall -y tzdata

# Get some shells
RUN dnf install -y fish golang-github-elves-elvish zsh bash dash


# Install default packages and VSCodium
COPY packages.txt /
RUN \
    rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg    &&\
    printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" |\
        tee -a /etc/yum.repos.d/vscodium.repo                                                     &&\
    dnf update  -y                                                                                &&\
    dnf install -y $(< /packages.txt)

# Install Jetbrains
# TODO do I need this if I could just put it in home?
RUN cd /tmp                                                                                       && \
    wget 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.1.3.18901.tar.gz'            &&\
    tar -xzf jetbrains-toolbox-* -C /opt
# Fuse is required for jetbrains-toolbox (`dnf provides libfuse.so.2`)
RUN dnf install -y fuse-libs fuse

# Additional Packages that are nice to have
RUN dnf install -y fd-find ripgrep rustup cargo ranger tmux python pipx \
                   pandoc zathura zathura-cb zathura-djvu zathura-pdf-mupdf zathura-ps go && \
    rustup-init -y

# Install LF as a ranger alternative
RUN env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest

# Additional Rust packages that are nice to have
RUN \
    $HOME/.cargo/bin/rustup default nightly       && \
    $HOME/.cargo/bin/cargo install broot
# I couldn't get zellij to compile, I'll need to look into this
#     $HOME/.cargo/bin/cargo install --locked zellij

# Additional Packages for Vim and Dotfiles
RUN dnf install -y cmake gcc clang nodejs nodejs-npm \
                   fontawesome-fonts-all mozilla-fira-fonts-common \
                   mozilla-fira-mono-fonts mozilla-fira-sans-fonts \
                   zoxide fzf gitui ctags nano xclip wl-clipboard xsel

# Required for the chat_cli program I wrote in rust
# Removed openssl1.1
RUN dnf install -y openssl openssl-devel  alacritty libxkbcommon-x11-devel

# Get some networking tools
RUN dnf install -y bind-utils

# I don't think I actually need these
# CMD /bin/bash
# CMD tail -f /dev/null

