
Args <- commandArgs(trailingOnly = TRUE)

Thres <- Args[1]

Tab <- read.table(file = "All.merge.xls", sep = "\t", row.names = 13, header = TRUE, check.names = FALSE)

num <- apply(Tab[, grep("trans", names(Tab)[-(1:12)], invert = TRUE, value = TRUE)], 1, function(x) length(which(x>as.integer(Thres))))

Tab2 <- Tab[names(sort(num[num>0], decreasing=TRUE)), ]

Tab2Ann <- Tab2[, 1:12]

Tab2L1 <- Tab2[, grep("trans", names(Tab2)[-(1:12)], invert = TRUE, value = TRUE)]

ColName <- colnames(Tab2L1)

Tab2Trans <- Tab2[, grep("trans", names(Tab2)[-(1:12)], invert = FALSE, value = TRUE)]

Tab2Ann$Loc <- apply(Tab2Ann[, c("Trans_chromosome", "Trans_chromosom_split_site")], 1, function(x) {paste(unique(paste(unlist(strsplit(x[1], split = ";")), gsub(" ", "", unlist(strsplit(x[2], split = ";"))), sep = "_")), collapse = ";")})

Tab2Ann$Gene <- sapply(as.character(Tab2Ann$Symbol), function(x) paste(unique(unlist(strsplit(x, split = ";"))), collapse = ";"))

write.table(data.frame(cbind(Tab2Ann, Tab2L1, Tab2Trans), stringsAsFactors = FALSE, check.names = FALSE), file = paste0("All.merge.", Thres, ".xls"), sep = "\t", quote = FALSE, col.names = NA)

Loc <- Tab2Ann$Loc

RowName <- tapply(rownames(Tab2), Loc, function(x) paste(x, collapse = ";"))

Tab2Ann <- apply(Tab2Ann, 2, function(x) tapply(x, Loc, function(y) paste(y, collapse = ";")))

#Tab2L1 <- apply(Tab2L1, 2, function(x) tapply(x, ExprStr, max))

#tt <- lapply(Tab2L1, function(x) tapply(x, ExprStr, unique))

tmp <- list()

for(i in 1:ncol(Tab2L1)){

	print(i)

	tmp[[i]] <- tapply(Tab2L1[[i]], Loc, mean)

}

Tab2L1 <- Reduce(cbind, tmp)

colnames(Tab2L1) <- ColName

#Tab2Trans <- apply(Tab2Trans, 2, function(x) tapply(x, ExprStr, unique))

tmp <- list()

for(i in 1:ncol(Tab2Trans)){

        print(i)

        tmp[[i]] <- tapply(Tab2Trans[[i]], Loc, mean)

}

Tab2Trans <- Reduce(cbind, tmp)

colnames(Tab2Trans) <- paste0(ColName, "_trans")

Tab2Uni <- data.frame(cbind(Tab2Ann, Tab2L1, Tab2Trans), stringsAsFactors = FALSE, check.names = FALSE)

rownames(Tab2Uni) <- RowName


Tab2Uni$Loc <- sapply(Tab2Uni$Loc, function(x) paste(unique(unlist(strsplit(x, split = ";"))), collapse = ";"))

Tab2Uni$Gene <- sapply(Tab2Uni$Gene, function(x) paste(unique(unlist(strsplit(x, split = ";"))), collapse = ";"))

write.table(Tab2Uni, file = paste0("All.merge.", Thres, ".xls.uniq.loc"), sep = "\t", quote = FALSE, col.names = NA)


#Tab2 <- Tab[names(sort(num[num>=2], decreasing=TRUE)), ]
#
#write.table(Tab2, file = "All.merge.R5.S2.xls", sep = "\t", quote = FALSE, col.names = NA)
#
#
#Tab2 <- Tab[names(sort(num[num>=5], decreasing=TRUE)), ]
#
#write.table(Tab2, file = "All.merge.R5.S5.xls", sep = "\t", quote = FALSE, col.names = NA)

