## Where am I?
.First <- function() {
    # Print a welcome message
    message("Your working directory is currently: ", getwd())
}
## Set default mirror
local({
    r <- getOption("repos")
    r["CRAN"] <- "https://cloud.r-project.org"
    options(repos = r)
})
## Set multiple cores
options(Ncpus = parallel::detectCores() - 2)
options(mc.cores = parallel::detectCores() - 2)



## Needed for transperancy
## Requires:
## ```bash
## xbps-install -S libXt-devel
## ```
## ```r
## install.packages("cairo")
## ```
setHook(
    packageEvent("grDevices", "onLoad"),
    function(...) grDevices::X11.options(type = "cairo")
)
# options(device = "x11") # NOTE may need to remove this for  Jupyter under Runit
## https://stackoverflow.com/a/22915279
options(bitmapType="cairo")





# Fix linting
options(lintr.linter_file="~/.config/R/lintr")
