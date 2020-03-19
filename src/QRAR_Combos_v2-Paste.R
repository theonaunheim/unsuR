combos <- function(sheet_path) {
  # QRAR_Combos (description) ####
  # Description: Generates scenarios using FAIR factors from "Scope" tab.
  
  # Load Resources ####
    library(tidyverse)
    library(googledrive)
    library(readxl)
    library(clipr)
    
  # Download data, remove 'excluded' and load into memory ####
    fp <- sheet_path
    scope_components <- (gsheet_name <- drive_get(fp))
    drive_download(scope_components, path = "downloaded_temp", overwrite = TRUE)
    gScope <- read_excel("downloaded_temp.xlsx", sheet = "Scope", skip = 3)
  
    # Remove "excluded"
    gScope_refined <- gScope %>% 
      select(starts_with("Included"))
    
  # Generate all Combos ####
    gScope_refined_combos <- gScope_refined %>%
      cross_df() %>% na.omit()
  
  # Remove forbidden scenarios ####
    # Remove malicious software + accidentally (MSA)
      gScope_refined_combos_rm_MSA <- gScope_refined_combos %>%
      filter(Included...7 != "accidentally" | Included...5 != "malicious software") %>%
      
    # remove external attackers + accidentally (EAA)
      filter(Included...7 != "accidentally" | Included...5 != "external attackers")
  
  # Copy to user's clipboard.
    write_clip(gScope_refined_combos_rm_MSA,
               col.names = FALSE)
    print("You must now paste what has been loaded into clipboard to the scenarios sheet at cell B4.")
} (write_clip(gScope_refined_combos_rm_MSA,
              col.names = FALSE))