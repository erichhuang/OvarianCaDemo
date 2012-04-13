## ANALYSIS CODE FOR OVARIAN TCGA EXPRESSION DATA
#####

require(synapseClient)
require(survival)

## PULL IN FUNCTION TO PARSE TCGA IDS
source("tcgaID.R")

#####
## PULL DOWN THE EXPRESSION U133A LAYER
#####
ovExpr <- loadEntity(273923)
exprMat <- ovExpr$objects$normMat

## MOVE FROM IDS TO PATIENT LEVEL BARCODES
exprID <- tcgaID(id=colnames(exprMat))
exprNames <- sapply(strsplit(colnames(exprMat), "-", fixed=T), function(x){
  blah <- paste(x[1:3], collapse="-")
  blah
})

## SUBSET TO TUMORS ONLY
ide <- exprID$Sample == "01"
exprTumor <- exprMat[, ide]
exprTumorID <- lapply(exprID, "[", ide)
exprTumorNames <- exprNames[ide]

## THERE IS ONE DUPLICATE - WILL JUST TAKE THE FIRST ONE
de <- !duplicated(exprTumorNames)
exprTumor <- exprTumor[, de]
exprTumorID <- lapply(exprTumorID, "[", de)
exprTumorNames <- exprTumorNames[de]
colnames(exprTumor) <- exprTumorNames


#####
## CLINICAL DATA
#####
ovClin <- loadEntity(274110)
clinAll <- ovClin$objects$clinAll
ptDat <- clinAll$clinical_patient_public_ov
rownames(ptDat) <- ptDat$bcr_patient_barcode

## SUBSET TO PATIENTS WITH EXPRESSION DATA
ptDat <- ptDat[colnames(exprTumor), ]

## GRAB PLATINUM SENSITIVE
drug <- clinAll$clinical_drug_public_ov
drug <- drug[ drug$regimen_indication == "ADJUVANT", ]
drug <- drug[ grep("plat", drug$drug_name), ]

#####
## INCLUSION CRITERIA
#####

## ONLY PATIENTS WHO RECIEVED CHEMO
ptAnal <- ptDat[ ptDat$chemo_therapy == "YES", ]
## ONLY PATIENT WITH LATE STAGE (III/IV)
ptAnal <- ptAnal[ ptAnal$tumor_stage %in% c("IIIA", "IIIB", "IIIC", "IV"), ]
## ONLY PATIENT WHO RECIEVED SOME SORT OF PLATINUM BASED 
ptAnal <- ptAnal[ which(rownames(ptAnal) %in% unique(drug$bcr_patient_barcode)), ]
## ONLY PATIENT WHO HAVE TIME TO RECURRENCE INFO
ptAnal <- ptAnal[ ptAnal$days_to_tumor_recurrence != "[Not Available]", ]

## SPECIFY TIME TO RECURRENCE -- DEATH INCLUDED AS AN EVENT
ptAnal$ttr <- as.numeric(ptAnal$days_to_tumor_recurrence)
ptAnal$stat <- ifelse(is.na(ptAnal$ttr), 0, 1)
ptAnal$ttr[is.na(ptAnal$ttr)] <- as.numeric(ptAnal$days_to_last_followup[is.na(ptAnal$ttr)])
ptAnal$ttr[ptAnal$stat == 0 & ptAnal$vital_status == "DECEASED"] <- as.numeric(ptAnal$days_to_death[ptAnal$stat == 0 & ptAnal$vital_status == "DECEASED"])
ptAnal$stat[ptAnal$stat==0] <- ifelse(ptAnal$vital_status[ptAnal$stat==0] == "DECEASED", 1, 0)


## GET RID OF PATIENTS WITHOUT ENOUGH FOLLOWUP
ptAnal <- ptAnal[ !(ptAnal$ttr < (365.25) & ptAnal$stat == 0), ]
## GET RID OF PATIENTS WHO DIED IN FIRST 30 DAY (ASSUME SURGICAL COMPLICATIONS)
ptAnal <- ptAnal[ !(ptAnal$vital_status == "DECEASED" & as.numeric(ptAnal$days_to_last_followup) <= 30), ]


## PLATINUM SENSITIVITY AT 12 MONTHS
ptAnal$platSensitive12mo <- ifelse(ptAnal$ttr >= (365.25), 1, 0)


## SUBSET EXPRESSION DATA DOWN TO THOSE IN CLINICAL MATRIX AFTER INCLUSION CRITERIA APPLIED
exprAnal <- exprTumor[ , rownames(ptAnal)]


rm(list=setdiff(ls(), c("ptAnal", "exprAnal")))

