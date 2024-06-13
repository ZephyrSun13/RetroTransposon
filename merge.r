
#!/usr/bin/R

longerS <- function(ID){

        tt <- unlist(strsplit(ID, split = ";"))

        return(tt[which.max(nchar(tt))])

}

longerL <- function(ID){

        tt <- as.integer(unlist(strsplit(ID, split = ";")))

        return(tt[which.max(tt)])

}


args <- commandArgs(trailingOnly = TRUE)

Results <- read.table(file = args[1], header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

Clusters <- read.table(file = args[2], header = FALSE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

Fac <- factor(Clusters[[1]])

Results <- apply(Results, 2, function(x) tapply(x, Fac, function(y) paste(y, collapse = ";")))

Results[, 14: ncol(Results)] <- apply(Results[, 14: ncol(Results)], 2, function(x) sapply(x, longerL))

#Results[, "Surpport_Reads"] <- sapply(Results[, "Surpport_Reads"], longerL)

Results[, "Sequence"] <- sapply(Results[, "Sequence"], longerS)

write.table(Results, file = paste0(args[1], ".merge.xls"), sep = "\t", row.names = FALSE, quote = FALSE)

