FROM localhost/base

RUN dnf install -y go golang-x-tools-gopls golang-x-tools-guru                                       \
                   python black python3-pyflakes  python3-isort pipenv                               \
                   python3-nose python3-pytest ansible                                               \
                   shellcheck shfmt                                                                  \
                   rustup fd-find git neovim texlive latexmk texlive-xetex texlive-wrapfig texstudio \
                   texlive-scheme-full python3-pygments meld                                         \
                   zathura zathura-devel zathura-djvu zathura-pdf-mupdf zathura-ps
RUN go install github.com/x-motemen/gore/cmd/gore@latest

# Add fonts and meld
RUN dnf install -y fontawesome-fonts-all mozilla-fira-fonts-common mozilla-fira-mono-fonts mozilla-fira-sans-fonts dejavu-fonts-all

# RUN git clone https://github.com/domtronn/all-the-icons.el /tmp/all-the-icons && cp /tmp/all-the-icons/**/*.ttf ~/.local/share/fonts/ && fc-cache -f -v

# Install Emacs [fn_2]
# Use pgtk emacs
RUN dnf copr enable -y deathwish/emacs-pgtk-nativecomp
RUN dnf install -y emacs
RUN dnf update  -y emacs



# [fn_1]: https://www.reddit.com/r/emacs/comments/qtsx98/comment/hkn7sfw/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

# [fn_2]
  # Emacs can either run as X or Wayland (pgtk).
  #
  #   * X11
  #     * The X11 version does not work on Gnome-Wayland on Nvidia.
  #   * pgtk
  #     * The pgtk version doesn't run well under X
  #
  # I've created containers for both versions under ./emacs-x/ and ./emacs-wayland/
  #
  # For more info see:
  #
  #   * http://vale:8076/index.php/Xwayland_support_in_Gnome_on_Nvidia
  #   * http://vale:8076/index.php/Emacs#Different_Installs
  #
  # Native Comp is included in the default fedora install, check with
  # # (native-comp-available-p)
