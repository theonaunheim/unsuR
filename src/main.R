# Load libraries into memory
library(plyr)
library(googledrive)
library(ggplot2)
library(scales)
library(reshape2)
library(viridis)
library(httpuv)
library(ggridges)
library(readxl)
library(dplyr)
library(formattable)
library(plotly)
library(stringr)
library(ggbeeswarm)
library(kableExtra)
library(leaflet)
library(clipr)
library(forcats)
library(readr)
library(DT)

# Load source into memory
source("rpert.R")
source("monterlo.R")
source("combos.R")


email <- "DUMMY_STRING"

sheeturl <- "DUMMY_STRING"

scen_gen <- FALSE

simsnum <- rstudioapi::showPrompt(
  title = 'Simulations quantity',
  message = 'Enter the number of simulations desired.
Tip: Run once as-is to test that everything is working ok, then try 10,000 or more.',
  default = "1000")

# Set random number seed for reproducability.
set.seed(3141593)

# Set number of simulation variations (at least 10,000 recommended).
n_perms = simsnum

# Generate combos and load into clipboard (if user answered "Yes")
if(scen_gen) combos()

# Read the data sheets into memory.
gEstimates <- read_excel("downloaded_temp.xlsx", sheet = "api_stage", skip = 10)
gEstimates2 <- read_excel("downloaded_temp.xlsx", sheet = "api_stage_2", skip = 9)
gScope <- read_excel("downloaded_temp.xlsx", sheet = "Scope", skip = 3)
gCommentary <- read_excel("downloaded_temp.xlsx", sheet = "Commentary")
gJournal <- read_excel("downloaded_temp.xlsx", sheet = "Journal")
gSumstats <- read_excel("downloaded_temp.xlsx", sheet = "sumstats")

# Read commentary sheet contents into memory
gCommentaryH <- gCommentary$Subsection
gCommentaryF <- t(gCommentary$Commentary)
colnames(gCommentaryF) <- gCommentaryH
gCommentaryF <- as.data.frame(gCommentaryF)

# Define unique identifier variables
n_scens = length(na.omit(gEstimates$`UID`))
n_bens = length(na.omit(gEstimates2$`Benefit UID`))
n_costs = length(na.omit(gEstimates2$`Known Costs UID`))

# Declare necessary variables
sim_output_A_FRQ <- data.frame()
sim_output_B_FRQ <- data.frame()
sim_output_C_FRQ <- data.frame()
sim_output_A <- data.frame()
sim_output_B <- data.frame()
sim_output_C <- data.frame()

sim_output_B_ICC <- data.frame()
sim_output_C_ICC <- data.frame()

sim_output_B_RCC <- data.frame()
sim_output_C_RCC <- data.frame()

sim_output_Bens <- data.frame()
sim_output_Costs <- data.frame()

# Convert estimates from Frequency Formats to decimal / percentage ----
# Plan A
freq_form <- gEstimates$`Plan A Loss Event Frequency (LEF) Lower Bound`
perc_form <- 1/as.numeric(freq_form)
gEstimates$`Plan A Loss Event Frequency (LEF) Lower Bound` <- perc_form

freq_form <- gEstimates$`Plan A Loss Event Frequency (LEF) Most Likely`
perc_form <- 1/as.numeric(freq_form)
gEstimates$`Plan A Loss Event Frequency (LEF) Most Likely` <- perc_form

freq_form <- gEstimates$`Plan A Loss Event Frequency (LEF) Upper Bound`
perc_form <- 1/as.numeric(freq_form)
gEstimates$`Plan A Loss Event Frequency (LEF) Upper Bound` <- perc_form

# Plan B
freq_form <- gEstimates$`Plan B Loss Event Frequency (LEF) Lower Bound`
perc_form <- 1/as.numeric(freq_form)
gEstimates$`Plan B Loss Event Frequency (LEF) Lower Bound` <- perc_form

freq_form <- gEstimates$`Plan B Loss Event Frequency (LEF) Most Likely`
perc_form <- 1/as.numeric(freq_form)
gEstimates$`Plan B Loss Event Frequency (LEF) Most Likely` <- perc_form

freq_form <- gEstimates$`Plan B Loss Event Frequency (LEF) Upper Bound`
perc_form <- 1/as.numeric(freq_form)
gEstimates$`Plan B Loss Event Frequency (LEF) Upper Bound` <- perc_form

