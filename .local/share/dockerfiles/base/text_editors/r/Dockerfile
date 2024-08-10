# Inherit from text-editors so the r box has latex
FROM localhost/text_editors




# Add COPR
RUN dnf install 'dnf-command(copr)' -y && \
    dnf copr enable iucar/cran -y      && \
    dnf update -y                      && \
    dnf upgrade -y

# Install Rstudio
RUN dnf install -y --setopt=tsflags=        \
    R-CoprManager R rstudio-desktop python3 \
    xeyes wget tmux                         \
    R-CRAN-{fpp3,rmarkdown,quarto,tidyverse,xts,languageserver,IRkernel}

# Install jupyterlab, black and pip
RUN dnf install -y pipx jupyterlab
# This is a newer version with quarto
# RUN wget 'https://download1.rstudio.org/electron/rhel9/x86_64/rstudio-2023.06.2-561-x86_64.rpm'  &&\
#     dnf install --allowerasing -y rstudio-2023.06.2-561-x86_64.rpm

# Install Julia
RUN dnf install -y julia julia-devel julia-doc; julia -e 'using Pkg; Pkg.add("IJulia")'

# Setup a Python Virtualenvironment
# Need 3.11 for torch
RUN dnf install -y python3.11
RUN jup_dir="~/.local/share/virtualenvs/jupyter"; \
    test -d ${jup_dir} && rm ${jup_dir};  \
    python3.11 -m venv ${jup_dir}; \
    ${jup_dir}/bin/pip install \
        numpy polars pandas torch jupyterlab scikit-learn

RUN dnf install -y R-CRAN-latex2exp R-CRAN-gridExtra

CMD ~/.local/share/virtualenvs/jupyter/bin/jupyter lab
