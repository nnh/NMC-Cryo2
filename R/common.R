# Common processing
# Created date: 2019/3/12
# Author: mariko ohtsuka
# Constant section ------
kNA_lb <- -1
kCTCAEGrade <- c(1:5)
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
    "症例登録票.csv" = "rawdata_registration",
    "治療.csv" = "rawdata_treatment",
    "最終評価.csv" = "rawdata_ae",
    "重症な有害事象.csv" = "rawdata_sae"
  )
  temp_csv <- read.csv(paste0(input_path, "/", csv_list[i]), as.is=T, fileEncoding="cp932",
                                   stringsAsFactors=F, na.strings="")
  temp_label <- paste0(temp_objectname, "_labels")
  assign(temp_label, as.matrix(temp_csv)[1, ])
  temp_csv <- temp_csv[-1, ]
  assign(temp_objectname, temp_csv)
}
# FAS
treatment <- subset(rawdata_treatment, treat_date == "あり")
treatment <- set_label(treatment, rawdata_treatment_labels)
registration <- subset(rawdata_registration, subjid %in% treatment$subjid)
registration <- set_label(registration, rawdata_registration_labels)
ae <- subset(rawdata_ae, subjid %in% treatment$subjid)
ae <- set_label(ae, rawdata_ae_labels)
# Delete duplicate rows
ae <- ae %>% dplyr::distinct(subjid, .keep_all=T)
sae <- subset(rawdata_sae, subjid %in% treatment$subjid)
all_qualification <- as.numeric(nrow(registration))
# N
number_of_patients <- paste0("n=", all_qualification, " (", all_qualification / all_qualification * 100, "%)")
#' ### `r number_of_patients`
temp_N <- c("Number of cases", NA, all_qualification, all_qualification / all_qualification * 100)