# Plan C
freq_form <- gEstimates$`Plan C Loss Event Frequency (LEF) Lower Bound`
perc_form <- 1/as.numeric(freq_form)
gEstimates$`Plan C Loss Event Frequency (LEF) Lower Bound` <- perc_form

freq_form <- gEstimates$`Plan C Loss Event Frequency (LEF) Most Likely`
perc_form <- 1/as.numeric(freq_form)
gEstimates$`Plan C Loss Event Frequency (LEF) Most Likely` <- perc_form

freq_form <- gEstimates$`Plan C Loss Event Frequency (LEF) Upper Bound`
perc_form <- 1/as.numeric(freq_form)
gEstimates$`Plan C Loss Event Frequency (LEF) Upper Bound` <- perc_form

# Simulate Plan A FREQUENCY (Monte Carlo)
sim_output_A_FRQ <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = rep(1,n_scens),
  mn = gEstimates$`Plan A Loss Event Frequency (LEF) Lower Bound`,
  ml = gEstimates$`Plan A Loss Event Frequency (LEF) Most Likely`,
  mx = gEstimates$`Plan A Loss Event Frequency (LEF) Upper Bound`,
  out_var = sim_output_A_FRQ)

# Simulate Plan B FREQUENCY (Monte Carlo)
sim_output_B_FRQ <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = rep(1,n_scens),
  mn = gEstimates$`Plan B Loss Event Frequency (LEF) Lower Bound`,
  ml = gEstimates$`Plan B Loss Event Frequency (LEF) Most Likely`,
  mx = gEstimates$`Plan B Loss Event Frequency (LEF) Upper Bound`,
  out_var = sim_output_B_FRQ)

# Simulate Plan C FREQUENCY (Monte Carlo)
sim_output_C_FRQ <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = rep(1,n_scens),
  mn = gEstimates$`Plan C Loss Event Frequency (LEF) Lower Bound`,
  ml = gEstimates$`Plan C Loss Event Frequency (LEF) Most Likely`,
  mx = gEstimates$`Plan C Loss Event Frequency (LEF) Upper Bound`,
  out_var = sim_output_C_FRQ)

# Load Frequency means into memory
FRQ_mean <- colMeans(sim_output_A_FRQ)
FRQ_mean <- cbind(FRQ_mean,colMeans(sim_output_B_FRQ))
FRQ_mean <- cbind(FRQ_mean,colMeans(sim_output_C_FRQ))
FRQ_mean <- as.data.frame(FRQ_mean)
colnames(FRQ_mean) <- c("LEF-A","LEF-B","LEF-C")

# Simulate Plan A MAGNITUDE & given FREQUENCY simulated in previous step (Monte Carlo)
sim_output_A <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = FRQ_mean$`LEF-A`,
  mn =  gEstimates$`Plan A Loss Magnitude (LM) Lower Bound`,
  ml = gEstimates$`Plan A Loss Magnitude (LM) Most Likely`,
  mx = gEstimates$`Plan A Loss Magnitude (LM) Upper Bound`,
  out_var = sim_output_A)

# Simulate Plan B MAGNITUDE & given FREQUENCY simulated in previous step (Monte Carlo)
sim_output_B <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = FRQ_mean$`LEF-B`,
  mn = gEstimates$`Plan B Loss Magnitude (LM) Lower Bound`,
  ml = gEstimates$`Plan B Loss Magnitude (LM) Most Likely`,
  mx = gEstimates$`Plan B Loss Magnitude (LM) Upper Bound`,
  out_var = sim_output_B)

# Simulate Plan C MAGNITUDE & given FREQUENCY simulated in previous step (Monte Carlo)
sim_output_C <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = FRQ_mean$`LEF-C`,
  mn = gEstimates$`Plan C Loss Magnitude (LM) Lower Bound`,
  ml = gEstimates$`Plan C Loss Magnitude (LM) Most Likely`,
  mx = gEstimates$`Plan C Loss Magnitude (LM) Upper Bound`,
  out_var = sim_output_C)

# Simulate Initial Control Costs
# Simulate Plan B  initial CONTROL Costs
sim_output_B_ICC <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = rep(1,n_scens),
  mn = gEstimates$`Plan B Initial Control Cost Lower Bound`,
  ml = gEstimates$`Plan B Initial Control Cost Most Likely`,
  mx = gEstimates$`Plan B Initial Control Cost Upper Bound`,
  out_var = sim_output_B_ICC)

