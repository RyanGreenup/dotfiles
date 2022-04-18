## Where am I?
.First <- function(){
    # Print a welcome message
    message("Your working directory is currently: ", getwd())
}
## Set default mirror
local({r <- getOption("repos")
       r["CRAN"] <- "https://cloud.r-project.org" 
       options(repos=r)
})
## Set multiple cores
options(Ncpus = parallel::detectCores()-2)
options(mc.cores = parallel::detectCores()-2)

