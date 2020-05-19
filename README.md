# unsuR: Risk assessment with R

Risk assessment is challenging when data is unavailable, hard to obtain, or costly to process. Organizations often request estimates from experts instead. I present my package unsuR for turning expert estimates into insights for stakeholders. unsuR facilitates estimate collection using GoogleSheets, simulates data using estimates as parameters, and derives probabilistic statements summarizing resulting distributions like “There is a 60% chance of your company losing over $50,000 due to a data breach.” It also produces and automates risk assessment reports. unsuR can inform decisions like whether a $3 million per year next-generation firewall is “worth it” considering preventable annual losses minus tangible costs like pricetag, along with intangibles like how the firewall inconveniences our data scientists whom the firewall unexpectedly blocked from reaching CRAN. Perhaps firewall options range $50-$6 million annually, or maybe finding engineers familiar with an obscure firewall technology adds another $50k in recruiting expenses, leaving us in a bad situation when they quit. Such considerations can and should be part of decision making processes; unsuR makes this possible.

To access the demo dashboard, visit [https://cneskey.github.io/unsuR/unsuR_Report.html](https://cneskey.github.io/unsuR/unsuR_Report.html).

How do I make this?
@ Install R Studio [https://rstudio.com/products/rstudio/#rstudio-desktop](https://rstudio.com/products/rstudio/#rstudio-desktop)
@ Download and extract this repo.
@ Run the Report Maker Script

How do I put in my own data?
@ Make a copy of the Companion Spreadsheet and enter your FAIR scenario components.
@ Run the combo generator.
@ Enter pre-control estimates.
@ Enter post-control estimates.
@ Run the Report Maker Script.
