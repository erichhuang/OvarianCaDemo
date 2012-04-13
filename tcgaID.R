tcgaID <- function(id){
  mySplit <- strsplit(id, "-", fixed=T)
  l <- length(mySplit[[1]])
  
  myRes <- list()
  
  myRes$Project <- sapply(mySplit, "[[", 1)
  
  if( any(myRes$Project != "TCGA") ){
    stop("Does not appear to be a TCGA ID")
  }
  
  if( l > 7 ){
    stop("Too many arguments for a TCGA ID")
  }
  
  if( l > 1){
    myRes$TSS <- sapply(mySplit, "[[", 2)
    if( l > 2 ){
      myRes$Participant <- sapply(mySplit, "[[", 3)
      if( l > 3 ){
        myRes$Sample <- substr(sapply(mySplit, "[[", 4), 1, 2)
        myRes$Vial <- substr(sapply(mySplit, "[[", 4), 3, 3)
        if( l > 4 ){
          myRes$Portion <- substr(sapply(mySplit, "[[", 5), 1, 2)
          myRes$Analyte <- substr(sapply(mySplit, "[[", 5), 3, 3)
          if( l > 5 ){
            myRes$Plate <- sapply(mySplit, "[[", 6)
            if ( l > 6 ){
              myRes$Center <- sapply(mySplit, "[[", 7)
            }
          }
        }
      }
    }
  }
  
  return(myRes)
  
}