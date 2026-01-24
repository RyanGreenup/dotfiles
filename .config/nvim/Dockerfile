FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.13 \
    python3.13-venv \
    python3-pip \
    && curl -fLO https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz \
    && tar -xzf nvim-linux-x86_64.tar.gz -C /usr/local --strip-components=1 \
    && rm nvim-linux-x86_64.tar.gz

## NOTE install additional deps here till it works
# Required for native-fzf in Telescope
RUN apt-get -y install cmake gcc clang
RUN apt-get -y install npm && npm install -g tree-sitter-cli
RUN npm install -g yarn
RUN apt-get -y install unzip r-base
RUN apt-get -y install r-cran-tidyverse r-cran-stringr libxml2-dev libcurl4-openssl-dev libssl-dev

# On the local system one may also consider e.g.
# RUN echo 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"))' >> /etc/R/Rprofile.site \
#     && Rscript -e 'install.packages("languageserver")'


RUN rm -rf /var/lib/apt/lists/*