# Simulate Plan C initial CONTROL Costs
sim_output_C_ICC <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = rep(1,n_scens),
  mn = gEstimates$`Plan C Initial Control Cost Lower Bound`,
  ml = gEstimates$`Plan C Initial Control Cost Most Likely`,
  mx = gEstimates$`Plan C Initial Control Cost Upper Bound`,
  out_var = sim_output_C_ICC)

# Simulate Recurring Control Costs
# Simulate Plan B recurring CONTROL Costs
sim_output_B_RCC <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = rep(1,n_scens),
  mn = gEstimates$`Plan B Recurring Control Cost Lower Bound`,
  ml = gEstimates$`Plan B Recurring Control Cost Most Likely`,
  mx = gEstimates$`Plan B Recurring Control Cost Upper Bound`,
  out_var = sim_output_B_RCC)

# Simulate Plan C recurring CONTROL Costs
sim_output_C_RCC <- monterlo(
  n_scens = n_scens,
  n_perms = n_perms,
  prb = rep(1,n_scens),
  mn = gEstimates$`Plan C Recurring Control Cost Lower Bound`,
  ml = gEstimates$`Plan C Recurring Control Cost Most Likely`,
  mx = gEstimates$`Plan C Recurring Control Cost Upper Bound`,
  out_var = sim_output_C_RCC)

# Simulate Known Benefits
sim_output_Bens <- monterlo(
  n_scens = n_bens,
  n_perms = n_perms,
  prb = as.numeric(na.omit(gEstimates2$`Benefits Probability`)),
  mn = as.integer(na.omit(gEstimates2$`Benefits Lower Bound`)),
  ml = as.integer(na.omit(gEstimates2$`Benefits Most Likely`)),
  mx = as.integer(na.omit(gEstimates2$`Benefits Upper Bound`)),
  out_var = sim_output_Bens)

# Simulated Known Costs
sim_output_Costs <- monterlo(
  n_scens = n_costs,
  n_perms = n_perms,
  prb = rep(1,n_scens),
  mn = gEstimates2$`Known Costs Lower Bound`,
  ml = gEstimates2$`Known Costs Most Likely`,
  mx = gEstimates2$`Known Costs Upper Bound`,
  out_var = sim_output_Costs)

# Add header rows to simulation outputs
# headers for loss outputs
colnames(sim_output_A) <- as.character(paste("Risk-",1:n_scens,sep = ""))
colnames(sim_output_B) <- as.character(paste("Risk-",1:n_scens,sep = ""))
colnames(sim_output_C) <- as.character(paste("Risk-",1:n_scens,sep = ""))

# headers for initial control cost outputs
colnames(sim_output_B_ICC) <- as.character(paste("Risk-",1:n_scens,sep = ""))
colnames(sim_output_C_ICC) <- as.character(paste("Risk-",1:n_scens,sep = ""))

# headers for recurring control cost outputs
colnames(sim_output_B_RCC) <- as.character(paste("Risk-",1:n_scens,sep = ""))
colnames(sim_output_C_RCC) <- as.character(paste("Risk-",1:n_scens,sep = ""))

# headers for benefit outputs
colnames(sim_output_Bens) <- as.character(paste("benefit-",1:n_bens,sep = ""))

# headers for benefit outputs
colnames(sim_output_Costs) <- as.character(paste("cost-",1:n_costs,sep = ""))

# Load the mean of all columns into memory
# load Loss Magnitude (LM) means into memory
risk_mean <- colMeans(sim_output_A)
risk_mean <- cbind(risk_mean,colMeans(sim_output_B))
risk_mean <- cbind(risk_mean,colMeans(sim_output_C))
risk_mean <- as.data.frame(risk_mean)
colnames(risk_mean) <- c("PLAN-A","PLAN-B","PLAN-C")

# load Initial control cost (ICC) means into memory
control_mean <- colMeans(sim_output_B_ICC)
control_mean <- cbind(control_mean,colMeans(sim_output_C_ICC))

# load recurring control cost (RCC) means into memory
control_mean <- cbind(control_mean,colMeans(sim_output_B_RCC))
control_mean <- cbind(control_mean,colMeans(sim_output_C_RCC))

