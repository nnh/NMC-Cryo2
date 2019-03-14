# Common processing
# Created date: 2019/3/12
# Author: mariko ohtsuka
# Constant section ------
kNA_lb <- -1
kCTCAEGrade <- c(1:5)
kExclude_FAS_flag <- 1
kExclude_SAS_flag <- 2
# The following constants are used for common_function.R
kCount <- "Count"
kPercentage <- "Percent"
kN_index <- 1
kNA_index <- 2
kDfIndex <- 3
kOutputColnames <- c("Item", "Category", kCount, kPercentage)
# initialize ------
Sys.setenv("TZ" = "Asia/Tokyo")
parent_path <- "/Users/admin/Desktop/NMC-Cryo2"
# log output path
log_path <- paste0(parent_path, "/log")
if (file.exists(log_path) == F) {
  dir.create(log_path)
}
# Setting of input/output path
input_path <- paste0(parent_path, "/input")
# If the output folder does not exist, create it
output_path <- paste0(parent_path, "/output")
if (file.exists(output_path) == F) {
  dir.create(output_path)
}
# read rawdata
csv_list <- list.files(input_path)
for (i in 1:length(csv_list)) {
  temp_objectname <- switch (csv_list[i],
    "症例登録票.csv" = "registration",
    "治療.csv" = "treatment",
    "最終評価.csv" = "ae",
    "重症な有害事象.csv" = "sae"
  )
  assign(temp_objectname, read.csv(paste0(input_path, "/", csv_list[i]), as.is=T, fileEncoding="cp932",
                                   stringsAsFactors=F, na.strings=""))
  assign(temp_objectname, get(temp_objectname)[-1, ])
}
all_qualification <- as.numeric(nrow(registration))
# All registration
#all_ptdata <- ptdata
#all_registration <- as.numeric(nrow(all_ptdata))
