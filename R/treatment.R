# ' treatment.R
# ' Created date: 2019/3/14
# ' author: mariko ohtsuka
# install.packages("table1")
library(table1)

treatment$table_header <- " "
#' # 5.3. 治療
#' ## 治療内容
table1(~ APC + snare + mechanical_debulking + treat_other| table_header, data=treatment, overall=F)
#' # 5.4. 有効性
#' ## 5.4.1. 手技的成功率
table1(~ aw_stenosis + stent_success + sputum | table_header, data=treatment, overall=F)