# convert control means object to dataframe and name columns
control_mean <- as.data.frame(control_mean)
colnames(control_mean) <- c("ICC-B","ICC-C","RCC-B","RCC-C")

# load Benefit means into memory
Benefit_mean <- colMeans(sim_output_Bens)
Benefit_mean <- as.data.frame(Benefit_mean)

# eval recurring
Benefit_mean <- cbind(Benefit_mean,Benefit_mean*gEstimates2$`Benefits Recurring_Ben`)
colnames(Benefit_mean) <- c("Benefit","Recurring_Benefit")

# load Costs means into memory
Cost_mean <- colMeans(sim_output_Costs)
Cost_mean <- as.data.frame(Cost_mean)

# eval recurring
Cost_mean <- cbind(Cost_mean,Cost_mean*gEstimates2$`Known Costs Recurring Expense`)
colnames(Cost_mean) <- c("Cost","Recurring_Cost")

# Eval ----
evals <- data.frame()
REL_AvB <- risk_mean$`PLAN-A` - risk_mean$`PLAN-B`
REL_AvC <- risk_mean$`PLAN-A` - risk_mean$`PLAN-C`
ROSI_AvB <- na_if(na_if(REL_AvB/control_mean$`ICC-B`-1,"Inf"),"-Inf")
ROSI_AvC <- na_if(na_if(REL_AvC/control_mean$`ICC-C`-1,"Inf"),"-Inf")
NET_AvB <- na_if(na_if(ROSI_AvB*control_mean$`ICC-B`,"Inf"),"-Inf")
NET_AvC <- na_if(na_if(ROSI_AvC*control_mean$`ICC-C`,"Inf"),"-Inf")

# Forcasts
# Year 1
# A: Benefits - Costs - Loss_magn.
NET_A_Year1 <- sum(Benefit_mean$Benefit) - sum(Cost_mean$Cost) - risk_mean$`PLAN-A`
# B: Benefits_init - Costs_init - Loss Magn. - Ctrl_cost_init + Reduction_In_exp_losses
NET_B_Year1 <- sum(Benefit_mean$Benefit) - sum(Cost_mean$Cost) - risk_mean$`PLAN-B` - control_mean$`ICC-B` + REL_AvB
# C: Benefits_init - Costs_init - Loss Magn. - Ctrl_cost_init + Reduction_In_exp_losses
NET_C_Year1 <- sum(Benefit_mean$Benefit) - sum(Cost_mean$Cost) - risk_mean$`PLAN-C` - control_mean$`ICC-C` + REL_AvC

# Year 2
# A: (((Benefits+Benefits_recurring)-(Costs-Costs_Recurring))-(Loss_Magn*2))
NET_A_Year2 <- (((sum(Benefit_mean$Benefit)+sum(Benefit_mean$Benefit_Recurring)) - (sum(Cost_mean$Cost-sum(Cost_mean$Cost_Recurring))) - risk_mean$`PLAN-A`*2))

# B: (((Benefits+Benefits_recurring)-(Costs-Costs_Recurring))-(Loss_Magn*2-Initial_Ctrl_Cost+ReductionEL*2))-Ctrl_Costs_recurring
NET_B_Year2 <- (((sum(Benefit_mean$Benefit)+sum(Benefit_mean$Benefit_Recurring)) - (sum(Cost_mean$Cost-sum(Cost_mean$Cost_Recurring))) - risk_mean$`PLAN-B`*2 - control_mean$`ICC-B` + REL_AvB*2)) - control_mean$`RCC-B`

# C: (((Benefits+Benefits_recurring)-(Costs-Costs_Recurring))-(Loss_Magn*2-Initial_Ctrl_Cost+ReductionEL*2))-Ctrl_Costs_recurring
NET_C_Year2 <- (((sum(Benefit_mean$Benefit)+sum(Benefit_mean$Benefit_Recurring)) - (sum(Cost_mean$Cost-sum(Cost_mean$Cost_Recurring))) - risk_mean$`PLAN-C`*2 - control_mean$`ICC-C` + REL_AvC*2)) - control_mean$`RCC-C`

