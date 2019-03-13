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
  registration[ ,temp_colname] <- ifelse(registration[ ,col_index] == 1, "あり", "なし")
}
#+ results='asis'
#' ### 原発性肺がん
disease_title <- c("腺癌", "扁平上皮がん", "小細胞がん", "その他", "転移性肺がん", "リンパ腫", "その他の悪性腫瘍")
for (i in 1:4) {
  temp_colname <- paste0("demog_disease_", i)
  temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , disease_title[i])
  output_demog_csv <- temp_res_list[[1]]
  print(kable(KableList(temp_res_list[[2]]), format="markdown", align="r"))
}
#' ### 原発性肺がん_その他詳細
temp_colname <- "disease_t1"
assign(temp_colname, subset(registration, registration[ ,temp_colname] != "")[ ,temp_colname])
get(temp_colname)
temp_df <- data.frame(matrix(rep(NA), ncol=length(kOutputColnames), nrow=length(get(temp_colname))))
colnames(temp_df) <- kOutputColnames
temp_df[ ,1] <- temp_colname
temp_df[ ,2] <- get(temp_colname)
output_demog_csv <- rbind(output_demog_csv, temp_df)
#disease_t1 <- subset(registration, disease_t1 != "")[,"disease_t1"]
#disease_t1
#temp_df <- data.frame(matrix(rep(NA), ncol=length(kOutputColnames), nrow=length(disease_t1)))
#colnames(temp_df) <- kOutputColnames
#temp_df[ ,1] <- "disease_t1"
#temp_df[ ,2] <- disease_t1
#output_demog_csv <- rbind(output_demog_csv, temp_df)
#' ### 転移性肺がん
temp_colname <- paste0("demog_disease_", "5")
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , "転移性肺がん")
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ### 転移性肺がんの原発巣
#subset(registration, disease_t3 != "")[,"disease_t3"]
temp_colname <- "disease_t3"
assign(temp_colname, subset(registration, registration[ ,temp_colname] != "")[ ,temp_colname])
get(temp_colname)
temp_df <- data.frame(matrix(rep(NA), ncol=length(kOutputColnames), nrow=length(get(temp_colname))))
colnames(temp_df) <- kOutputColnames
temp_df[ ,1] <- temp_colname
temp_df[ ,2] <- get(temp_colname)
output_demog_csv <- rbind(output_demog_csv, temp_df)
#' ### リンパ腫
temp_colname <- paste0("demog_disease_", "6")
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , "リンパ腫")
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ### その他の悪性腫瘍
temp_colname <- paste0("demog_disease_", "7")
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , "その他の悪性腫瘍")
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ### その他の悪性腫瘍_その他詳細
#subset(registration, disease_t2 != "")[,"disease_t2"]
temp_colname <- "disease_t2"
assign(temp_colname, subset(registration, registration[ ,temp_colname] != "")[ ,temp_colname])
get(temp_colname)
temp_df <- data.frame(matrix(rep(NA), ncol=length(kOutputColnames), nrow=length(get(temp_colname))))
colnames(temp_df) <- kOutputColnames
temp_df[ ,1] <- temp_colname
temp_df[ ,2] <- get(temp_colname)
output_demog_csv <- rbind(output_demog_csv, temp_df)
#' ## 出血傾向の有無
temp_colname <- "bleeding"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , temp_colname)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ### 有の場合はその詳細
temp_bleeding_t1_df <- subset(registration, bleeding == "あり")
#subset(temp_bleeding_t1_df, bleeding_t1 != "")[,"bleeding_t1"]
temp_colname <- "bleeding_t1"
assign(temp_colname, subset(temp_bleeding_t1_df, temp_bleeding_t1_df[ ,temp_colname] != "")[ ,temp_colname])
get(temp_colname)
temp_df <- data.frame(matrix(rep(NA), ncol=length(kOutputColnames), nrow=length(get(temp_colname))))
colnames(temp_df) <- kOutputColnames
temp_df[ ,1] <- temp_colname
temp_df[ ,2] <- get(temp_colname)
output_demog_csv <- rbind(output_demog_csv, temp_df)
#' ## 抗凝固薬の投与の有無
temp_colname <- "anticoagulation"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , temp_colname)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## PS(ECOG)
temp_colname <- "PS"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , temp_colname)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 筋弛緩薬使用
temp_colname <- "muscle_relax"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , temp_colname)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 酸素投与
temp_colname <- "oxygen"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , temp_colname)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 酸素投与量（L/分)
temp_oxygen_L_df <- subset(registration, oxygen == "あり")
temp_oxygen_L_df$num_oxygen_L <- as.numeric(temp_oxygen_L_df$oxygen_L)
temp_colname <- "num_oxygen_L"
temp_res_list <- Convert_summary_to_DF(output_demog_csv, temp_oxygen_L_df[ ,temp_colname], "oxygen_L")
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## Sp02
registration$num_SpO2 <- as.numeric(registration$Sp02)
# -1 -> NA
registration$num_SpO2 <- ifelse(registration$num_SpO2 == -1, NA, registration$num_SpO2)
temp_colname <- "num_SpO2"
temp_res_list <- Convert_summary_to_DF(output_demog_csv, registration[ ,temp_colname], "SpO2")
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
# output csv
write.csv(output_demog_csv, paste0(output_path, "/demog.csv"), row.names=F, fileEncoding = "cp932", na="")
