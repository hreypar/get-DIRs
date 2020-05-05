#!/usr/bin/env Rscript
#
# hreyes April 2020
# glm-normalized-hicexp.R
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
###################### infer model matrix ###########################
# probably would be good to add covars if they exist
modelmat <- model.matrix(~factor(meta(the.hicexp)$group))
#
###################### figure out groups ############################
samples <- meta(the.hicexp)

unique(samples$group)


########################## perform glm ##############################
# Now, we've got different tests we want to perform... 

qlf.MCF10AT1.MCF10A <- hic_glm(the.hicexp, design = modelmat, coef = 2,
                   method = "QLFTest", p.method = "fdr", parallel = TRUE)

# filtering is being moved to a different module anyway
top.qlf.MCF10AT1.MCF10A <- topDirs(qlf.MCF10AT1.MCF10A, return_df = "pairedbed", p.adj_cutoff = 0.05)


#

qlf.MCF10CA1A.MCF10A <- hic_glm(the.hicexp, design = modelmat, coef = 3,
                                method = "QLFTest", p.method = "fdr", parallel = TRUE)

top.qlf.MCF10CA1A.MCF10A <- topDirs(qlf.MCF10CA1A.MCF10A, return_df = "pairedbed", p.adj_cutoff = 0.05)

# should we output a list of qlf hicexp?

################ save qlf hicexp ################
saveRDS(the.hicexp, file = opt$output)
