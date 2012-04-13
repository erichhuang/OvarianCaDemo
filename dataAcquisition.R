# dataAquisition.R

require(synapseClient)
require(Biobase)
require(affy)

### BRING IN THE DATA FROM SAGE COMMONS REPOSITORY
ovarianCaEnt <- loadEntity(273923)