**************************************************************************
Program Name : O2.sas
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


proc import datafile="&raw.\Ž¡—Ã.csv"
                    out=treatment
                    dbms=csv replace;
run;

data treatment_2;
    set treatment;
    if _N_=1 then delete;
    if treat_date='‚È‚µ' then delete;
run;


%macro BINOMIAL;

    %global _OBS_;
    data _null_;
        set treatment_2 nobs=obs;
        call symput("_OBS_", obs);
        stop;
    run;

    proc freq data=treatment_2 noprint;
        tables spo2_95 / out=ope_2;
    run;

    data ope_3;
        set ope_2;
        if spo2_95='‚Í‚¢' then output;
    run;

    data ope_4;
        format Number_of_Patients SpO2_below_95 Percent Lower_Conf_Limit_95 Upper_Conf_Limit_95 best12.;
        set ope_3;
        Number_of_Patients=&_OBS_;
        SpO2_below_95=count;
        Percent=round(percent, 0.1);
        call missing(Lower_Conf_Limit_95, Upper_Conf_Limit_95);
        keep Number_of_Patients SpO2_below_95 percent Lower_Conf_Limit_95 Upper_Conf_Limit_95;
    run;

    proc freq data=ope_2 noprint;
        tables SpO2_95 / binomial (exact level='‚Í‚¢');
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

    data O2;
        merge ope_4 cl_2;
    run;

%mend BINOMIAL;

%BINOMIAL;


%ds2csv (data=O2, runmode=b, csvfile=&out.\SAS\O2.csv, labels=N);
