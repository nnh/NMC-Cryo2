**************************************************************************
Program Name : AE_2.sas
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


proc import datafile="&raw.\Ç—á“o˜^•[.csv"
                    out=baseline
                    dbms=csv replace;
run;

data baseline_2;
    set baseline;
    if _N_=1 then delete;
run;

proc sort data=baseline_2; by subjid; run;

proc import datafile="&raw.\ÅI•]‰¿.csv"
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

proc import datafile="&raw.\¡—Ã.csv"
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
    if treat_date='‚ ‚è';
run;

data evaluation_3;
    merge evaluation_2(in=a) treatment_2;
    by subjid;
    if a;
    if treat_date='‚ ‚è';
run;


%macro COUNT (name, var, title, raw, sym, point);

    proc freq data=&raw noprint;
        tables &var / out=&name;
    run;

    proc sort data=&name; by &var; run;

    data &name._2;
        format Category $12. Count Percent best12.;
        set &name;
        Category=&var;
        %if &var in (oxygen_L AE_oxygen_L) %then %do;
        if &var=' ' then delete;
        %end;
        if &var=' ' then Category='MISSING';
        percent=round(percent, 0.1);
        drop &var;
    run;

    %if &var in (hypoxia AE_hypoxia) %then %do;
        data &name._frame;
            format Category $12.;
            Category='0'; output;
            Category='2'; output;
            Category='3'; output;
            Category='4'; output;
            Category='5'; output;
        run;
    %end;
    %if &var in (dyspnea AE_dyspnea) %then %do;
        data &name._frame;
            format Category $12.;
            Category='0'; output;
            Category='1'; output;
            Category='2'; output;
            Category='3'; output;
            Category='4'; output;
            Category='5'; output;
        run;
    %end;

    data &name._2;
        format Symptom Point $24. Item $60. Category $12. Count Percent best12.;
        set &name._2;
        if _N_=1 then do; Symptom="&sym"; Point="&point."; item="&title"; end;
    run;

    %if &var in (hypoxia AE_hypoxia dyspnea AE_dyspnea) %then %do;
        data &name._2;
            merge &name._frame &name._2;
            by Category;
            if count=. then count=0;
            if percent=. then percent=0;
        run;
    %end;

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

    data x_&name;
        format Symptom Point $24. Item $60. Category $12. Count Percent best12.;
        set &name._2 &name._total_2;
    run;

%mend COUNT;

%macro IQR (name, var, title, rdata);

    data &rdata._2;
        set &rdata;
        c=input(&var., best12.);
        if c=-1 then delete;
        %if &var=oxygen_L %then %do;
            if oxygen='‚È‚µ' then delete;
        %end;
        keep c;
        rename c=&var.;
    run;

    proc means data=&rdata._2 noprint;
        var &var;
        output out=&name n=n mean=mean std=std median=median q1=q1 q3=q3 min=min max=max;
    run;

    data &name._frame;
        format Symptom Point $24. Item $60. Category $12. Count Percent best12.;
        Symptom=' ';
        Point=' ';
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
        keep Symptom Point Item Category Count Percent;
    run;

%mend IQR;


*’á_‘fÇ;
  *ƒx[ƒXƒ‰ƒCƒ“;
    *_‘f“Š—^‚Ì—L–³;
    %COUNT (oxygen, oxygen, _‘f“Š—^‚Ì—L–³, baseline_3, ’á_‘fÇ, ƒx[ƒXƒ‰ƒCƒ“);
    *_‘f“Š—^—L‚Ìê‡‚Ì_‘f—Ê;
    %IQR (oxygen_L, oxygen_L, _‘f“Š—^—L‚Ìê‡‚Ì_‘f—Ê, baseline_3);
    *SpO2;
    %IQR (Sp02, Sp02, SpO2, baseline_3);
    *Grade;
    %COUNT (hypoxia, hypoxia, Grade, baseline_3, , );
  *ÅI•]‰¿;
    *_‘f“Š—^‚Ì—L–³;
    %COUNT (AE_oxygen, AE_oxygen, _‘f“Š—^‚Ì—L–³, evaluation_3, , ÅI•]‰¿);
    *_‘f“Š—^—L‚Ìê‡‚Ì_‘f—Ê;
    %IQR (AE_oxygen_L, AE_oxygen_L, _‘f“Š—^—L‚Ìê‡‚Ì_‘f—Ê, evaluation_3);
    *SpO2;
    %IQR (AE_spO2_v, AE_spO2_v, SpO2, evaluation_3);
    *Grade;
    %COUNT (AE_hypoxia, AE_hypoxia, Grade, evaluation_3, , );

*ŒÄ‹z¢“ï;
  *ƒx[ƒXƒ‰ƒCƒ“;
    *Grade;
    %COUNT (dyspnea, dyspnea, Grade, baseline_3, ŒÄ‹z¢“ï, ƒx[ƒXƒ‰ƒCƒ“);
  *ÅI•]‰¿;
    *Grade;
    %COUNT (AE_dyspnea, AE_dyspnea, Grade, evaluation_3, ,ÅI•]‰¿);


data AE_2;
    set x_oxygen x_oxygen_L x_Sp02 x_hypoxia x_AE_oxygen x_AE_oxygen_L x_AE_spO2_v x_AE_hypoxia
    x_dyspnea x_AE_dyspnea;
run;

%ds2csv (data=AE_2, runmode=b, csvfile=&out.\SAS\AE_2.csv, labels=N);
