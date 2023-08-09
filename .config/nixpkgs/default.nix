# import the nixpkgs library
let
  pkgs = import <nixpkgs> {};



in
  # Build a nix env with specified packages
  pkgs.buildEnv {
    # Setthe name of the env
    name = "my-packages";
    # Set the paths to the desired packages
    paths = with pkgs; let
      # igraph is slow!
      # [fn_r_xml2]
      buildInputs = [
        libxml2
        libxml2.dev
        libxslt
        rPackages.stringi
      ];

      # [fn_rstudio]
      rstudioEnv = rstudioWrapper.override {
        packages = with rPackages; [
          ggplot2
          dplyr
          xts
          xml2
          IRkernel
          ggplot2
          tidyverse
          igraph
          rtweet
          rtoot
          languageserver
          languageserversetup
          quarto
          knitr
          rmarkdown
          reshape2
          png
          reticulate
          stringi
        ];
      };
      R_with_my_packages = rWrapper.override {packages = with rPackages; [ggplot2 dplyr xts xml2 IRkernel ggplot2 tidyverse igraph rtweet rtoot languageserver quarto knitr rmarkdown reshape2 png reticulate];};
    in [
      # evcxr # [fn_evcxr_jup]
      rustup
      # [fn_python]
      (python3.withPackages (ps: [
        # Jupyter
        ps.jupyter
        ps.jupyterlab
        ps.pip
        ps.ipykernel
        ps.overrides
        ps.async-lru
        # Essentials
        ps.numpy
        ps.polars
        ps.pandas
        ps.matplotlib
        ps.seaborn
      ]))
      # jupyter
      # alacritty # Doesn't work because nvidia
      zellij
      broot
      tealdeer
      fd
      firefox
      # librewolf-unwrapped # bukubrow requires native messaging, won't work through nix, likely keepass also
      brave
      tmux
      syncthing
      unison

      libxml2.dev
      openssl.dev
      pandoc
      # R # [fn_R_packages]
      R_with_my_packages # [fn_R] [fn_knitr]
      texlive.combined.scheme-full # SLOW
      pandoc

      xml2
      libxml2
      pkg-config
      lz4
      jetbrains.pycharm-professional
      jetbrains-toolbox
      jetbrains.clion


      emacs29
      neovim
      neovide
      vscode # Free to install extensions through interface
      # Switching preserves previously installed packages
      # vscode-with-extensions # Must manage extensions through nix exclusively
      # Adapted from https://nixos.wiki/wiki/Visual_Studio_Code
      # Missing REditorSupport and julia
      /*
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions;
          [
            bbenoist.nix
            ms-python.python
            ms-toolsai.jupyter
            golang.go
            ms-azuretools.vscode-docker
            ms-vscode-remote.remote-ssh
            rust-lang.rust-analyzer
            ms-vscode.cpptools
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          ];
      })
      */
      keepassxc
      bukubrow
      element-desktop
      # rocketchat-desktop # No matrix support to be found
      thunderbird
      # fluffychat # doesn't work
      fzf
      skim
      broot
      lf
      zoxide
      ranger
      sqlitebrowser
      elvish
      wireguard-tools
      gitui
      bat
      ripgrep
      helix

      sshfs-fuse
      xclip

      vnote # [fn_vnote]
      obsidian

      alejandra

      # rstudio
      rstudioEnv
      quarto
      fira-code
      fira
      # [fn_yet_to_test]
      # mathematica
      # octave
      # cantor
      julia-bin
      geogebra
      lua

      dwmblocks
      lxsession

      # leftwm # Broken window maximise on old version, newest version is available through cargo

      # gparted  # Doesn't work, no sudo

      # I haven't tried this, be mindful, it could cause issues with Gentoo
      # clang
      # cmake
    ];
  }

################################################################################
##  Footnotes  #################################################################
################################################################################


# [fn_evcxr_jup]
# Make sure to re-run `evcxr_jupyter --install` after installing this via nix
# I haven't tried it with external libraries :shrug:
# Also this still requires `evcxr_jupyter` which is not in nix, so probably
# just stick with `cargo install evcxr evcxr_repl evcxr_jupyter &&
# evcxr_jupyter --install`


# [fn_python]
# There is not a lot of need to install Python through nix
#   * Virtual environments means multiple-versions is solved
# However, this means Jupyter is stable and won't randomly break, it's tied to
# the derivation, this can then be rolled back to with a snapshot of home
# == Jupyter ==
# When I installed jupyter through Nix I needed to reinstall the kernels
# ```sh
# evcxr_jupyter --install; R -e 'IRkernel::installspec()'
# ```
# After that it worked fine through a virtual environment, nix, or Gentoo
# Just remember with Gentoo, you must have the R png use flag for IRkernel to work


# [fn_vnote]
# Same problem as alacritty
# Could not initialize GLX
# Must run with
# QT_XCB_GL_INTEGRATION=none vnote
# <https://github.com/NixOS/nixpkgs/issues/169630>

# [fn_R]
# When R is installed via nix and the system concurrently
# some editors (e.g. Rstudio) will reach for the system R not the nix one
# Vscode will want R to have the languagserver installed, this depends on
# xml2, so follow the advice in [fn_r_xml2] below.

# [fn_rstudio]
# > RStudio uses a standard set of packages and ignores any custom R environments or installed packages you may have. To create a custom environment, see rstudioWrapper, which functions similarly to rWrapper, see:
# * <https://github.com/NixOS/nixpkgs/blob/20bc3aa323fc4f20e2369be83c5b2d500bab1645/doc/languages-frameworks/r.section.md>

# [fn_r_xml2]
# When installing R through nix, xml2 will break because it cannot find libxml2
# under the directory:
# /home/ryan/R/x86_64-pc-linux-gnu-library/4.3/xml2/libs
# The steps I took to fix this:
# 1. Add `buildInputs = [ libxslt zlib ] ` to the default.nix
# 2. Add both xml2 and languageserver as R packages with the rWrapper.override
# 3. Inside the nix R, `install.packages(c("xml2", "languageserver"))`
# 4. Repeat for stringi `install.packages("stringi")`

# [fn_R_packages]
# Seemingly it doesn't matter whether you install R or R with packages. I've been able to install additional packages in the rWrapper just fine.

# [fn_knitr]
# > To knit a .Rmd file to a pdf (or .Rnw), you need to have included in your envronment pkgs.texlive.combined.scheme-fullas well as pandoc or it will fail to knit. None of the other texlive packages contain the proper "frame" package.
# > there are likely other workarounds but this requires the least effort.


################################################################################
## README ######################################################################
################################################################################
# 1. nix-env -if default.nix
# 2. which R
#   * ensure this is the nix version
# 3. R -e 'install.packages(c("xml2", "languageserver", "stringi"))'
# 4. R -e 'IRkernel::installspec()'
# 5. R -e 'IRkernel::installspec()'
# 6. julia -E 'using Pkg; Pkg.add("IJulia")
# 7. cargo jinstall evcxr evcxr_jupyter evcxr_repl; evcxr_jupyter --install
#  * This way there is a rust kernel for jupyter
# 8. Get Dotfiles
# 8. Install Doom Emacs
# 9. Install Neovim and Packer Sync


# When can I install packages through the program?
# R
# Seems to be fine with me installing packages, or nix installing them
# Julia
# They're all installed via Julia
# Python
# Don't use pip, use virtual environments, pip itself may not allow this anymore
# VScode
# You can have one or the other, switching between vscode and vscode-with-extensions doesn't interfere with one another
# Pycharm
# Installing extensions is fine