# Year 3
# A: (Benefit+Benefit_recurring*2)-(Cost_initial+Cost_recurring*2)-Loss_magn*3-Ctrl_Cost_init)-Ctrl_Cost_recurring*2
NET_A_Year3 <- (((sum(Benefit_mean$Benefit)+sum(Benefit_mean$Benefit_Recurring*2)) - (sum(Cost_mean$Cost-sum(Cost_mean$Cost_Recurring*2))) - risk_mean$`PLAN-A`*3 - 0)) - 0

# B: (Benefit+Benefit_recurring*2)-(Cost_initial+Cost_recurring*2)-Loss_magn*3-Ctrl_Cost_init+ReductionEL*3)-Ctrl_Cost_recurring*2
NET_B_Year3 <- (((sum(Benefit_mean$Benefit)+sum(Benefit_mean$Benefit_Recurring*2)) - (sum(Cost_mean$Cost-sum(Cost_mean$Cost_Recurring*2))) - risk_mean$`PLAN-A`*3 - control_mean$`ICC-B` + REL_AvB*3)) - control_mean$`RCC-B`*2

# C: (Benefit+Benefit_recurring*2)-(Cost_initial+Cost_recurring*2)-Loss_magn*3-Ctrl_Cost_init+ReductionEL*3)-Ctrl_Cost_recurring*2
NET_C_Year3 <- (((sum(Benefit_mean$Benefit)+sum(Benefit_mean$Benefit_Recurring*2)) - (sum(Cost_mean$Cost-sum(Cost_mean$Cost_Recurring*2))) - risk_mean$`PLAN-A`*3 - control_mean$`ICC-C` + REL_AvB*3)) - control_mean$`RCC-C`*2

evals <- cbind(risk_mean,
               control_mean,
               REL_AvB,
               REL_AvC,
               ROSI_AvB,
               ROSI_AvC,
               NET_AvB,
               NET_AvC,
               NET_A_Year1,
               NET_B_Year1,
               NET_C_Year1,
               NET_A_Year2,
               NET_B_Year2,
               NET_C_Year2,
               NET_A_Year3,
               NET_B_Year3,
               NET_C_Year3
)

# Year 1 Expected
Expected_Benefits_y1 <- sum(Benefit_mean$Benefit)
Expected_Implementation_Costs_y1 <- sum(Cost_mean$Cost)

# Plan A
Expected_Losses_A_y1 <- mean(risk_mean$`PLAN-A`)
Expected_Prevented_Loss_A_y1 <- 0
Expected_Net_A_y1 <- mean(NET_A_Year1)

# Plan B
Expected_Losses_B_y1 <- mean(risk_mean$`PLAN-B`)
Expected_Mitigation_Costs_B_y1 <- mean(control_mean$`ICC-B`)
Expected_Prevented_Loss_B_y1 <- mean(REL_AvB)
Expected_Net_B_y1 <- mean(NET_B_Year1)

# Plan C
Expected_Losses_C_y1 <- mean(risk_mean$`PLAN-C`)
Expected_Mitigation_Costs_C_y1 <- mean(control_mean$`ICC-C`)
Expected_Prevented_Loss_C_y1 <- mean(REL_AvC)
Expected_Net_C_y1 <- mean(NET_C_Year1)

# Year 2 Expected
Expected_Benefits_y2 <- sum(Benefit_mean$Benefit)+sum(Benefit_mean$Recurring_Benefit)
Expected_Implementation_Costs_y2 <- sum(Cost_mean$Cost)+sum(Cost_mean$Recurring_Cost)

# Plan A
Expected_Losses_A_y2 <- mean(risk_mean$`PLAN-A`)*2
Expected_Prevented_Loss_A_y2 <- 0
Expected_Net_A_y2 <- mean(NET_A_Year2)

# Plan B
Expected_Losses_B_y2 <- mean(risk_mean$`PLAN-B`)*2
Expected_Mitigation_Costs_B_y2 <- mean(control_mean$`ICC-B`)+mean(control_mean$`RCC-B`)
Expected_Prevented_Loss_B_y2 <- mean(REL_AvB)*2
Expected_Net_B_y2 <- mean(NET_B_Year2)

# Plan C
Expected_Losses_C_y2 <- mean(risk_mean$`PLAN-C`)*2
Expected_Mitigation_Costs_C_y2 <- mean(control_mean$`ICC-C`)+mean(control_mean$`RCC-C`)
Expected_Prevented_Loss_C_y2 <- mean(REL_AvC)*2
Expected_Net_C_y2 <- mean(NET_C_Year2)

