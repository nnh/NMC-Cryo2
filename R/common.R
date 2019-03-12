# Common processing
# Created date: 2019/3/12
# Author: mariko ohtsuka
# Constant section ------
kNA_lb <- -1
kCTCAEGrade <- c(1:5)
kExclude_FAS_flag <- 1
kExclude_SAS_flag <- 2
# The following constants are used for common_function.R
kCount <- "count"
kPercentage <- "percentage"
kN_index <- 1
kNA_index <- 2
kDfIndex <- 3
kOutputColnames <- c("title", "grade", kCount, kPercentage)
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
  temp_seq <- substr(csv_list[i], 1, 1)
  temp_objectname <- switch (temp_seq,
    "1" = "registration",
    "2" = "treatment",
    "3" = "end",
    "4" = "sae"
  )
  assign(temp_objectname, read.csv(paste0(input_path, "/", csv_list[i]), as.is=T, fileEncoding="cp932",
                                   stringsAsFactors=F))
  assign(temp_objectname, get(temp_objectname)[-1, ])
}
all_qualification <- as.numeric(nrow(registration))
# All registration
#all_ptdata <- ptdata
#all_registration <- as.numeric(nrow(all_ptdata))
