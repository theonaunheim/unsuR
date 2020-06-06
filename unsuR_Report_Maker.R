# Run this script to start report generation process.
library(rmarkdown)
library(flexdashboard)
  
# Render the markdown file with flex dashboard.
start_time <- Sys.time()

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
unlink("*_temp.xlsx")

# Return time stats
end_time <- Sys.time()

start_time
end_time
duration <- end_time-start_time
duration