# Year 3 Expected
Expected_Benefits_y3 <- sum(Benefit_mean$Benefit)+sum(Benefit_mean$Recurring_Benefit)*2
Expected_Implementation_Costs_y3 <- sum(Cost_mean$Cost)+sum(Cost_mean$Recurring_Cost)*2

# Plan A
Expected_Losses_A_y3 <- mean(risk_mean$`PLAN-A`)*3
Expected_Prevented_Loss_A_y3 <- 0
Expected_Net_A_y3 <- mean(NET_A_Year3)

# Plan B
Expected_Losses_B_y3 <- mean(risk_mean$`PLAN-B`)*3
Expected_Mitigation_Costs_B_y3 <- mean(control_mean$`ICC-B`)+mean(control_mean$`RCC-B`)*2
Expected_Prevented_Loss_B_y3 <- mean(REL_AvB)*3
Expected_Net_B_y3 <- mean(NET_B_Year3)

# Plan C
Expected_Losses_C_y3 <- mean(risk_mean$`PLAN-C`)*3
Expected_Mitigation_Costs_C_y3 <- mean(control_mean$`ICC-C`)+mean(control_mean$`RCC-C`)*2
Expected_Prevented_Loss_C_y3 <- mean(REL_AvC)*3
Expected_Net_C_y3 <- mean(NET_C_Year3)

Expected_Mitigation_Costs_A_y1 <-0
Expected_Mitigation_Costs_A_y2 <-0
Expected_Mitigation_Costs_A_y3 <-0

# Build forcast tables
# Plan A 3-year table
Plan_A_Expected <- as.data.frame(rbind(
  Expected_Benefits_y1,
  Expected_Implementation_Costs_y1,
  Expected_Losses_A_y1,
  Expected_Mitigation_Costs_A_y1,
  Expected_Prevented_Loss_A_y1,
  Expected_Net_A_y1))
Plan_A_Expected$Year_2 <- rbind(
  Expected_Benefits_y2,
  Expected_Implementation_Costs_y2,
  Expected_Losses_A_y2,
  Expected_Mitigation_Costs_A_y2,
  Expected_Prevented_Loss_A_y2,
  Expected_Net_A_y2)
Plan_A_Expected$Year_3 <- rbind(
  Expected_Benefits_y3,
  Expected_Implementation_Costs_y3,
  Expected_Losses_A_y3,
  Expected_Mitigation_Costs_A_y3,
  Expected_Prevented_Loss_A_y3,
  Expected_Net_A_y3)

# Plan B 3-year table
Plan_B_Expected <- as.data.frame(rbind(
  Expected_Benefits_y1,
  Expected_Implementation_Costs_y1,
  Expected_Losses_B_y1,
  Expected_Mitigation_Costs_B_y1,
  Expected_Prevented_Loss_B_y1,
  Expected_Net_B_y1))
Plan_B_Expected$Year_2 <- rbind(
  Expected_Benefits_y2,
  Expected_Implementation_Costs_y2,
  Expected_Losses_B_y2,
  Expected_Mitigation_Costs_B_y2,
  Expected_Prevented_Loss_B_y2,
  Expected_Net_B_y2)
Plan_B_Expected$Year_3 <- rbind(
  Expected_Benefits_y3,
  Expected_Implementation_Costs_y3,
  Expected_Losses_B_y3,
  Expected_Mitigation_Costs_B_y3,
  Expected_Prevented_Loss_B_y3,
  Expected_Net_B_y3)

# Plan c 3-year table
Plan_C_Expected <- as.data.frame(rbind(
  Expected_Benefits_y1,
  Expected_Implementation_Costs_y1,
  Expected_Losses_C_y1,
  Expected_Mitigation_Costs_C_y1,
  Expected_Prevented_Loss_C_y1,
  Expected_Net_C_y1))
Plan_C_Expected$Year_2 <- rbind(
  Expected_Benefits_y2,
  Expected_Implementation_Costs_y2,
  Expected_Losses_C_y2,
  Expected_Mitigation_Costs_C_y2,
  Expected_Prevented_Loss_C_y2,
  Expected_Net_C_y2)
