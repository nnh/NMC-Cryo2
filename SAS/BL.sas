**************************************************************************
Program Name : BL.sas
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


proc import datafile="&raw.\治療.csv"
                    out=treatment
                    dbms=csv replace;
run;

data treatment_2;
    set treatment;
    if _N_=1 then delete;
    if treat_date='なし' then delete;
run;


%macro BINOMIAL;

    %global _OBS_;
    data _null_;
        set treatment_2 nobs=obs;
        call symput("_OBS_", obs);
        stop;
    run;

    data ope;
        format bleeding_N;
        set treatment_2;
        if bleeding in: ('中等度', '重度') then bleeding_N=1;
        else if bleeding in: ('出血無', '軽度') then bleeding_N=0;
    run;

    proc freq data=ope noprint;
        tables bleeding_N / out=ope_2;
    run;

    data ope_3;
        set ope_2;
        if bleeding_N=1 then output;
    run;

    data ope_4;
        format Number_of_Patients Bleeding Bleeding_Rate Lower_Conf_Limit_95 Upper_Conf_Limit_95 best12.;
        set ope_3;
        Number_of_Patients=&_OBS_;
        Bleeding=count;
        Bleeding_Rate=round(percent, 0.1);
        call missing(Lower_Conf_Limit_95, Upper_Conf_Limit_95);
        keep Number_of_Patients Bleeding Bleeding_Rate Lower_Conf_Limit_95 Upper_Conf_Limit_95;
    run;

    proc freq data=ope_2 noprint;
        tables bleeding_N / binomial (exact level='1');
        weight count;
        output out=cl binomial;
    run;

    data cl_2;
        format Lower_Conf_Limit_95 Upper_Conf_Limit_95 best12.;
        set cl;
        Lower_Conf_Limit_95=round(XL_BIN, 0.001); 
        Upper_Conf_Limit_95=round(XU_BIN, 0.001);
        keep Lower_Conf_Limit_95 Upper_Conf_Limit_95;
    run;

    data BL;
        merge ope_4 cl_2;
    run;

%mend BINOMIAL;

%BINOMIAL;

%ds2csv (data=BL, runmode=b, csvfile=&out.\SAS\BL.csv, labels=N);


%macro COUNT;

    proc freq data=treatment_2 noprint;
        tables bleeding / out=bleeding_detail;
    run;

    data bleeding_detail_2;
        format sort best12.;
        set bleeding_detail;
        if bleeding=:'出血無' then sort=1;
        else if bleeding=:'軽度' then sort=2;
        else if bleeding=:'中等度' then sort=3;
        else if bleeding=:'重度' then sort=4;
        percent=round(percent, 0.1);
    run;

    proc sort data=bleeding_detail_2; by sort; run;

    data bleeding_detail_frame;
        format sort best12. Bleeding_Volume $24. Count Percent best12.;
        sort=1; Bleeding_Volume='出血無'; output;
        sort=2; Bleeding_Volume='軽度の術中出血'; output;
        sort=3; Bleeding_Volume='中等度の術中出血'; output;
        sort=4; Bleeding_Volume='重度の術中出血'; output;
    run;

    data bleeding_detail_3;
        merge bleeding_detail_frame bleeding_detail_2;
        by sort;
        if count=. then count=0;
        if percent=. then percent=0;
        keep Bleeding_Volume count percent;
    run;

    proc summary data=bleeding_detail_3;
        var count percent;
        output out=bleeding_detail_total sum=;
    run;

    data bleeding_detail_total_2;
        format Bleeding_Volume $24. Count Percent best12.;
        set bleeding_detail_total;
        Bleeding_Volume='合計';
        keep Bleeding_Volume Count Percent;
    run;

    data BL_breakdown;
        set bleeding_detail_3 bleeding_detail_total_2;
    run;

%mend COUNT;

%COUNT;

%ds2csv (data=BL_breakdown, runmode=b, csvfile=&out.\SAS\BL_breakdown.csv, labels=N);


%macro by_STENT;

proc sort data=ope; by stent; run;

proc freq data=ope noprint;
    tables bleeding_N / out=stent;
    by stent;
run;

data stent_2;
    format sort best12.;
    set stent;
    if stent='あり' and bleeding_N=1 then sort=1;
    if stent='あり' and bleeding_N=0 then sort=2;
    if stent='なし' and bleeding_N=1 then sort=3;
    if stent='なし' and bleeding_N=0 then sort=4;
    drop stent bleeding_N;
run;

data stent_frame;
    format Stent Bleeding $12. Bleeding_N sort best12.;
    Stent='有'; Bleeding='有'; Bleeding_N=0; sort=1; output;
    Stent=' '; Bleeding='無'; Bleeding_N=0; sort=2; output;
    Stent='無'; Bleeding='有'; Bleeding_N=0; sort=3; output;
    Stent=' '; Bleeding='無'; Bleeding_N=0; sort=4; output;
run;

proc sort data=stent_2; by sort; run;

data BL_by_stent;
    merge stent_frame stent_2;
    by sort;
    if count=. then count=0;
    if percent=. then percent=0;
    Bleeding_N=count;
    Bleeding_Rate=round(percent, 0.1);
    keep Stent Bleeding Bleeding_N Bleeding_Rate;
run;

%mend by_STENT;

%by_STENT;

%ds2csv (data=BL_by_stent, runmode=b, csvfile=&out.\SAS\BL_by_stent.csv, labels=N);
