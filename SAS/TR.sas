**************************************************************************
Program Name : TR.sas
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


proc import datafile="&raw.\¡—Ã.csv"
                    out=treatment
                    dbms=csv replace;
run;

data treatment_2;
    set treatment;
    if _N_=1 then delete;
    if treat_date='‚È‚µ' then delete;
run;


%macro COUNT (name, var, title);

    proc freq data=treatment_2 noprint;
        tables &var / out=&name;
    run;

    proc sort data=&name; by &var; run;

    data &name._2;
        format Item $60. Category $12. Count Percent best12.;
        set &name;
        if _N_=1 then item="&title";
        Category=&var;
        if &var=' ' then Category='MISSING';
        percent=round(percent, 0.1);
        drop &var;
    run;

        proc sort data=&name._2; by Category; run;

    proc summary data=&name._2;
        var count percent;
        output out=&name._total sum=;
    run;

    data &name._total_2;
        format Item $60. Category $12. Count Percent best12.;
        set &name._total;
        item=' ';
        category='‡Œv';
        keep Item Category Count Percent;
    run;

    data tr_&name;
        set &name._2 &name._total_2;
    run;

%mend COUNT;

*APC;
%COUNT (APC, APC, APC);

*‚ü”gƒXƒlƒA;
%COUNT (snare, snare, ‚ü”gƒXƒlƒA);

*d«‹¾ŠÇ‚É‚æ‚éŠíŠB“IŒ¸—Ê (Mechanical Debulking);
%COUNT (mechanical_debulking, mechanical_debulking, d«‹¾ŠÇ‚É‚æ‚éŠíŠB“IŒ¸—Ê (Mechanical Debulking));

*‚»‚Ì‘¼;
%COUNT (treat_other, treat_other, ‚»‚Ì‘¼);


data TR;
    set tr_APC tr_snare tr_mechanical_debulking tr_treat_other;
run;

%ds2csv (data=TR, runmode=b, csvfile=&out.\SAS\TR.csv, labels=N);
