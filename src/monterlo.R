# monterlo
# Monte carlo simulation framework
# ref: https://sites.google.com/view/coreyneskey/

monterlo <- function( n_scens, n_perms, prb, mn,ml,mx, out_var){
  
  for (i in 1:n_scens) {
    LEF <- prb[i]
    LMmin <- mn[i]
    LMmin <- as.numeric(sub("\\$ ","",sub(",","",LMmin)))
    
    LMmax <- mx[i]
    LMmax <- as.numeric(sub("\\$ ","",sub(",","",LMmax)))
    
    LMmlk <- ml[i]
    LMmlk <- as.numeric(sub("\\$ ","",sub(",","",LMmlk)))
    for (j in 1:n_perms) {
      out_var[j,i] <- as.numeric(paste(rbinom(n=1,size=1,p=LEF) * rpert(1,LMmin,LMmax,LMmlk,4)))}}
  return(out_var)
}

