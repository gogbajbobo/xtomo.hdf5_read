library(h5)
library(matrixStats)
library(purrr)

file <- h5file('Downloads/9d9313a5-1b1c-4d1a-8e6b-892f5dfd0b6a.h5', mode = 'r')
dark <- file['dark']
data <- file['data']

darkDSNames <- list.datasets(dark)

openDS <- function(dsName) return(openDataSet(file, dsName, type = 'integer'))
readDs <- function(ds) return(readDataSet(ds, dspace = selectDataSpace(ds)))

darkSets <- map(darkDSNames, openDS)
darkSetsData <- map(darkSets, readDs)

darkIntensity <- sum(rowMedians(matrix(unlist(darkSetsData), ncol = length(darkSetsData), byrow = TRUE)))

dataDSNames <- list.datasets(data)

prefix <- '/data/'
dataDSNumbers <- sort(as.integer(gsub(prefix, '', dataDSNames)))

dsNameFn <- function(n) return(paste(prefix, n, sep=''))
dataDSNamesSorted <- unlist(map(dataDSNumbers, dsNameFn))

dataSets <- map(dataDSNamesSorted, openDS)

sumValues <- function(ds) return(sum(readDs(ds)))
dataSetsIntensities <- unlist(map(dataSets, sumValues))

plotData <- dataSetsIntensities - darkIntensity
plot(plotData, type='l')

h5close(file)
