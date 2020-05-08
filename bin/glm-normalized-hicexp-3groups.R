#!/usr/bin/env Rscript
#
# hreyes April 2020
# glm-normalized-hicexp-3groups.R
#
# Read in a normalized hicexp object and perform statistical testing
#
#
#################### import libraries and set options ####################
library(optparse)
library(multiHiCcompare)
library(BiocParallel)
#
options(scipen = 10)
#
cores = parallel::detectCores()
register(MulticoreParam(workers = cores - 2), default = TRUE)
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

opt <- parse_args(OptionParser(option_list=option_list))

if (is.null(opt$input)){
  print_help(OptionParser(option_list=option_list))
  stop("The normalized hicexp input file is mandatory.n", call.=FALSE)
}

the.hicexp <- readRDS(file = opt$input)
#
############### check it's actually 3 groups ########################
if (nlevels(meta(the.hicexp)$group) != 3) {
  stop("The normalized hicexp input file should contain 3 groups of samples.n", call.=FALSE)
}
#
###################### infer model matrix ###########################
# probably would be good to add covars if they exist
modelmat <- model.matrix(~factor(meta(the.hicexp)$group))
#
###################### figure out groups ############################
the.hicexp.groups <- levels(meta(the.hicexp)$group)

qlf <- list(2, 3, c(0, -1, 1))

#
########################## perform glms ##############################
# group2 vs group1
# group3 vs group1
# group3 vs group2

#The contrast argument in this case requests a statistical test of the null hypothesis that
#coefficient3−coefficient2 is equal to zero.



qlf.MCF10AT1.MCF10A <- hic_glm(the.hicexp, design = modelmat, coef = 2,
                   method = "QLFTest", p.method = "fdr", parallel = TRUE)



#

qlf.MCF10CA1A.MCF10A <- hic_glm(the.hicexp, design = modelmat, coef = 3,
                                method = "QLFTest", p.method = "fdr", parallel = TRUE)


# should we output a list of qlf hicexp?

################ save qlf hicexp ################
saveRDS(the.hicexp, file = opt$output)
