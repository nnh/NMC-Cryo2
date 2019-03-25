# output html files
# Created date: 2019/3/12
# Author: mariko ohtsuka

# library, function section ------
# install.packages("rmarkdown")
# install.packages("sjlabelled")
library(rmarkdown)
library(knitr)
library(sjlabelled)
library(dplyr)
library(table1)
knitr::opts_chunk$set(echo=F, comment=NA)
# all treatment
save_wd <- getwd()
setwd(paste0(save_wd, "/R"))
source("./common.R", local=T)
source("./common_function.R", local=T)
render("./demog.R", output_dir=output_path, output_file="demog.html")
render("./ae.R", output_dir=output_path, output_file="ae.html")
render("./treatment.R", output_dir=output_path, output_file="treatment.html")
render("./ae2.R", output_dir=output_path, output_file="ae2.html")
setwd(save_wd)
