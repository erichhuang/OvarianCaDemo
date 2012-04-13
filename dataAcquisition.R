# dataAquisition.R

require(synapseClient)
require(Biobase)
require(affy)
require(mg.hgu133a.db) # Brig Mecham's custom mappings for SCR workflow datasets

### BRING IN THE DATA FROM SAGE COMMONS REPOSITORY
ovarianCaEnt <- loadEntity(273923)
ovarianCaMat <- ovarianCaEnt$objects$normMat
###

### ANNOTATE SCR CUSTOM FEATURES TO GENE SYMBOLS
# someProbes <- rownames(ovarianCaMat)[1:100]
# hsym <- as.character(mg.hgu133aSYMBOL)
# foo <- hsym[someProbes]
