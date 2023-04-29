## Julia and Neovim with these Dots

### Initialize the REPL SysImage

```sh
image_dir="$HOME/.julia/environments/Current/"
mkdir -p "${image_dir}"
cd       "${image_dir}"
```

When starting julia, it's going to be desirable to run it with `julia --threads=auto`, this will map processes over multiple cores.

```julia
using Pkg
pkg"add https://github.com/TsurHerman/Fezzik"
```

Close the Julia REPL and then start a fresh one:

```julia
using Fezzik
Fezzik.auto_trace()
```

Close the Julia REPL and then start a fresh one:


```julia
using Random
using Plots
using FFTW

N = 99
x = rand(Float32, N)
X = fft(x)
plot(abs.(X))
sleep(0.5)
```

Close the Julia REPL and then start a fresh one:

```julia
import Fezzik

Fezzik.brute_build_local()

# Optionally stop it from tracing
# It may be desirable to keep building up used packages though.
Fezzik.auto_trace(false)
```

### Initialize the LanguageServer SysImage

```sh
cd ~/.julia/environments/nvim-lspconfig/
make
```

Finally open Neovim and try to send a line through to the REPL.
