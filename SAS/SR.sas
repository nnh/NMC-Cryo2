**************************************************************************
Program Name : SR.sas
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
        format success best12.;
        set treatment_2;
        if sputum='あり' then success=1;
        else if aw_stenosis='あり' then success=1;
        else if stent_success='あり' then success=1;
        else success=0;
        keep success sputum aw_stenosis stent_success;
    run;

    proc freq data=ope noprint;
        tables success / out=ope_2;
    run;

    data ope_3;
        set ope_2;
        if success=1 then output;
    run;

    data ope_4;
        format Number_of_Patients Number_of_Successes Success_Rate Lower_Conf_Limit_95 Upper_Conf_Limit_95 best12.;
        set ope_3;
        Number_of_Patients=&_OBS_;
        Number_of_Successes=count;
        Success_Rate=round(percent, 0.1);
        call missing(Lower_Conf_Limit_95, Upper_Conf_Limit_95);
        keep Number_of_Patients Number_of_Successes Success_Rate Lower_Conf_Limit_95 Upper_Conf_Limit_95;
    run;

    proc freq data=ope_2 noprint;
        tables success / binomial (exact level='1');
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

    data SR;
        merge ope_4 cl_2;
    run;

%mend BINOMIAL;

%BINOMIAL;

%ds2csv (data=SR, runmode=b, csvfile=&out.\SAS\SR.csv, labels=N);


%macro COUNT (name, var, title);

    proc freq data=treatment_2 noprint;
        tables &var / out=&name;
    run;

    proc sort data=&name; by &var; run;

    data &name._2;
        format Item $60. Category $12. Count Percent best12.;
        set &name;
        if _N_=1 then item="&title";
        category=&var;     
        if &var=' ' then category='MISSING';
        percent=round(percent, 0.1);
        drop &var;
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
        keep Item Category count percent;
    run;

    data sr_&name;
        set &name._2 &name._total_2;
    run;

%mend COUNT;

*貯留した痰の排泄;
%COUNT (sputum, sputum, 貯留した痰の排泄);

*気道狭窄の改善;
%COUNT (aw_stenosis, aw_stenosis, 気道狭窄の改善);

*ステント留置の成功;
%COUNT (stent_success, stent_success, ステント留置の成功);

data SR_breakdown;
    set sr_sputum sr_aw_stenosis sr_stent_success;
run;

%ds2csv (data=SR_breakdown, runmode=b, csvfile=&out.\SAS\SR_breakdown.csv, labels=N);
