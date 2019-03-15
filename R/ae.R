# ' ae1.R
# ' Created date: 2019/3/12
# ' author: mariko ohtsuka
# Main section ------
# create dataframe for output
output_ae1_csv <- data.frame(matrix(rep(NA, length(kOutputColnames)), nrow=1))[numeric(0), ]
temp_N[3] <- nrow(ae)
#' ### n=`r temp_N[3]`
output_ae1_csv <- rbind(output_ae1_csv, temp_N)
colnames(output_ae1_csv) <- kOutputColnames
output_ae1_csv <- ConvertFactor(output_ae1_csv)
output_name <- "縦郭気腫"
#' ## `r output_name`
temp_colname <- "AE_mediastinal_emphysema"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "喀血"
#' ## `r output_name`
temp_colname <- "AE_hemoptysis"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "低酸素症_Grade"
#' ## `r output_name`
temp_colname <- "AE_hypoxia"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "呼吸困難_Grade"
#' ## `r output_name`
temp_colname <- "AE_dyspnea"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "気管支痙攣"
#' ## `r output_name`
temp_colname <- "AE_bronc_spasm"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "心房細動"
#' ## `r output_name`
temp_colname <- "AE_AF"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "術中の心肺停止"
#' ## `r output_name`
temp_colname <- "AE_cardiac_arrest"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "出血"
#' ## `r output_name`
temp_colname <- "AE_bleeding"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "その他_有害事象名"
#' ## `r output_name`
temp_colname <- "AE_oher"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "その他_有害事象Grade"
#' ## `r output_name`
temp_colname <- "AE_other_grade"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , output_name)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
# output csv
write.csv(output_ae1_csv, paste0(output_path, "/ae1.csv"), row.names=F, fileEncoding = "cp932", na="")

