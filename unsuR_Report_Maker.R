# Open this script in RStudio and click "Source" to start report generation process.

# About: https://cneskey.github.io/unsuR/

# Set the working directory to wherever this .R file is.
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Install/Load package manager pacman then others.
if (!require("pacman")) install.packages("pacman")
source("src/packs.R")
library(pacman)
p_load(char=packages, install = TRUE, character.only = FALSE)

# Render the markdown file with flex dashboard.
start_time <- Sys.time()

# Optionally replace the .png logo and icon with your own a you please.
render(output_dir = "output/",
       "src/unsuR_Report.Rmd",
       flex_dashboard(logo = "../imgs/emblem.png",
                      favicon = "../imgs/favicon.png",
                      theme="united",
                      self_contained = TRUE,
                      source_code = "https://github.com/cneskey/unsuR"))

# Launch the report.
browseURL("output/unsuR_Report.html")

# Clean Up
unlink("src/*_temp.xlsx")

# Return time stats
end_time <- Sys.time()

start_time
end_time
duration <- end_time-start_time
duration
