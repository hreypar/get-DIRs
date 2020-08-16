#!/usr/bin/env Rscript
#
# hreyes April 2020
# glm-normalised-hicexp-2groups.R
#
# Read in a normalized hicexp object and perform statistical testing
#
#
#################### import libraries and set options ####################
library(optparse)
suppressMessages(library(multiHiCcompare))
library(BiocParallel)
message("\nRequired libraries have been loaded.")
#
options(scipen = 10)
#
cores = parallel::detectCores()
register(MulticoreParam(workers = cores - 2), default = TRUE)
message(paste(cores, "cores detected, using", cores-2))
#
########################## functions ###################################
# it's dangerous to go alone! take this.
hic_glm_2groups <- function(g) {
  
  out <- hic_glm(hicexp = the.hicexp, design = modelmat, coef = g,
                   method = "QLFTest", p.method = "fdr", parallel = TRUE)
  
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

opt <- parse_args(OptionParser(option_list=option_list))

if (is.null(opt$input)){
  print_help(OptionParser(option_list=option_list))
  stop("The normalized hicexp input file is mandatory.n", call.=FALSE)
}

the.hicexp <- readRDS(file = opt$input)
message("The normalised hicexp has been loaded.")

# check the hicexp actually has 2 groups 
if (nlevels(meta(the.hicexp)$group) != 2) {
  stop("The normalized hicexp input file should contain 2 groups of samples.n", call.=FALSE)
}
#
###################### infer model matrix ###########################
# probably would be good to add covars if they exist
modelmat <- model.matrix(~factor(meta(the.hicexp)$group))
message("Model matrix for statistical test has been created.")
#
###################### prepare qlf list ############################
# group2 vs group1 coefficient
#
qlf.hicexp.list <- list(2)

#figure out groups
the.hicexp.groups <- levels(meta(the.hicexp)$group)

# set names for the comparison
names(qlf.hicexp.list) <- paste("qlf", the.hicexp.groups[2], the.hicexp.groups[1], sep=".")

message("The glm model has been created.")
#
########################## perform glms #############################
# Now, we've got different tests we want to perform... 

qlf.hicexp.list <- lapply(qlf.hicexp.list, FUN = hic_glm_2groups)
message("The quasi likelihood F-test been performed.")


################ save qlf hicexp ################
saveRDS(qlf.hicexp.list, file = opt$output)
message("The hicexp object with qlf test results has been saved as an Rds file.\n")
