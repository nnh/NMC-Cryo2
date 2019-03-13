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
temp_N <- c("Number of patients", NA, all_qualification, all_qualification / all_qualification * 100)
output_demog_csv <- rbind(output_demog_csv, temp_N)
colnames(output_demog_csv) <- kOutputColnames
output_demog_csv <- ConvertFactor(output_demog_csv)
#output_demog_csv[ ,kCount] <- as.character(output_demog_csv[ ,kCount])
#'
output_name <- "年齢"
#' ## `r output_name`
# Calculate age
registration[ ,kBirth_date_colname] <- as.Date(registration[ ,kBirth_date_colname], origin="1899-12-30")
registration[ ,kRegist_date_colname] <- as.Date(registration[ ,kRegist_date_colname], origin="1899-12-30")
for (i in 1:nrow(registration)) {
  registration[i, "age"] <- Calc_age(registration[i, kRegist_date_colname], registration[i, kBirth_date_colname])
}
temp_colname <- "age"
temp_res_list <- Convert_summary_to_DF(output_demog_csv, registration[ ,temp_colname], output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "性別"
#' ## `r output_name`
temp_colname <- "sex"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , output_name)
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
disease_title <- c("原発性肺がん_腺癌", "原発性肺がん_扁平上皮がん", "原発性肺がん_小細胞がん", "原発性肺がん_その他",
                   "転移性肺がん", "リンパ腫", "その他の悪性腫瘍")
for (i in 1:4) {
  temp_colname <- paste0("demog_disease_", i)
  temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , disease_title[i])
  output_demog_csv <- temp_res_list[[1]]
  print(kable(KableList(temp_res_list[[2]]), format="markdown", align="r"))
}
output_name <- "原発性肺がん_その他詳細"
#' ## `r output_name`
temp_colname <- "disease_t1"
assign(temp_colname, subset(registration, (registration[ ,temp_colname] != "" & registration[ ,"demog_disease_4"] == "あり"))[ ,temp_colname])
get(temp_colname)
temp_df <- data.frame(matrix(rep(NA), ncol=length(kOutputColnames), nrow=length(get(temp_colname))))
colnames(temp_df) <- kOutputColnames
temp_df[ ,1] <- output_name
temp_df[ ,2] <- get(temp_colname)
temp_df[ ,3] <- 1
output_demog_csv <- rbind(output_demog_csv, temp_df)
output_name <- "転移性肺がん"
#' ### `r output_name`
temp_colname <- paste0("demog_disease_", "5")
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "転移性肺がんの原発巣"
#' ### `r output_name`
temp_colname <- "disease_t3"
assign(temp_colname, subset(registration, registration[ ,temp_colname] != "")[ ,temp_colname])
get(temp_colname)
temp_df <- data.frame(matrix(rep(NA), ncol=length(kOutputColnames), nrow=length(get(temp_colname))))
colnames(temp_df) <- kOutputColnames
temp_df[ ,1] <- output_name
temp_df[ ,2] <- get(temp_colname)
temp_df[ ,3] <- 1
output_demog_csv <- rbind(output_demog_csv, temp_df)
output_name <- "リンパ腫"
#' ### `r output_name`
temp_colname <- paste0("demog_disease_", "6")
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "その他の悪性腫瘍"
#' ### `r output_name`
temp_colname <- paste0("demog_disease_", "7")
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "その他の悪性腫瘍_その他詳細"
#' ### `r output_name`
temp_colname <- "disease_t2"
assign(temp_colname, subset(registration, registration[ ,temp_colname] != "")[ ,temp_colname])
get(temp_colname)
temp_df <- data.frame(matrix(rep(NA), ncol=length(kOutputColnames), nrow=length(get(temp_colname))))
colnames(temp_df) <- kOutputColnames
temp_df[ ,1] <- output_name
temp_df[ ,2] <- get(temp_colname)
temp_df[ ,3] <- 1
output_demog_csv <- rbind(output_demog_csv, temp_df)
output_name <- "出血傾向の有無"
#' ## `r output_name`
temp_colname <- "bleeding"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "出血傾向の有無_有の場合はその詳細"
#' ## `r output_name`
temp_bleeding_t1_df <- subset(registration, bleeding == "あり")
#subset(temp_bleeding_t1_df, bleeding_t1 != "")[,"bleeding_t1"]
temp_colname <- "bleeding_t1"
assign(temp_colname, subset(temp_bleeding_t1_df, temp_bleeding_t1_df[ ,temp_colname] != "")[ ,temp_colname])
get(temp_colname)
temp_df <- data.frame(matrix(rep(NA), ncol=length(kOutputColnames), nrow=length(get(temp_colname))))
colnames(temp_df) <- kOutputColnames
temp_df[ ,1] <- output_name
temp_df[ ,2] <- get(temp_colname)
temp_df[ ,3] <- 1
output_demog_csv <- rbind(output_demog_csv, temp_df)
output_name <- "抗凝固薬の投与の有無"
#' ## `r output_name`
temp_colname <- "anticoagulation"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "PS(ECOG)"
#' ## `r output_name`
temp_colname <- "PS"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "筋弛緩薬使用"
#' ## `r output_name`
temp_colname <- "muscle_relax"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "酸素投与"
#' ## `r output_name`
temp_colname <- "oxygen"
temp_res_list <- Convert_aggregate_to_DF(output_demog_csv ,registration[ ,temp_colname] , output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "酸素投与量（L/分)"
#' ## `r output_name`
temp_oxygen_L_df <- subset(registration, oxygen == "あり")
temp_oxygen_L_df$num_oxygen_L <- as.numeric(temp_oxygen_L_df$oxygen_L)
temp_colname <- "num_oxygen_L"
temp_res_list <- Convert_summary_to_DF(output_demog_csv, temp_oxygen_L_df[ ,temp_colname], output_name)
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "Sp02"
#' ## `r output_name`
registration$num_SpO2 <- as.numeric(registration$Sp02)
# -1 -> NA
registration$num_SpO2 <- ifelse(registration$num_SpO2 == -1, NA, registration$num_SpO2)
temp_colname <- "num_SpO2"
temp_res_list <- Convert_summary_to_DF(output_demog_csv, registration[ ,temp_colname], "SpO2")
output_demog_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
# output csv
write.csv(output_demog_csv, paste0(output_path, "/demog.csv"), row.names=F, fileEncoding = "cp932", na="")
