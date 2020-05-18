# Run this script to start report generation process.
library(rmarkdown)
library(flexdashboard)
render("unsuR_Report.Rmd",
       flex_dashboard(logo = "imgs/emblem.png",
                      favicon = "imgs/favicon.png",
                      theme="united",
                      self_contained = TRUE,
                      source_code = "https://github.com/cneskey/unsuR"))