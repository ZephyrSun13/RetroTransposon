
Tab <- read.table(file = "All.merge.xls", sep = "\t", row.names = 13, header = TRUE, check.names = FALSE)

num <- apply(Tab[, grep("trans", names(Tab)[-(1:13)], invert = TRUE, value = TRUE)], 1, function(x) length(which(x>5)))

Tab2 <- Tab[names(sort(num[num>0], decreasing=TRUE)), ]

write.table(Tab2, file = "All.merge.5.xls", sep = "\t", quote = FALSE, col.names = NA)

