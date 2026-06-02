#!/usr/bin/env Rscript

# Plot output from likelihood mapping by iqtree3
# Last modified: 2026-06-02 14:32:16
# Sign: JN

require(readr)
require(dplyr)
require(ggtern)
require(ggplot2)

args <- commandArgs(TRUE)
if (length(args) == 0) {
    stop("Needs an input file", call. = FALSE)
}
infile <- args[1]
out_png <- paste(infile, ".lmap.png", sep = "")

lm <- read_tsv(infile, show_col_types = FALSE)

#  ggtern(lm, aes(x=weight1, y=weight2, z=weight3)) +
#    geom_point(size=3, alpha=0.5) +
#    theme_bw() +
#    labs(title="IQ-TREE 3 likelihood mapping (quartets)") +
#    Tlab("Topology 3") + Llab("Topology 1") + Rlab("Topology 2")
#
#  # Color dots by area
#  ggtern(lm, aes(x=weight1, y=weight2, z=weight3, color=factor(area))) +
#    geom_point(size=3, alpha=0.5) +
#    theme_bw() +
#    labs(color="Area", title="Likelihood mapping colored by IQ-TREE area") +
#    Tlab("Topology 3") + Llab("Topology 1") + Rlab("Topology 2")
#
#  # Color dots by corner
#  ggtern(lm, aes(x=weight1, y=weight2, z=weight3, color=factor(corner))) +
#    geom_point(size=3, alpha=0.5) +
#    theme_bw() +
#    labs(color="Corner", title="Likelihood mapping colored by IQ-TREE area") +
#    Tlab("Topology 3") + Llab("Topology 1") + Rlab("Topology 2")

# Color by resolved or not
lm2 <- lm %>%
  mutate(
    maxw = pmax(weight1, weight2, weight3),
    class = case_when(
      maxw >= 0.9 ~ "resolved (corner)",
      maxw <= 0.4 ~ "unresolved (center)",
      TRUE        ~ "partly resolved"
    )
  )

p <- ggtern(lm2, aes(weight1, weight2, weight3, color = class)) +
  geom_point(size=3, alpha=0.5) +
  theme_bw() +
  labs(color="Resolved", title="Likelihood mapping colored by IQ-TREE resolution") +
  Tlab("Topology 3") + Llab("Topology 1") + Rlab("Topology 2")

png(out_png, width = 700)
p
dev.off()

cat("\nDone. Check for file ", out_png, "\n", sep="")

q(status=0)


# TODO:
# Plot percentage of maps in corners and areas.
# Need to be able to draw the areas as lines in the figure.
