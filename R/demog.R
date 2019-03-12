# ' demog.R
# ' Created date: 2019/3/12
# ' author: mariko ohtsuka
# Constant section ------
kRegist_date_colname <- "ic_date"
kBirth_date_colname <- "birthday"
kDisease <- "disease"
# Main section ------
# create dataframe for output
output_demog_csv <- data.frame(matrix(rep(NA, length(kOutputColnames)), nrow=1))[numeric(0), ]
# N
number_of_patients <- paste0("n=", all_qualification, " (", all_qualification / all_qualification * 100, "%)")
#' ### `r number_of_patients`
temp_N <- c("Number of patients", NA, number_of_patients, NA)
output_demog_csv <- rbind(output_demog_csv, temp_N)
colnames(output_demog_csv) <- kOutputColnames
output_demog_csv <- ConvertFactor(output_demog_csv)
#output_demog_csv[ ,kCount] <- as.character(output_demog_csv[ ,kCount])
#'
#' ## 年齢
# Calculate age
registration[ ,kBirth_date_colname] <- as.Date(registration[ ,kBirth_date_colname], origin="1899-12-30")
registration[ ,kRegist_date_colname] <- as.Date(registration[ ,kRegist_date_colname], origin="1899-12-30")
for (i in 1:nrow(registration)) {
  registration[i, "age"] <- Calc_age(registration[i, kRegist_date_colname], registration[i, kBirth_date_colname])
}
temp_colname <- "age"
temp_res_list <- Convert_summary_to_DF(output_demog_csv, registration[ ,temp_colname], temp_colname)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 性別
temp_colname <- "sex"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , temp_colname)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 原病
# summary disease 0 ~ 6
for (i in 1:7) {
  col_index <- 4 + i
  temp_colname <- paste0("demog_disease_", i)
  registration[ ,temp_colname] <- ifelse(registration[ ,i] == 1, "あり", "なし")
}
