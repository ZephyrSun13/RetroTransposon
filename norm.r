
#!/usr/bin/R

args <- commandArgs(trailingOnly = TRUE)

All <- read.table(file = args[1], sep = "\t", header = TRUE, row.names = 1)

#rownames(All) <- make.names(All[[1]], unique = TRUE)

#All <- All[, -1]

All <- All[, grep("^NT", names(All), invert = TRUE)]

All.ann <- All[, grep("^TP", names(All), invert = TRUE)]

All.count <- read.table(file = args[2], sep = "\t", header = FALSE, row.names = 1)

All.count.trans <- All.count

rownames(All.count.trans) <- paste0(rownames(All.count.trans), "_trans")

All.count <- rbind(All.count, All.count.trans)

#All[All==0] <- min(All[All>0])

All <- All[, intersect(rownames(All.count), names(All))]

All.count <- All.count[intersect(rownames(All.count), names(All)), ]

All <- t(apply(All, 1, function(x) {log2(x/All.count*max(All.count) + 1)}))

All <- cbind(All.ann, All)

write.table(All, file = "All.corrected.norm", sep = "\t", quote = FALSE, col.names = NA)

