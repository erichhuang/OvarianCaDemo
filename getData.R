

require(synapseClient)

## PULL DOWN THE EXPRESSION U133A LAYER
ovExpr <- loadEntity(273923)


qry <- synapseQuery(paste("SELECT id, name FROM layer WHERE parentId=='", propertyValue(ovExpr, "parentId"), "'", sep=""))


#####
## GRAB THE MAGE-TAB FILES
#####
mageLayers <- qry[ grep("mage-tab", qry$layer.name), ]
mageLayers <- mageLayers[grep(annotValue(ovExpr, "platformName"), tolower(gsub("-", "", gsub("_", "", mageLayers$layer.name, fixed=T), fixed=T))), ]
thisMage <- mageLayers$layer.id[2]

m <- downloadEntity(thisMage)

mageTemp <- tempfile()
dir.create(mageTemp)
setwd(mageTemp)
system(paste("tar -xvf", file.path(m$cacheDir, m$files)))
theseFiles <- list.files(mageTemp, full.names=T, recursive=T)

mf <- read.delim(theseFiles[ grep("sdrf", theseFiles)], as.is=T)

normMat <- ovExpr$objects$normMat

tmpMap <- mf$Extract.Name
names(tmpMap) <- mf$Array.Data.File

colnames(normMat) <- tmpMap[colnames(normMat)]

ovExpr <- deleteObject(ovExpr, "normMat")
ovExpr <- addObject(ovExpr, normMat)
ovExpr <- storeEntity(ovExpr)
## NOW UPDATED WITH THE CORRECT COLUMN NAMES TO MAP TO CLINICAL DATA


#####
## GRAB THE CLINICAL DATA
#####
qryClin <- qry[ grep("clinical", qry$layer.name), ]
qryClin <- qryClin[-grep("intgen", qryClin$layer.name), ]


clinEnt <- downloadEntity(qryClin$layer.id)

myTemp <- tempfile()
dir.create(myTemp)
setwd(myTemp)
system(paste("tar -xvf", file.path(clinEnt$cacheDir, clinEnt$files)))
these <- list.files(myTemp, full.names=T)

clinAll <- lapply(as.list(these), function(x){
  read.delim(x, as.is=T)
})
names(clinAll) <- sub(".txt", "", basename(these))

clinFinal <- createEntity(Layer(list(name = "Clinical Data",
                                     parentId = propertyValue(ovExpr, "parentId"),
                                     type="C")))

annotValue(clinFinal, "repository") <- "TCGA"
annotValue(clinFinal, "species") <- "Homo sapiens"
annotValue(clinFinal, "tissue") <- "Ovarian"
annotValue(clinFinal, "disease") <- "Cancer"

clinFinal <- addObject(clinFinal, list(clinAll=clinAll))
clinFinal <- storeEntity(clinFinal)
clinFinal
## SYNAPSE ID: 274110

