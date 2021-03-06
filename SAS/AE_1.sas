**************************************************************************
Program Name : AE_1.sas
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


proc import datafile="&raw.\最終評価.csv"
                    out=evaluation
                    dbms=csv replace;
run;

data evaluation_2;
    set evaluation;
    if _N_=1 then delete;
run;

proc sort data=evaluation_2; by subjid; run;

data evaluation_2;
    set evaluation_2;
    by subjid;
    if not first.subjid then delete;
run;

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

data evaluation_3;
    merge evaluation_2(in=a) treatment_2;
    by subjid;
    if a;
    if treat_date='あり';
run;


%macro COUNT (name, var, title, raw, number);

    proc freq data=&raw noprint;
        tables &var / out=&name;
    run;

    proc sort data=&name; by &var; run;

    data &name._2;
        format Category $12. Count Percent best12.;
        set &name;
        Category=&var;
        if &var=' ' then Category='MISSING';
        if Category='あり' then sort=1;
        if Category='なし' then sort=2;
        percent=round(percent, 0.1);
        %if &var=AE_bleeding %then %do;
            if category=:'出血無' then sort=1;
            else if category=:'軽度' then sort=2;
            else if category=:'中等度' then sort=3;
            else if category=:'重度' then sort=4;
            drop category;
        %end;
        drop &var;
    run;

    proc sort data=&name._2; by sort; run;

    %if not (&var in (AE_hypoxia AE_dyspnea AE_bleeding)) %then %do;
        data &name._frame;
            format Category $12.;
            Category='あり'; sort=1; output;
            Category='なし'; sort=2; output;
        run;
    %end;
    %if &var in (AE_hypoxia AE_dyspnea) %then %do;
        data &name._frame;
            format Category $12.;
            do i=&number; 
                Category=input(i, $12.); output;
            end;
        run;
    %end;
    %if &var=AE_bleeding %then %do;
        data &name._frame;
            format Category $12.;
            Category='出血無'; sort=1; output;
            Category='軽度'; sort=2; output;
            Category='中等度'; sort=3; output;
            Category='重度'; sort=4; output;
        run;
    %end;

    %if not (&var in (AE_hypoxia AE_dyspnea)) %then %do;
    proc sort data=&name._frame; by sort; run;
    data &name._2;
        format Item $60. Category $12. Count Percent best12.;
        merge &name._frame &name._2;
        by sort;
        if count=. then count=0;
        if percent=. then percent=0;
        if _N_=1 then do; item="&title"; end;
    run;
    %end;
    %if &var in (AE_hypoxia AE_dyspnea) %then %do;
    data &name._2;
        format Item $60. Category $12. Count Percent best12.;
        merge &name._frame &name._2;
        by category;
        if count=. then count=0;
        if percent=. then percent=0;
        if _N_=1 then do; item="&title"; end;
        drop i;
    run;
    %end;

    proc summary data=&name._2;
        var count;
        output out=&name._total sum=;
    run;

    data &name._total_2;
        format Item $60. Category $12. Count Percent best12.;
        set &name._total;
        item=' ';
        category='合計';
        call missing(percent);
        keep Item Category Count Percent;
    run;

    data x_&name;
        format Item $60. Category $12. Count Percent best12.;
        set &name._2 &name._total_2;
        drop sort;
    run;

%mend COUNT;


*縦郭気腫;
%COUNT (AE_mediastinal_emphysema, AE_mediastinal_emphysema, 縦郭気腫, evaluation_3);

*喀血;
%COUNT (AE_hemoptysis, AE_hemoptysis, 喀血, evaluation_3);

*低酸素症 (SpO2 90%以下);
%COUNT (AE_hypoxia, AE_hypoxia, 低酸素症_Grade, evaluation_3, %str(0, 2 to 5));

*呼吸困難;
%COUNT (AE_dyspnea, AE_dyspnea, 呼吸困難_Grade, evaluation_3, 1 to 5);

*気管支痙攣;
%COUNT (AE_bronc_spasm, AE_bronc_spasm, 気管支痙攣, evaluation_3);

*心房細動;
%COUNT (AE_AF, AE_AF, 心房細動, evaluation_3);

*術中の心肺停止;
%COUNT (AE_cardiac_arrest, AE_cardiac_arrest, 術中の心肺停止, evaluation_3);

*出血 (手術開始24時間後〜day7) の有無 (軽度、中等度、重度);
%COUNT (AE_bleeding, AE_bleeding, 出血, evaluation_3, );

*その他 (詳細, grade);
/*%COUNT (AE_oher, AE_oher, その他, evaluation_3);*/


data AE_1;
    set x_AE_mediastinal_emphysema x_AE_hemoptysis x_AE_hypoxia x_AE_dyspnea x_AE_bronc_spasm
    x_AE_AF x_AE_cardiac_arrest x_AE_bleeding;
run;

%ds2csv (data=AE_1, runmode=b, csvfile=&out.\SAS\AE_1.csv, labels=N);
