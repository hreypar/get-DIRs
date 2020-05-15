# DESCRIPTION:
# mk module to use a glm quasi likelihood model to
# F-test differences between Hi-C samples.
#
# USAGE:
# Single target execution: `mk <TARGET>` where TARGET is
# any line printed by the script `bin/mk-targets`
#
# Multiple target execution in tandem `bin/mk-targets | xargs mk`
#
# AUTHOR: HRG
#
# Run R script to use glm on a normalised hicexp.
#
results/%.qlf.cycnorm.hicexp.Rds:	data/%.cycnorm.hicexp.Rds
	mkdir -p `dirname $target`
	bin/glm-normalised-hicexp.R \
		--input $prereq \
		--output $target

# Produce Manhattan plots of the qlf comparisons.
#
results/%.pdf:	results/%.qlf.cycnorm.hicexp.Rds
	bin/manhattan-hicexp.R \
		--input $prereq \
		--outputpath `dirname $target`

