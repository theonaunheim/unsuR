# unsuR: Risk assessment with R

Risk assessment is challenging when data is unavailable, hard to obtain, or costly to process. Organizations often request estimates from experts instead. I present my package unsuR for turning expert estimates into insights for stakeholders. unsuR facilitates estimate collection using GoogleSheets, simulates data using estimates as parameters, and derives probabilistic statements summarizing resulting distributions like “There is a 60% chance of your company losing over $50,000 due to a data breach.” It also produces and automates risk assessment reports. unsuR can inform decisions like whether a $3 million per year next-generation firewall is “worth it” considering preventable annual losses minus tangible costs like pricetag, along with intangibles like how the firewall inconveniences our data scientists whom the firewall unexpectedly blocked from reaching CRAN. Perhaps firewall options range $50-$6 million annually, or maybe finding engineers familiar with an obscure firewall technology adds another $50k in recruiting expenses, leaving us in a bad situation when they quit. Such considerations can and should be part of decision making processes; unsuR makes this possible.

To access the demo dashboard, visit [https://cneskey.github.io//unsuR/blob/master/src/unsuR_Report.html](https://cneskey.github.io/unsuR/unsuR_Report.html).

How do I make this?
1. Install R Studio [https://rstudio.com/products/rstudio/#rstudio-desktop](https://rstudio.com/products/rstudio/#rstudio-desktop).

2. Download and extract this [https://github.com/cneskey/unsuR/archive/master.zip](https://github.com/cneskey/unsuR/archive/master.zip).

3. Run the Report Maker Script

How do I put in my own data?

1. Make a copy of the [Companion Spreadsheet](https://docs.google.com/spreadsheets/d/1DWB4rdAmUGggkUN0KtVdtyn6E1gZ9j68QifDD8cn2fY/edit#gid=1976081657).

2. Replace contents of the "Scope" tab with your own objects within scope of your assessment.

3. Enter pre-control estimates in tab "Plan-A Valuation".

4. Replace the controls in tab "Plan-B" with your own.

5. Enter post-control estimates in tab "Plan-B Valuation"

6. Replace the controls in tab "Plan-C" with your own alternative control plan under consideration.

5. Enter post-control estimates in tab "Plan-C Valuation"

5. Run the Report Maker Script.
