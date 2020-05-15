#!/usr/bin/env Rscript
#
# hreyes May 2020
# mahattan-hicexp.R
#
# Read in a normalized and compared hicexp object and produce a manhattan 
# plot of the differences in a PDF format.
#
#################### import libraries and set options ####################
library(multiHiCcompare)
#
########################## functions ###################################
# it's dangerous to go alone! take this.

produce_manhattan <- function(comparison) {
  pdf(file = paste0(opt$outputpath, gsub("\\.", "-", names(the.hicexp)), ".pdf"), 
      height = 15, width = 30)
  
  manhattan_hicexp(hicexp = the.hicexp[[comparison]])
  title(gsub("\\.", " vs ", gsub("qlf.", "quasi-likelihood F-test ", names(comparison))))
  abline(h = -log10(0.001), lwd=1, lty=3, col="red")
  abline(h = -log10(0.05), lwd=1, lty=3, col="red")
  
  dev.off()
}
#
########################## read in data ###################################
option_list = list(
  make_option(opt_str = c("-i", "--input"), 
              type = "character",
              help = "Input Rds file: a list with hicexp objects obtained using glm-hicexp"),

  make_option(opt_str = c("-p", "--outputpath"),
              type = "character", 
              help = "Path for output file file: a manhattan plot of the pvalues from the comparison"),
)

opt <- parse_args(OptionParser(option_list=option_list))

if (is.null(opt$input)){
  print_help(OptionParser(option_list=option_list))
  stop("The input file is mandatory.n", call.=FALSE)
}

input.hicexp <- readRDS(opt$input)

########################## call plotting ###################################
lapply(names(the.hicexp), produce_manhattan)


