# !/usr/bin/R
# library(tidyverse)
# library(mise)
#  mise()
StartTime <- Sys.time()

# If I didn't want `rmarkdown` as a dependency
   # This would also let me move the YAML to the bottom of the document
   # Another option that might work a lot better is using python with
       # https://github.com/eyeseast/python-frontmatter
   # Longer term ish I think using [tmsu](https://github.com/oniony/TMSU)
   # with the front matter and then vim-nerdtree would be the way to go
         # symlinks are better because I can fix it wit sed

# head(mdDoc)
# mdDoc <- read.delim(file = "~/Dropbox/Notable/notes/05 - Notes.md")
# grep(pattern = "\s\S", x = mdDoc, perl)
# Extracted_YAML <-
# myyamlfile <- yaml::read_yaml(Extracted_YAML)

### * Using the RMarkdown Dependency ------------------------------------------

#### *** Load or Install RMarkdown ###############################################

  if(require('rmarkdown')){
    library('rmarkdown')
  }else{
    install.packages('rmarkdown')
    library('rmarkdown')
  }

  if(require('R.utils')){
    library('R.utils')
  }else{
    install.packages('R.utils')
    library('R.utils')
  }
##### Load or Install dplyr ###################################################
  if(require('dplyr')){
    library('dplyr')
  }else{
    install.packages('dplyr')
    library('dplyr')
  }

##### Load or Install Purrr ######################################################

  if(require('purrr')){
    library('purrr')
  }else{
    install.packages('purrr')
    library('purrr')
  }

#### Set Working Directory (Actually Don't) =====================================
# Set Working Directory as Script Location
# Set Working Directory
  # rstudio api requires rstudio to run (and generally adds 30ms to run time)
  # setwd(getSrcDirectory()[1]) didn't work
  # just set a bash script to cd; Rscript ListTags.R; exit 0
setwd("~/Notes")

#### List all the Notes with a YAML Header =======================================
   # TODO use regex not slow list building
noteFiles <- c(dir(pattern="*.Rmd", recursive = TRUE), dir(pattern="*.md", recursive = TRUE), dir(pattern="*.txt", recursive = TRUE), dir(pattern="*.markdown", recursive = TRUE))



gen_symlinks <- function(file) {

  # Generate Symlinks

#' + If you put it it under the directory ag will return both the symlink and the file
#'   + Also Notable will have two copies of every file.
#'     + This doesn't matter for =#tags= because that directory
#'        because that directory is wiped by ~/bin/tagFilter.sh
#'        Every time tagFilter -s is run
#'        + Actually maybe it does matter and maybe I should move that to documents
#' + You will need to regularly delete this file upon restructuring
#' + don't ust /temp because root issues will occur

    for (tagDirPath in MDTags) {
        #actDirPath  <- paste0("./00Notebooks/", tagDirPath)
        actDirPath  <- paste0("~/Documents/00Notebooks/", tagDirPath)
	dir.create(path = actDirPath, recursive = TRUE)
        linkPath=paste0( actDirPath, "/", file)
          print(paste("Symlink from", file, "to", linkPath))
          createLink(link = linkPath, target = file)
       }
}

#### Run For Loop over Yaml ======================================================
# Create an empty dynamic Vector
tagVector <- c()

# Run the following code over the entire folder
c=0
for (i in noteFiles){
  c = c + 1
  yamlExtract <- yaml_front_matter(input = i )
  MDTags      <- (yamlExtract$tags)
  tagVector <- c(MDTags, tagVector)

   gen_symlinks(i) # adds a lotof time.
}
#tagVector <- flatten_chr(tagVector)

EndTime <- Sys.time()

#### Remove Repetition ===========================================================
cat("\n")
tagVector <- as.matrix(tagVector)

# tagFreq <- arrange(as.data.frame(table(tagVector)),-Freq)
# tagFreq <- arrange(as.data.frame(table(tagVector)),-Freq)
tagVector      <- unique(tagVector)



#### Write to a CSV ===============================================================
# Write a document containing all the tags
# write.csv(tagVector, file = "~/Desktop/YamlScript/tags.csv", quote = TRUE, row.names = FALSE)
write.csv(tagVector, file = "/tmp/00tags.csv", quote = FALSE, row.names = FALSE)


#@#### Create Notebook Directories ==================================================
#@for(i in 1:length(tagVector)){
#@  tagPath=paste( "./00Notebooks/",tagVector[i], sep = "")
#@  dir.create(path = tagPath, recursive = TRUE)
#@  linkPath=paste( "./00Notebooks/", tagVector[i], i, sep = "")
#@  print(linkPath)
#@  createLink(link = linkPath, target = i)
#@ # Nah so the issue here is that I need to connect the filename to the YAML extract, so n order to do that I can either write a DB or I can do it inside the loop, hmmm
#@}



#### Optional Arguments =========================================================
# Print Statement

args <- commandArgs(trailingOnly = TRUE)
if (length(args)!=0) {
  if (args[1]=="p" | args[1]=="-p") {
    print(tagFreq)  # I could list this by frequency
  }
  if (args[1]=="--help" | args[1]=="-h") {
    print("Using the p argument will print the tags")
  }
}

print(paste(length(tagVector), "Tags Successfully Generated in ", round((EndTime- StartTime),3)*1000, "MilliSeconds"))







## vim:fdm=expr:fdl=0
## vim:fde=getline(v\:lnum)=~'^##'?'>'.(matchend(getline(v\:lnum),'##*')-2)\:'='
