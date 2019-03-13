# Main section ------
# create dataframe for output
output_ae1_csv <- data.frame(matrix(rep(NA, length(kOutputColnames)), nrow=1))[numeric(0), ]
kOutputAEColnames <- c("item", "grade", "count", "per")
output_ae2_csv <- data.frame(matrix(rep(NA, length(kOutputAEColnames)), nrow=1))[numeric(0), ]
temp_N[3] <- nrow(ae)
#' ### n=`r temp_N[3]`
output_ae1_csv <- rbind(output_ae1_csv, temp_N)
colnames(output_ae1_csv) <- kOutputColnames
output_ae1_csv <- ConvertFactor(output_ae1_csv)
#' ## 縦郭気腫
temp_colname <- "AE_mediastinal_emphysema"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 喀血
temp_colname <- "AE_hemoptysis"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 低酸素症_Grade
temp_colname <- "AE_hypoxia"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 呼吸困難_Grade
temp_colname <- "AE_dyspnea"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 気管支痙攣
temp_colname <- "AE_bronc_spasm"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 心房細動
temp_colname <- "AE_AF"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 術中の心肺停止
temp_colname <- "AE_cardiac_arrest"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 出血
temp_colname <- "AE_bleeding"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## その他_有害事象名
temp_colname <- "AE_oher"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## その他_有害事象Grade
temp_colname <- "AE_other_grade"
temp_res_list <- Convert_aggregate_to_DF(output_ae1_csv ,ae[ ,temp_colname] , temp_colname)
output_ae1_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
# output csv
write.csv(output_ae1_csv, paste0(output_path, "/ae1.csv"), row.names=F, fileEncoding = "cp932", na="")

