**************************************************************************
Program Name : DM.sas
Study Name : NMC-Cryo2
Author : Kato Kiroku
Date : 2019-03-18
SAS version : 9.4
**************************************************************************;


proc datasets library=work kill nolist; quit;

options mprint mlogic symbolgen minoperator;


*^^^^^^^^^^^^^^^^^^^^Current Working Directories^^^^^^^^^^^^^^^^^^^^;

*Find the current working directory;
%macro FIND_WD;

    %local _fullpath _path;
    %let _fullpath=;
    %let _path=;

    %if %length(%sysfunc(getoption(sysin)))=0 %then
      %let _fullpath=%sysget(sas_execfilepath);
    %else
      %let _fullpath=%sysfunc(getoption(sysin));

    %let _path=%substr(&_fullpath., 1, %length(&_fullpath.)
                       -%length(%scan(&_fullpath., -1, '\'))
                       -%length(%scan(&_fullpath., -2, '\')) -2);
    &_path.

%mend FIND_WD;

%let cwd=%FIND_WD;
%put &cwd.;

%inc "&cwd.\program\macro\libname.sas";


proc import datafile="&raw.\症例登録票.csv"
                    out=baseline
                    dbms=csv replace;
run;
data baseline_2;
    set baseline;
    if _N_=1 then delete;
run;
proc sort data=baseline_2; by subjid; run;

proc import datafile="&raw.\治療.csv"
                    out=treatment
                    dbms=csv replace;
run;
data treatment_2;
    set treatment;
    if _N_=1 then delete;
    keep subjid treat_date;
run;
proc sort data=treatment_2; by subjid; run;

data baseline_3;
    merge baseline_2(in=a) treatment_2;
    by subjid;
    if a;
    if treat_date='あり';
run;


%macro COUNT (name, var, title, raw);

    proc freq data=&raw noprint;
        tables &var / out=&name;
    run;

    proc sort data=&name; by &var; run;

    data &name._2;
        format Category $12. Count Percent best12.;
        set &name;
        Category=&var;
        if &var=' ' then Category='MISSING';
        percent=round(percent, 0.1);
        drop &var;
    run;

    data &name._2;
        format Item $60. Category $12. Count Percent best12.;
        set &name._2;
        if _N_=1 then do; item="&title"; end;
    run;

    proc summary data=&name._2;
        var count percent;
        output out=&name._total sum=;
    run;

    data &name._total_2;
        format Item $60. Category $12. Count Percent best12.;
        set &name._total;
        item=' ';
        category='合計';
        keep Item Category Count Percent;
    run;

    data x_&name;
        format Item $60. Category $12. Count Percent best12.;
        set &name._2 &name._total_2;
    run;

%mend COUNT;


%macro IQR (name, var, title, rdata);

    data &rdata._2;
        set &rdata;
        c=input(&var., best12.);
        if c=-1 then delete;
        keep c;
        rename c=&var.;
    run;

    proc means data=&rdata._2 noprint;
        var &var;
        output out=&name n=n mean=mean std=std median=median q1=q1 q3=q3 min=min max=max;
    run;

    data &name._frame;
        format Item $60. Category $12. Count Percent best12.;
        Item=' ';
        Category=' ';
        count=0;
        percent=0;
        output;
    run;

    proc transpose data=&name out=&name._2;
        var n mean std median q1 q3 min max;
    run;

    data x_&name;
        merge &name._frame &name._2;
        if _N_=1 then Item="&title.";
        Category=upcase(_NAME_);
        count=round(col1, 0.1);
        call missing(percent);
        keep Item Category Count Percent;
    run;

%mend IQR;


*年齢;
    data age_baseline;
        set baseline_3;
        current=(input(ic_date, YYMMDD10.));
        birth=(input(birthday, YYMMDD10.));
        age=intck('YEAR', birth, current);
        if (month(current) < month(birth)) then age=age - 1;
        else if (month(current) = month(birth)) and day(current) < day(birth) then age=age - 1;
    run;
    %IQR (age, age, 年齢, age_baseline);

*性別;
    %COUNT (sex, sex, 性別, baseline_3);

*原病_原発性肺がん_腺癌;
    %COUNT (disease, disease, 原病_原発性肺がん_腺癌, baseline_3);

*原病_原発性肺がん_扁平上皮がん;
    %COUNT (VAR6, VAR6, 原病_原発性肺がん_扁平上皮がん, baseline_3);

*原病_原発性肺がん_小細胞がん;
    %COUNT (VAR7, VAR7, 原病_原発性肺がん_小細胞がん, baseline_3);

*原病_原発性肺がん_その他;
    %COUNT (VAR8, VAR8, 原病_原発性肺がん_その他, baseline_3);

*原発性肺がん_その他詳細;
    data bb_baseline;
        set baseline_3;
        if VAR8='該当する';
        if disease_t1 NE ' ';
    run;
    data x_disease_t1;
        format Item $60. Category $12. Count Percent best12.;
        set bb_baseline;
        if _N_=1 then Item='原発性肺がん_その他詳細';
        Category=disease_t1;
        count=.;
        percent=.;
        keep Item Category Count Percent;
    run;

*原病_転移性肺がん;
    %COUNT (VAR9, VAR9, 原病_転移性肺がん, baseline_3);

*転移性肺がんの原発巣;
    data cc_baseline;
        set baseline_3;
        if VAR9='該当する';
        if disease_t3 NE ' ';
    run;
    data x_disease_t3;
        format Item $60. Category $12. Count Percent best12.;
        set cc_baseline;
        if _N_=1 then Item='転移性肺がんの原発巣';
        Category=disease_t3;
        count=.;
        percent=.;
        keep Item Category Count Percent;
    run;

*原病_リンパ腫;
    %COUNT (VAR10, VAR10, 原病_リンパ腫, baseline_3);

*原病_その他の悪性腫瘍;
    %COUNT (VAR11, VAR11, 原病_その他の悪性腫瘍, baseline_3);

*その他の悪性腫瘍_その他詳細;
    data dd_baseline;
        set baseline_3;
        if VAR11='該当する';
        if disease_t2 NE ' ';
    run;
    data x_disease_t2;
        format Item $60. Category $12. Count Percent best12.;
        set dd_baseline;
        if _N_=1 then Item='その他の悪性腫瘍_その他詳細';
        Category=disease_t2;
        count=.;
        percent=.;
        keep Item Category Count Percent;
    run;

*出血傾向;
    %COUNT (bleeding, bleeding, 出血傾向, baseline_3);

*出血傾向ありの場合_詳細;
    data bleeding_baseline;
        set baseline_3;
        if bleeding='あり';
    run;
    data x_bleeding_t1;
        format Item $60. Category $12. Count Percent best12.;
        set bleeding_baseline;
        Item='出血傾向ありの場合_詳細';
        Category=bleeding_t1;
        count=.;
        percent=.;
        keep Item Category Count Percent;
    run;

*抗凝固薬の投与;
    %COUNT (anticoagulation, anticoagulation, 抗凝固薬の投与, baseline_3);

*PS;
    %COUNT (PS, PS, PS (ECOG), baseline_3);

*筋弛緩薬使用;
    %COUNT (muscle_relax, muscle_relax, 筋弛緩薬使用, baseline_3);

*酸素投与;
    %COUNT (oxygen, oxygen, 酸素投与, baseline_3);

*出血傾向ありの場合_詳細;
    data oxy_baseline;
        set baseline_3;
        if oxygen='あり';
    run;
    %IQR (oxygen_L, oxygen_L, 酸素投与ありの場合_酸素投与量_L_分, oxy_baseline);

*SpO2;
    %IQR (Sp02, Sp02, SpO2, baseline_3);



data DM;
    set x_age x_sex x_disease x_VAR6 x_var7 x_var8 x_disease_t1 x_var9 x_disease_t3 x_var10 x_var11 x_disease_t2
    x_bleeding x_bleeding_t1 x_anticoagulation x_PS x_muscle_relax x_oxygen x_oxygen_L x_Sp02;
run;

%ds2csv (data=DM, runmode=b, csvfile=&out.\SAS\DM.csv, labels=N);