Plan_C_Expected$Year_3 <- rbind(
  Expected_Benefits_y3,
  Expected_Implementation_Costs_y3,
  Expected_Losses_C_y3,
  Expected_Mitigation_Costs_C_y3,
  Expected_Prevented_Loss_C_y3,
  Expected_Net_C_y3)

# Name rows and columns
row.names(Plan_A_Expected) <- c("Benefits","Costs","Loss","Mitigation Costs","Prevented Loss","Net")
colnames(Plan_A_Expected) <- c("Year 1", "Year 2","Year 3")
row.names(Plan_B_Expected) <- c("Benefits","Costs","Loss","Mitigation Costs","Prevented Loss","Net")
colnames(Plan_B_Expected) <- c("Year 1", "Year 2","Year 3")
row.names(Plan_C_Expected) <- c("Benefits","Costs","Loss","Mitigation Costs","Prevented Loss","Net")
colnames(Plan_C_Expected) <- c("Year 1", "Year 2","Year 3")

#Data Prep for visualisations
# Density Plot 1
df <- t(risk_mean)
df.m <- melt(df)
colnames(df.m) <- as.character(c("plan","risk","loss"))
mu <- ddply(df.m, "plan", summarise, grp.mean=mean(loss))
df.m$plan <- factor(df.m$plan, levels = c("PLAN-C", "PLAN-B", "PLAN-A"))
mu$plan <- factor(mu$plan, levels = c("PLAN-C", "PLAN-B", "PLAN-A"))

# Density Plot 2 (costs)
df2 <- t(Cost_mean)
df.m2 <- melt(sim_output_Costs)
colnames(df.m2) <- as.character(c("cost_name","cost_amt"))
mu2 <- ddply(df.m2, "cost_name", summarise, grp.mean=mean(cost_amt))
df.m2$cost_name <- factor(df.m2$cost_name)
mu2$cost_name <- factor(mu2$cost_name)

# Density Plot 3 (bens)
df3 <- t(Benefit_mean)
df.m3 <- melt(sim_output_Bens)
colnames(df.m3) <- as.character(c("ben_name","ben_amt"))
mu3 <- ddply(df.m3, "ben_name", summarise, grp.mean=mean(ben_amt))
df.m3$ben_name <- factor(df.m3$ben_name)
mu3$cost_name <- factor(mu3$ben_name)

# Density Plot 4A (per risk) @@@
df4A <- t(sim_output_A)
df.m4A <- melt(df4A)
colnames(df.m4A) <- as.character(c("risk","iter","loss"))
mu4A <- ddply(df.m4A, "risk", summarise, grp.mean=mean(loss))

# Density Plot 4B (per risk) @@@
df4B <- t(sim_output_B)
df.m4B <- melt(df4B)
colnames(df.m4B) <- as.character(c("risk","iter","loss"))
mu4B <- ddply(df.m4B, "risk", summarise, grp.mean=mean(loss))

# Density Plot C (per risk) @@@
df4C <- t(sim_output_C)
df.m4C <- melt(df4C)
colnames(df.m4C) <- as.character(c("risk","iter","loss"))
mu4C <- ddply(df.m4C, "risk", summarise, grp.mean=mean(loss))

# For per plan ECDF
loss_ecdf <- ddply(df.m, c("plan"), mutate, ecdf = ecdf(loss)(unique(loss))*length(loss))
# To invert the per plan ECDF
loss_ecdf_2 <- ddply(loss_ecdf, "plan", mutate, ecdf = scale(ecdf,center=min(ecdf),scale=diff(range(ecdf))))

# Net amounts and graphs
Nets <- rbind(Plan_A_Expected[6,], Plan_B_Expected[6,], Plan_C_Expected[6,])
row.names(Nets) <- c("PLAN-A", "PLAN-B", "PLAN-C")
Netsm <- melt(t(Nets),id = 0)
Netsm$col <-  ifelse(Netsm$value>0, TRUE, FALSE)
Netsm$value <- as.numeric(Netsm$value)
colnames(Netsm) <- c("Year", "Plan", "Net", "Sign")

# Define headers of "Scope" sheet.
colnames(gScope) <- c("Included","Excluded","Included","Excluded","Included","Excluded","Included","Excluded","Included","Excluded")

# Output a sheet of my risks, estimates, and sim outputs per risk
ests_plus_simouts <- cbind(gEstimates,risk_mean)
write_csv(ests_plus_simouts, "../output/ests_and_means.csv")