# https://github.com/doomemacs/doomemacs/issues/116

# https://github.com/ryanoasis/nerd-fonts#option-3-install-script
# Clone this repo and unpack them all
# https://github.com/domtronn/all-the-icons.el

f=JetBrainsMono
mkdir ${f}
cd    ${f}
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${f}.tar.xz
tar -xf ${f}.tar.xz
cd ..

f=FiraCode
mkdir ${f}
cd    ${f}
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${f}.tar.xz
tar -xf ${f}.tar.xz
cd ..

f=RobotoMono
mkdir ${f}
cd    ${f}
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${f}.tar.xz
tar -xf ${f}.tar.xz
cd ..


f=Iosevka
mkdir ${f}
cd    ${f}
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${f}.tar.xz
tar -xf ${f}.tar.xz
cd ..


git clone https://github.com/domtronn/all-the-icons.el    && \
    mv all-the-icons.el/**/*.ttf .                        && \
    rm -rf all-the-icons.el

fc-cache -f -v

# Font Awesome (good for e.g. Typst with Codly template)
npm install @tabler/icons-webfont
mv node_modules/@tabler/icons-webfont/dist/fonts/tabler-icons.ttf \
    node_modules/@tabler/icons-webfont/dist/fonts/tabler-icons-filled.ttf \
    node_modules/@tabler/icons-webfont/dist/fonts/tabler-icons-outline.ttf  \
    .
rm -rf node_modules
