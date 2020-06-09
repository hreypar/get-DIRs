#!/usr/bin/env Rscript
#
# hreyes May 2020
# mahattan-hicexp.R
#
# Read in a normalized and compared hicexp object and produce a manhattan 
# plot of the differences in a PDF format.
#
# always bear in mind that this plots REGIONS (not PAIRS of regions)
#################### import libraries and set options ####################
library(multiHiCcompare)
library(optparse)
#
options(scipen = 10)
########################## functions ###################################
# it's dangerous to go alone! take this.

produce_manhattan <- function(comparison) {
  png(file = paste0(dirname(args), "/", gsub("\\.", "-", comparison), ".png"), 
      height = 15, width = 30, units = "in", res = 500)
  
  manhattan_hicexp(hicexp = hicexp.comparison.list[[comparison]])
  title(main = gsub("\\.", " vs ", gsub("qlf.", "quasi-likelihood F-test ", comparison)),
        cex.main = 3)
  abline(h = -log10(0.001), lwd=3, lty=2, col="red")
  #abline(h = -log10(0.05), lwd=2.5, lty=2, col="red")
  
  pq = quantile(-log10(results(hicexp.comparison.list[[comparison]])$p.value))
  axis(side = 2, at = seq(from = 0, to = round(pq["100%"]), by = 1), las=1)
  
  dev.off()
}
#
########################## read in data ###################################
args = commandArgs(trailingOnly=TRUE)

hicexp.comparison.list <- readRDS(args)

########################## call plotting ###################################
lapply(names(hicexp.comparison.list), produce_manhattan)


