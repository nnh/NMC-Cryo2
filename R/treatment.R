# ' treatment.R
# ' Created date: 2019/3/14
# ' author: mariko ohtsuka
# install.packages("table1")
EditTreatment <- function(input_all_count, input_count, output_columns){
  output_df <- data.frame(matrix(rep(NA, length(output_columns)), nrow=1))
  colnames(output_df) <- output_columns
  output_df[ , 1] <- input_all_count
  output_df[ , 2] <- input_count
  output_df[ , 3] <- round(output_df[ , 2] / output_df[ , 1] * 100, digits=1)
  output_df_95CI <- binom.test(output_df[ , 2] , output_df[ , 1])
  output_df[ , 4] <- output_df_95CI$conf.int[1]
  output_df[ , 5] <- output_df_95CI$conf.int[2]
  print(kable(output_df))
  cat("  \n")
}
kGroup_A <- "あり"
kGroup_B <- "なし"
output_treatment_csv <- data.frame(matrix(rep(NA, length(kOutputColnames)), nrow=1))[numeric(0), ]
output_treatment_csv <- rbind(output_treatment_csv, temp_N)
colnames(output_treatment_csv) <- kOutputColnames
output_treatment_csv <- ConvertFactor(output_treatment_csv)
treatment$table_header <- " "
#' # 5.3. 治療
#' ## 治療内容
#table1(~ APC + snare + mechanical_debulking + treat_other| table_header, data=treatment, overall=F)
output_name <- "APC"
#' ## `r output_name`
temp_colname <- "APC"
temp_res_list <- Convert_aggregate_to_DF(output_treatment_csv ,treatment[ ,temp_colname] , output_name)
output_treatment_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "高周波スネア"
#' ## `r output_name`
temp_colname <- "snare"
temp_res_list <- Convert_aggregate_to_DF(output_treatment_csv ,treatment[ ,temp_colname] , output_name)
output_treatment_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "硬性鏡管による器械的減量_mechanical_debulking"
#' ## `r output_name`
temp_colname <- "mechanical_debulking"
temp_res_list <- Convert_aggregate_to_DF(output_treatment_csv ,treatment[ ,temp_colname] , output_name)
output_treatment_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "treat_other"
#' ## `r output_name`
temp_colname <- "treat_other"
temp_res_list <- Convert_aggregate_to_DF(output_treatment_csv ,treatment[ ,temp_colname] , output_name)
output_treatment_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")

#' # 5.4. 有効性
#' ## 5.4.1. 手技的成功率
treatment$procedure_success <- ifelse(treatment$aw_stenosis == "あり" | treatment$sputum == "あり"
                                      | treatment$stent_success == "あり", 1, 0)
procedure_success_columns <- c("Number of Patients", "Number of Successes", "Percent", "Lower 95% CL", "Upper 95% CL")
temp_all_count <- nrow(treatment)
temp_count <- nrow(subset(treatment, procedure_success == 1))
#+ results='asis'
EditTreatment(temp_all_count, temp_count, procedure_success_columns)
#table1(~ aw_stenosis + stent_success + sputum | table_header, data=treatment, overall=F)
output_name <- "気道狭窄の改善"
#' ## `r output_name`
temp_colname <- "aw_stenosis"
temp_res_list <- Convert_aggregate_to_DF(output_treatment_csv ,treatment[ ,temp_colname] , output_name)
output_treatment_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "ステント留置の成功"
#' ## `r output_name`
temp_colname <- "stent_success"
temp_res_list <- Convert_aggregate_to_DF(output_treatment_csv ,treatment[ ,temp_colname] , output_name)
output_treatment_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
output_name <- "貯留した痰の排泄"
#' ## `r output_name`
temp_colname <- "sputum"
temp_res_list <- Convert_aggregate_to_DF(output_treatment_csv ,treatment[ ,temp_colname] , output_name)
output_treatment_csv <- temp_res_list[[1]]
kable(KableList(temp_res_list[[2]]), format="markdown", align="r")
#' ## 5.4.2.術中SpO2が95以下となった被験者の割合
procedure_success_columns <- c("Number of Patients", "SpO2≦95%", "Percent", "Lower 95% CL", "Upper 95% CL")
temp_all_count <- nrow(treatment)
temp_count <- nrow(subset(treatment, SpO2_95 == "はい"))
#+ results='asis'
EditTreatment(temp_all_count, temp_count, procedure_success_columns)
#' # 5.5. 安全性
#' ## 5.5.1. 術中出血割合（手術開始から24時間以内の出血）
#' ### 中等度以上の術中出血割合
procedure_success_columns <- c("Number of Patients", "Hemorrhage", "Percent", "Lower 95% CL", "Upper 95% CL")
temp_all_count <- nrow(treatment)
treatment$bleeding_temp <- ifelse(treatment$bleeding  == "中等度；24時間以内に30-300 cc の出血"
                                  | treatment$bleeding == "重度；24時間以内に>300-400 cc の出血", "Yes", "No")
temp_count <- nrow(subset(treatment, bleeding_temp == "Yes"))
#+ results='asis'
EditTreatment(temp_all_count, temp_count, procedure_success_columns)
#' ### 術中出血の詳細
table1(~ bleeding | table_header, data=treatment, overall=F)
label(treatment$bleeding_temp) <- "bleeding"
#' ### ステント有無別の出血割合
#table1(~ stent | bleeding_temp, data=treatment, overall=F)
stent_presence <- subset(treatment, stent == "あり")
stent_absence <- subset(treatment, stent == "なし")
treatment_stent <- Aggregate_Group(stent_presence, stent_absence, "bleeding_temp", c("bleeding", kCount, kPercentage))
treatment_stent[[5]]
