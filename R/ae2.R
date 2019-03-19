# ' ae2.R
# ' Created date: 2019/3/15
# ' author: mariko ohtsuka
output_ae2_csv <- data.frame(matrix(rep(NA, length(kOutputColnames)), nrow=1))[numeric(0), ]
output_ae2_csv <- rbind(output_ae2_csv, temp_N)
colnames(output_ae2_csv) <- kOutputColnames
output_ae2_csv <- ConvertFactor(output_ae2_csv)
#' # 5.5.2. 有害事象の発現頻度(術中〜術後)
#' ## 低酸素症
#' ### ベースライン
registration$table_header <- " "
table1(~ oxygen| table_header, data=registration, overall=F)
#' #### 酸素投与有の場合の酸素量
kable(KableList(demog_oxygen_l), format="markdown", align="r")
#' #### 酸素投与有の場合の酸素量 #17
kable(KableList(demog_oxygen_l_2), format="markdown", align="r")
#' #### SpO2
kable(KableList(demog_spo2), format="markdown", align="r")
#' #### Grade
table1(~ hypoxia| table_header, data=registration, overall=F)
#' ### 評価時
ae$table_header <- " "
table1(~ AE_oxygen| table_header, data=ae, overall=F)
output_name <- "酸素投与有の場合の酸素量"
#' #### `r output_name`
temp_ae_oxygen_L_df <- subset(ae, AE_oxygen == "あり")
temp_ae_oxygen_L_df$num_oxygen_L <- as.numeric(temp_ae_oxygen_L_df$AE_oxygen_L)
temp_colname <- "num_oxygen_L"
temp_res_list <- Convert_summary_to_DF(output_ae2_csv, temp_ae_oxygen_L_df[ ,temp_colname], output_name)
output_ae2_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "Sp02"
#' #### `r output_name`
ae$num_SpO2 <- as.numeric(ae$AE_spO2_v)
# -1 -> NA
ae$num_SpO2 <- ifelse(ae$num_SpO2 == kNA_lb, NA, ae$num_SpO2)
temp_colname <- "num_SpO2"
temp_res_list <- Convert_summary_to_DF(output_ae2_csv, ae[ ,temp_colname], "SpO2")
output_ae2_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
table1(~ AE_hypoxia| table_header, data=ae, overall=F)
#' ## 呼吸困難Grade
#' ### ベースライン
table1(~ dyspnea| table_header, data=registration, overall=F)
#' ### 最終評価時
table1(~ AE_dyspnea| table_header, data=ae, overall=F)
