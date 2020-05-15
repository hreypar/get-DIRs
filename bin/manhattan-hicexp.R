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
library(optparse)
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
              help = "Input lis of hicexp objects as an Rds file"),
  make_option(opt_str = c("-o", "--outputpath"), 
              type = "character", 
              help = "output filepath for PDF")
)
opt <- parse_args(OptionParser(option_list=option_list))

if (is.null(opt$input)){
  print_help(OptionParser(option_list=option_list))
  stop("The input file is mandatory.n", call.=FALSE)
}

the.hicexp <- readRDS(opt$input)

########################## call plotting ###################################
lapply(names(the.hicexp), produce_manhattan)


