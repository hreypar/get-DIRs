#!/usr/bin/env Rscript
#
# hreyes April 2020
# glm-normalised-hicexp-3groups.R
#
# Read in a normalized hicexp object and perform statistical testing
#
#
#################### import libraries and set options ####################
library(optparse)
suppressMessages(library(multiHiCcompare))
library(BiocParallel)
#
options(scipen = 10)
#
cores = parallel::detectCores()
register(MulticoreParam(workers = cores - 2), default = TRUE)
#
########################## functions ###################################
# it's dangerous to go alone! take this.
hic_glm_3groups <- function(g) {
  
  if(length(g) == 1) {
    out <- hic_glm(hicexp = the.hicexp, design = modelmat, coef = g,
                   method = "QLFTest", p.method = "fdr", parallel = TRUE)
  } else {
    out <- hic_glm(hicexp = the.hicexp, design = modelmat, contrast = g,
                   method = "QLFTest", p.method = "fdr", parallel = TRUE)
  }
  
  return(out)
}
# 
########################## read in data ###################################
option_list = list(
  make_option(opt_str = c("-i", "--input"), 
              type = "character",
              help = "Input normalised hicexp object as an Rds file"),
  make_option(opt_str = c("-o", "--output"), 
              type = "character", 
              help = "output filepath for the glm-ed hicexp object")
)
#
opt <- parse_args(OptionParser(option_list=option_list))
#
### check the hicexp parameter is not empty
if (is.null(opt$input)){
  print_help(OptionParser(option_list=option_list))
  stop("The normalized hicexp input file is mandatory.n", call.=FALSE)
}
#
the.hicexp <- readRDS(file = opt$input)
#
### check the hicesp actually has 3 groups 
if (nlevels(meta(the.hicexp)$group) != 3) {
  stop("The normalized hicexp input file should contain 3 groups of samples.n", call.=FALSE)
}
#
###################### infer model matrix ##########################
# probably would be good to add covars if they exist
modelmat <- model.matrix(~factor(meta(the.hicexp)$group))
#
###################### prepare qlf list ############################
# group2 vs group1 coefficient
#
# group3 vs group1 coefficient
#
# group3 vs group2 contrast 
# from edgeR documentation "The contrast argument in this case requests 
# a statistical test of the null hypothesis that coefficient3−coefficient2 
# is equal to zero."
#
qlf.hicexp.list <- list(2, 3, c(0, -1, 1))
#
#figure out groups
the.hicexp.groups <- levels(meta(the.hicexp)$group)
#
names(qlf.hicexp.list) <- c(paste("qlf", the.hicexp.groups[2], the.hicexp.groups[1], sep = "."),
                            paste("qlf", the.hicexp.groups[3], the.hicexp.groups[1], sep = "."),
                            paste("qlf", the.hicexp.groups[3], the.hicexp.groups[2], sep = ".")
                          )
#
########################## perform glms #############################
qlf.hicexp.list <- lapply(qlf.hicexp.list, FUN = hic_glm_3groups)

################ save qlf hicexp ################
saveRDS(qlf.hicexp.list, file = opt$output)
