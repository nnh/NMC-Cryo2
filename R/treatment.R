# ' treatment.R
# ' Created date: 2019/3/14
# ' author: mariko ohtsuka
# install.packages("table1")

treatment$table_header <- " "
#' # 5.3. 治療
#' ## 治療内容
table1(~ APC + snare + mechanical_debulking + treat_other| table_header, data=treatment, overall=F)
#' # 5.4. 有効性
#' ## 5.4.1. 手技的成功率
treatment$procedure_success <- ifelse(treatment$aw_stenosis == "あり" | treatment$sputum == "あり"
                                      | treatment$stent_success == "あり", 1, 0)
procedure_success_columns <- c("Number of Patients", "Number of Successes", "Percent", "Lower 95% CL", "Upper 95% CL")
procedure_success <- data.frame(matrix(rep(NA, length(procedure_success_columns)), nrow=1))
colnames(procedure_success) <- procedure_success_columns
procedure_success[ , 1] <- nrow(treatment)
procedure_success[ , 2] <- nrow(subset(treatment, procedure_success == 1))
procedure_success[ , 3] <- round(procedure_success_n / procedure_success_all * 100, digits=1)
procedure_success_95CI <- binom.test(procedure_success_n, procedure_success_all)
procedure_success[ , 4] <- procedure_success_95CI$conf.int[1]
procedure_success[ , 5] <- procedure_success_95CI$conf.int[2]
kable(procedure_success)
table1(~ aw_stenosis + stent_success + sputum | table_header, data=treatment, overall=F)
#' ## 5.4.2.術中SpO2が95以下となった被験者の割合
