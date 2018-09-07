libname project 'C:\Users\wgao\Desktop\ANA 610\Assignment\Final Project';

/*Data Dictionary*/
proc contents data=project.Fortune_acct; run;
proc contents data=project.fortune_attrition; run;

proc import datafile='C:\Users\wgao\Desktop\ANA 610\Assignment\Final Project\fortune_credit.csv' out=project.fortune_credit; run;

/*Data details*/
/*fortune_hr*/
proc freq data=project.fortune_hr; table Education EducationField Gender birth_state;
run;

/*fortune_acct*/
proc freq data=project.fortune_acct; table Department OverTime PerformanceRating StockOptionLevel;
run;

/*fortune_survey*/
proc means data=project.fortune_survey n nmiss min mean median max; var DistanceFromHome NumCompaniesWorked
TotalWorkingYears YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager employee_no; 
run;

proc freq data=project.fortune_survey; table BusinessTravel EnvironmentSatisfaction JobInvolvement
JobLevel JobSatisfaction MaritalStatus RelationshipSatisfaction TrainingTimesLastYear WorkLifeBalance;
run;

/*merge fortune_acct & fortune_credit */
data work.fortune_acct_num; set project.fortune_acct;
ssn_char=compress (ssn,"-"); 
ssn_num=input(ssn_char,9.);
drop ssn ssn_char;
run;

data work.fortune_credit_num; set project.fortune_credit;
ssn_num=ssn;
drop ssn;
run;

proc sort data=work.fortune_acct_num; by ssn_num; run;
proc sort data=work.fortune_credit_num; by ssn_num; run;
data work.fortune_acct_merge; merge work.fortune_acct_num work.fortune_credit_num; by ssn_num; run;

proc contents data=work.fortune_acct_merge; run;

/*merge others*/
proc sort data=project.fortune_survey; by employee_no; run;
proc sort data=project.fortune_attrition; by employee_no; run;
proc sort data=project.fortune_hr; by employee_no; run;
proc sort data=work.fortune_acct_merge; by employee_no; run;

data work.fortune_master; merge project.fortune_survey (in=a) project.fortune_attrition project.fortune_hr
work.fortune_acct_merge; by employee_no; if a; run;

proc contents data=work.fortune_master; run;

data project.fortune_master; set work.fortune_master; run;

/*sample size*/
proc sql; select count(*) as obs_count from project.fortune_master where depart_dt notin(.); 	quit;
proc sql; select count(*) as obs_count from project.fortune_master where depart_dt in(.); 	quit;

/*coding error correction*/
proc freq data=project.fortune_master; table Department EducationField; run;

data work.fortune_master_1; set project.fortune_master;
if Department="Research & D" then Department_new="Research & Development";
if Department notin ("Research & D") then Department_new=Department;
if EducationField="LS" then EducationField_new="Life Sciences   ";
if EducationField="Mkt" then EducationField_new="Marketing";
if EducationField="Tech" then EducationField_new="Technical Degree";
else if EducationField notin ("LS") and EducationField notin ("Mkt") and EducationField notin ("Tech") then EducationField_new=EducationField;
drop Department EducationField;
run;
proc freq data=work.fortune_master_1; table Department_new EducationField_new; run;

proc contents data=work.fortune_master_1; run;

/*Checking for duplicates*/
proc sql; select count(*) into : nobs from work.fortune_master_1; quit;

proc sort data=work.fortune_master_1 out=work.fortune_master_clean nodupkey; by employee_no; run;

proc sql; select count(*) into : nobs from work.fortune_master_clean; quit;
proc contents data=work.fortune_master_clean out=work.contents; run;

/*check missing values*/
/*numeric variables*/
proc means data = work.fortune_master_clean n nmiss; run;  

/*character variables*/
proc format; value $misscnt "  " = "Missing" other = "Nonmissing"; run;

proc freq data=work.fortune_master_clean;
tables _character_ /  nocum missing;
format _character_ $misscnt.;
run;

/*birth_dt*/
proc univariate data=work.fortune_master_clean nextrobs=10; var birth_dt;
	histogram birth_dt / normal;
run;

data work.fortune_master_1; set work.fortune_master_clean;
	array red birth_dt;
	do i = 1 to dim(red);
		if red(i) in (.) then birth_dt_mi_dum = 1; else birth_dt_mi_dum = 0;
	end;
	drop i; run;

proc rank data=work.fortune_master_1 out=work.fortune_master_1_rank groups=10;
	var TotalWorkingYears;
	ranks TotalWorkingYears_grp; run;
proc means data=work.fortune_master_1_rank median;
	class TotalWorkingYears_grp;
	var birth_dt;
run;

proc sort data=work.fortune_master_1_rank; by TotalWorkingYears_grp; run;

proc stdize data=work.fortune_master_1_rank
	method=median
	reponly
	out=work.imputed2;
	var birth_dt;
	by TotalWorkingYears_grp; 
run;

data work.imputed2; set work.imputed2 (rename =(birth_dt = birth_dt_mi));
	keep employee_no birth_dt_mi birth_dt_mi_dum;  run;

proc sort data=work.fortune_master_1_rank; 	by employee_no; run;
proc sort data=work.imputed2; 		by employee_no; run;

data work.fortune_master_1_mi; merge work.fortune_master_1_rank work.imputed2; by employee_no;
	array red birth_dt_mi;
	do i = 1 to dim (red);
		if red(i) = . then red(i) = 0;
	end;
	drop i; run;

proc means data=work.fortune_master_1_mi median mean;
	class  TotalWorkingYears_grp;
	var birth_dt birth_dt_mi; run;

proc univariate data=work.fortune_master_1_mi; var birth_dt birth_dt_mi;
	histogram birth_dt birth_dt_mi; run;

/*DailyRate*/
proc univariate data=work.fortune_master_clean nextrobs=10; var DailyRate;
	histogram DailyRate / normal;
run;

data work.fortune_master_2; set work.fortune_master_1_mi;
	array red DailyRate;
	do i = 1 to dim(red);
		if red(i) in (.) then DailyRate_mi_dum = 1; else DailyRate_mi_dum = 0;
	end;
	drop i; run;

proc rank data=work.fortune_master_2 out=work.fortune_master_2_rank groups=7;
	var HourlyRate;
	ranks HourlyRate_grp; run;
proc means data=work.fortune_master_2_rank median;
	class HourlyRate_grp;
	var DailyRate;
run;

proc sort data=work.fortune_master_2_rank; by HourlyRate_grp; run;

proc stdize data=work.fortune_master_2_rank
	method=median
	reponly
	out=work.imputed2;
	var DailyRate;
	by HourlyRate_grp; 
run;

data work.imputed2; set work.imputed2 (rename =(DailyRate = DailyRate_mi));
	keep employee_no DailyRate_mi DailyRate_mi_dum;  run;

proc sort data=work.fortune_master_2_rank; 	by employee_no; run;
proc sort data=work.imputed2; 		by employee_no; run;

data work.fortune_master_2_mi; merge work.fortune_master_2_rank work.imputed2; by employee_no;
	array red DailyRate_mi;
	do i = 1 to dim (red);
		if red(i) = . then red(i) = 0;
	end;
	drop i; run;

proc means data=work.fortune_master_2_mi median mean;
	class  HourlyRate_grp;
	var DailyRate DailyRate_mi; run;

proc univariate data=work.fortune_master_2_mi; var DailyRate DailyRate_mi;
	histogram DailyRate DailyRate_mi; run;

proc contents data=work.fortune_master_2_mi; run;

/*MonthlyIncome*/
data work.fortune_master_3; set work.fortune_master_2_mi;
	array red MonthlyIncome;
	do i = 1 to dim(red);
		if red(i) in (.) then MonthlyIncome_mi_dum = 1; else MonthlyIncome_mi_dum = 0;
	end;
	drop i; run;

proc rank data=work.fortune_master_3 out=work.fortune_master_rank groups=7;
	var HourlyRate;
	ranks HourlyRate_grp; run;

proc means data=work.fortune_master_rank median;
	class HourlyRate_grp;
	var MonthlyIncome;
run;

proc sort data=work.fortune_master_rank; by HourlyRate_grp; run;

proc stdize data=work.fortune_master_rank
	method=median
	reponly
	out=work.imputed2;
	var MonthlyIncome;
	by HourlyRate_grp;
run;

data work.imputed2; set work.imputed2 (rename =(MonthlyIncome = MonthlyIncome_mi));
	keep employee_no MonthlyIncome_mi MonthlyIncome_mi_dum;  run;

proc sort data=work.fortune_master_rank; 	by employee_no; run;
proc sort data=work.imputed2; 		by employee_no; run;

data work.fortune_master_mi_3; merge work.fortune_master_rank work.imputed2; by employee_no;
	array red MonthlyIncome_mi;
	do i = 1 to dim (red);
		if red(i) = . then red(i) = 0;
	end;
	drop i; run;

proc means data=work.fortune_master_mi_3 median mean;
	class  HourlyRate_grp;
	var MonthlyIncome MonthlyIncome_mi;
run;

proc univariate data=work.fortune_master_mi_3; var MonthlyIncome MonthlyIncome_mi;
	histogram MonthlyIncome MonthlyIncome_mi;
run;

/*depart_dt*/
data work.fortune_master_mi_4; set work.fortune_master_mi_3;
if depart_dt in (.) then depart_dt_mi_dum=1;
else if depart_dt notin (.) then depart_dt_mi_dum=0;
run;

proc freq data=work.fortune_master_mi_4; table depart_dt_mi_dum; run;

/*categorical missing values*/
data work.fortune_master_mi_5; set work.fortune_master_mi_4;
if MaritalStatus in (" ") then MaritalStatus_mi="Unknown";
if MaritalStatus notin (" ") then MaritalStatus_mi=MaritalStatus;
if birth_state in (" ") then birth_state_mi="Unknown";
else if birth_state notin (" ") then birth_state_mi=birth_state;
run;

proc freq data=work.fortune_master_mi_5; table MaritalStatus_mi birth_state_mi; run;

/*Extreme value*/
proc contents data=work.fortune_master_mi_5; run;
/*======>DailyRate_mi DistanceFromHome HourlyRate MonthlyIncome_mi NumCompaniesWorked PercentSalaryHike
TotalWorkingYears YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager birth_dt_mi
depart_dt employee_no fico_scr hire_dt ssn_num */

/*Range check*/
%let anal_var = hire_dt;

proc univariate data=work.fortune_master_mi_5 nextrobs=10;
	var &anal_var;
	histogram &anal_var / normal;
run;

/*Top/bottom X%*/
proc univariate data=work.fortune_master_mi_5; var &anal_var;
	histogram &anal_var;
	output out=work.tmp pctlpts= 1 99 pctlpre = percent; 
run;

proc print data=work.tmp; run;

data work.hi_low;
	set work.fortune_master_mi_5;
	if _n_ = 1 then set work.tmp;

	if &anal_var le percent1 then do;
		range = "low ";
		output;
	end;
	else if &anal_var ge percent99 then do;
		range = "high";
		output;
	end;
run;

proc sort data=work.hi_low; by &anal_var; run;

proc print data=work.hi_low; var employee_no &anal_var range; run;

/*Standard Deviation*/
proc means data=work.fortune_master_mi_5 noprint; var &anal_var;
	output out=work.tmp(drop = _freq_ _type_) mean=anal_var_mean std=anal_var_std; 
run;

proc print data=work.tmp; run;

%let n_std = 2;

data work.std_test;
	set work.fortune_master_mi_5;
	if _n_ = 1 then set work.tmp;
	if &anal_var le anal_var_mean - &n_std*anal_var_std then do;
		range = "low ";
		output;
	end;
	else if &anal_var ge anal_var_mean + &n_std*anal_var_std then do;
		range = "high";
		output;
	end; run;

proc sort data=work.std_test; by descending &anal_var; run;	
	
proc print data=work.std_test; var employee_no &anal_var range; run;

/*Trimmed Statistics*/
proc rank data=work.fortune_master_mi_5 (keep=employee_no &anal_var) out=work.tmp_rank groups = 20;
	var &anal_var;
	ranks anal_var_rank;
run;

proc means data=work.tmp_rank; var &anal_var;
output out=work.tmp_stat(drop = _freq_ _type_) mean=anal_var_mean std=anal_var_std; 
where anal_var_rank notin(0,19); run;

proc print data=work.tmp_stat; run;

%let n_std = 3;
%let mult = 1.24;

data work.std_test;
	set work.fortune_master_mi_5;
	if _n_ = 1 then set work.tmp_stat;

	if &anal_var le anal_var_mean - &n_std*anal_var_std*&mult then do;
		range = "low ";
		output;
	end;
	else if &anal_var ge anal_var_mean + &n_std*anal_var_std*&mult then do;
		range = "high";
		output;
	end; run;

proc sort data=work.std_test; by descending &anal_var; run;

proc print data=work.std_test; var employee_no &anal_var range; run;

/*IQR*/
proc means data=work.fortune_master_mi_5 noprint; var &anal_var;
	output out=work.tmp(drop = _freq_ _type_) q3 = upper q1 = lower qrange = IQR;
run;

proc print data=work.tmp; run;

%let iqr_mult = 3;

data work.iqr_test;
	set work.fortune_master_mi_5;
	if _n_ = 1 then set work.tmp;

	if &anal_var lt lower - &iqr_mult*IQR then do;
		range = "low ";
		output;
	end;
	else if &anal_var gt upper + &iqr_mult*IQR then do;
		range = "high";
		output;
	end; run;

proc sort data=work.iqr_test; by descending &anal_var; run;

proc print data=work.iqr_test; var employee_no &anal_var range; run;

/*Clustering*/
%macro clust_out(dsin,varlist,where,pmin,dsout);

/* here are the definitions of the macro variables
dsin  	= input dataset
varlist 	= list of vars used in clustering
where 	= where condition
pmin  	= size of cluster, as % of dataset, to label its obs as outliers
dsout 	= output dataset with outliers identified
*/
*====> invoke FASTCLUS to group obs into 50 clusters;
proc fastclus data=&dsin maxc=50 maxiter=100 cluster=_clusterindex_ out=work.temp_clus noprint;
	var &varlist;
	where &where;
run;

*====> analyze resulting clusters;
proc freq data=work.temp_clus noprint;
	tables _clusterindex_ / out=work.temp_freq;
run;
 
*====> isolate clusters with a size less than pmin of the dataset size;
data work.temp_low; set work.temp_freq;
	if percent < &pmin; _outlier_ = 1;
	keep _clusterindex_ _outlier_;
run; 

*====> merge these isolated clusters back onto the master dataset;
proc sort data=work.temp_clus; 	by _clusterindex_; run;
proc sort data=work.temp_low; 	by _clusterindex_; run;

data &dsout; merge work.temp_clus work.temp_low; by _clusterindex_;
	if _outlier_ = . then _Outlier_ = 0; run;

*====> print the outlier values;
proc print data=&dsout; var &varlist _Outlier_; where _Outlier_ = 1; run;

%mend;

%clust_out(work.fortune_master_mi_5, &anal_var, employee_no notin(.), .009, work.clus_out);

/*Extreme for hire_dt*/
proc sort data=work.fortune_master_mi_5; by hire_dt; run;

proc print data=work.fortune_master_mi_5 (obs=5); run;

/*outlier indicators*/
/*DailyRate_mi*/
data work.fortune_master_ex_1; set work.fortune_master_mi_5;
if DailyRate_mi<100 then outlier_DailyRate_mi=1;
else outlier_DailyRate_mi=0; run;

proc freq data=work.fortune_master_ex_1; table outlier_DailyRate_mi; run;

/*DistanceFromHome*/
%let anal_var = DistanceFromHome;
proc means data=work.fortune_master_ex_1 noprint; var &anal_var;
	output out=work.tmp(drop = _freq_ _type_) mean=anal_var_mean std=anal_var_std; 
run;

proc print data=work.tmp; run;

%let n_std = 2;

data work.fortune_master_ex_2;
	set work.fortune_master_ex_1;
	if _n_ = 1 then set work.tmp;
	if &anal_var ge anal_var_mean + &n_std*anal_var_std then outlier_DistanceFromHome=1;
	else outlier_DistanceFromHome=0;
run;
proc freq data=work.fortune_master_ex_2; table outlier_DistanceFromHome; run;

/*HourlyRate*/
data work.fortune_master_ex_3; set work.fortune_master_ex_2;
if HourlyRate=30 or HourlyRate=100 then outlier_HourlyRate=1;
else outlier_HourlyRate=0;
run;
proc freq data=work.fortune_master_ex_3; table outlier_HourlyRate; run;

/*MonthlyIncome_mi*/
data work.fortune_master_ex_4; set work.fortune_master_ex_3;
if MonthlyIncome_mi=135999 or MonthlyIncome_mi=199999 then outlier_MonthlyIncome_mi=1;
else outlier_MonthlyIncome_mi=0;
run;
proc freq data=work.fortune_master_ex_4; table outlier_MonthlyIncome_mi; run;

/*PercentSalaryHike*/
data work.fortune_master_ex_5; set work.fortune_master_ex_4;
if PercentSalaryHike>22 then outlier_PercentSalaryHike=1;
else outlier_PercentSalaryHike=0;
run;
proc freq data=work.fortune_master_ex_5; table outlier_PercentSalaryHike; run;

/*TotalWorkingYears*/
data work.fortune_master_ex_6; set work.fortune_master_ex_5;
if TotalWorkingYears>34 then outlier_TotalWorkingYears=1;
else outlier_TotalWorkingYears=0;
run;
proc freq data=work.fortune_master_ex_6; table outlier_TotalWorkingYears; run;

/*YearsInCurrentRole*/
data work.fortune_master_ex_7; set work.fortune_master_ex_6;
if YearsInCurrentRole>14 then outlier_YearsInCurrentRole=1;
else outlier_YearsInCurrentRole=0;
run;
proc freq data=work.fortune_master_ex_7; table outlier_YearsInCurrentRole; run;

/*YearsSinceLastPromotion*/
data work.fortune_master_ex_8; set work.fortune_master_ex_7;
if YearsSinceLastPromotion>12 then outlier_YearsSinceLastPromotion=1;
else outlier_YearsSinceLastPromotion=0;
run;
proc freq data=work.fortune_master_ex_8; table outlier_YearsSinceLastPromotion; run;

/*YearsWithCurrManager*/
data work.fortune_master_ex_9; set work.fortune_master_ex_8;
if YearsWithCurrManager>14 then outlier_YearsWithCurrManager=1;
else outlier_YearsWithCurrManager=0;
run;
proc freq data=work.fortune_master_ex_9; table outlier_YearsWithCurrManager; run;

/*fico_scr*/
data work.fortune_master_ex_10; set work.fortune_master_ex_9;
if fico_scr>=800 then outlier_fico_scr=1;
else outlier_fico_scr=0;
run;
proc freq data=work.fortune_master_ex_10; table outlier_fico_scr; run;

/*hire_dt*/
%let anal_var = hire_dt;

proc univariate data=work.fortune_master_ex_10 nextrobs=10;
	var &anal_var;
	histogram &anal_var / normal;
run;

data work.fortune_master_outlier; set work.fortune_master_ex_10;
if hire_dt <7300 then outlier_hire_dt=1;
else outlier_hire_dt=0;
run;
proc freq data=work.fortune_master_outlier; table outlier_hire_dt; run;

proc sort data=work.fortune_master_outlier; by hire_dt; run;

/*Analyze result comparison with and without outliers*/
/*MonthlyIncome_mi*/
proc means data=work.fortune_master_outlier n mean median stddev min max; var MonthlyIncome_mi; run;
proc univariate data=work.fortune_master_outlier; var MonthlyIncome_mi; histogram MonthlyIncome_mi / normal; run;

proc means data=work.fortune_master_outlier n mean median stddev min max; var MonthlyIncome_mi;
where outlier_MonthlyIncome_mi=0;
run;
proc univariate data=work.fortune_master_outlier; var MonthlyIncome_mi; histogram MonthlyIncome_mi / normal; 
where outlier_MonthlyIncome_mi=0;
run;

/*Extreme Distribution*/
%let anal_var = MonthlyIncome_mi;

proc univariate data=work.fortune_master_outlier; var &anal_var;
	histogram &anal_var / normal;
run;

data work.fortune_master_distribution; set work.fortune_master_outlier;
	if &anal_var ne 0 then do;
		invsqrt_MonthlyIncome_mi = 1/(sqrt(&anal_var));
		end;
	else do;
		invsqrt_MonthlyIncome_mi = 0;
		end;
run;

proc univariate data=work.fortune_master_distribution; 
	var invsqrt_MonthlyIncome_mi;
	histogram invsqrt_MonthlyIncome_mi/ normal;
run;

/*caterical variable dummy*/
/*Cardinality Ratio*/
proc contents data=work.fortune_master_distribution out=work.cat_cont; run;
data work.cat_cont; set work.cat_cont; keep name nobs; run;

/*BusinessTravel Department_new Education EducationField_new EnvironmentSatisfaction Gender JobInvolvement*/
/*JobLevel JobSatisfaction MaritalStatus_mi OverTime PerformanceRating RelationshipSatisfaction*/
/*StockOptionLevel TrainingTimesLastYear WorkLifeBalance birth_state_mi*/

%let cat_var = birth_state_mi;
proc freq data=work.fortune_master_distribution noprint; table &cat_var / out=work.cat_counts; run;
proc freq data=work.cat_counts noprint; table &cat_var / out=work.cat_counts; run;
proc sql; select count(*) into: TotalCats from work.cat_counts; quit;

data work.new; set work.cat_cont; where name ="&cat_var"; 
	level = scan("&TotalCats", _n_);
	card_ratio = level/nobs;
run;

proc print data=work.new; run;

/*Recoding*/
/*OverTime*/
proc freq data=work.fortune_master_distribution; table OverTime; run;

data work.fortune_master_dummy_1; set work.fortune_master_distribution;
OverTimeY_dum = (OverTime="Yes");
OverTimeN_dum = (OverTime="No");
run;

proc means data=work.fortune_master_dummy_1 sum; var OverTimeY_dum OverTimeN_dum; run;

proc sort data=work.fortune_master_dummy_1; by depart_dt_mi_dum ; run;
proc freq data=work.fortune_master_dummy_1; table OverTimeY_dum OverTimeN_dum; by depart_dt_mi_dum ; run;

/*PerformanceRating*/
proc freq data=work.fortune_master_dummy_1; table PerformanceRating; run;

data work.fortune_master_dummy_2; set work.fortune_master_dummy_1;
PerformanceRating3_dum = (PerformanceRating="3");
PerformanceRating4_dum = (PerformanceRating="4");
run;

proc means data=work.fortune_master_dummy_2 sum; var PerformanceRating3_dum PerformanceRating4_dum; run;

/*BusinessTravel*/
proc freq data=work.fortune_master_dummy_2; table BusinessTravel; run;

data work.fortune_master_dummy_3; set work.fortune_master_dummy_2;
BusinessTravelNon_dum = (BusinessTravel="Non-Travel");
BusinessTravelFreq_dum = (BusinessTravel="Travel_Frequently");
BusinessTravelRare_dum = (BusinessTravel="Travel_Rarely");
run;

proc means data=work.fortune_master_dummy_3 sum; var BusinessTravelNon_dum BusinessTravelFreq_dum BusinessTravelRare_dum;
run;

/*Department_new*/
proc freq data=work.fortune_master_dummy_3; table Department_new; run;

data work.fortune_master_dummy_4; set work.fortune_master_dummy_3;
Department_newHR_dum = (Department_new="Human Resources");
Department_newRD_dum = (Department_new="Research & Development");
Department_newSa_dum = (Department_new="Sales");
run;

proc means data=work.fortune_master_dummy_4 sum; var Department_newHR_dum Department_newRD_dum Department_newSa_dum;
run;

/*Gender*/
proc freq data=work.fortune_master_dummy_4; table Gender
; run;

data work.fortune_master_dummy_5; set work.fortune_master_dummy_4;
GenderF_dum = (Gender="Female");
GenderM_dum = (Gender="Male");
GenderNA_dum = (Gender="N/A");
run;

proc means data=work.fortune_master_dummy_5 sum; var GenderF_dum GenderM_dum GenderNA_dum;
run;

/*EnvironmentSatisfaction*/
proc freq data=work.fortune_master_dummy_5; table EnvironmentSatisfaction
; run;

data work.fortune_master_dummy_6; set work.fortune_master_dummy_5;
EnvironmentSatisfaction1_dum = (EnvironmentSatisfaction="1");
EnvironmentSatisfaction2_dum = (EnvironmentSatisfaction="2");
EnvironmentSatisfaction3_dum = (EnvironmentSatisfaction="3");
EnvironmentSatisfaction4_dum = (EnvironmentSatisfaction="4");
run;

proc means data=work.fortune_master_dummy_6 sum; var EnvironmentSatisfaction1_dum EnvironmentSatisfaction2_dum EnvironmentSatisfaction3_dum
EnvironmentSatisfaction4_dum; run;

/*JobInvolvement*/
proc freq data=work.fortune_master_dummy_6; table JobInvolvement
; run;

data work.fortune_master_dummy_7; set work.fortune_master_dummy_6;
JobInvolvement1_dum = (JobInvolvement="1");
JobInvolvement2_dum = (JobInvolvement="2");
JobInvolvement3_dum = (JobInvolvement="3");
JobInvolvement4_dum = (JobInvolvement="4");
run;

proc means data=work.fortune_master_dummy_7 sum; var JobInvolvement1_dum JobInvolvement2_dum JobInvolvement3_dum
 JobInvolvement4_dum; run;

/*JobSatisfaction*/
proc freq data=work.fortune_master_dummy_7; table JobSatisfaction
; run;

data work.fortune_master_dummy_8; set work.fortune_master_dummy_7;
JobSatisfaction1_dum = (JobSatisfaction="1");
JobSatisfaction2_dum = (JobSatisfaction="2");
JobSatisfaction3_dum = (JobSatisfaction="3");
JobSatisfaction4_dum = (JobSatisfaction="4");
run;

proc means data=work.fortune_master_dummy_8 sum; var JobSatisfaction1_dum JobSatisfaction2_dum JobSatisfaction3_dum 
JobSatisfaction4_dum; run;

/*MaritalStatus_mi*/
proc freq data=work.fortune_master_dummy_8; table MaritalStatus_mi
; run;

data work.fortune_master_dummy_9; set work.fortune_master_dummy_8;
MaritalStatus_mi_Divorce_dum = (MaritalStatus_mi="Divorce");
MaritalStatus_mi_Married_dum = (MaritalStatus_mi="Married");
MaritalStatus_mi_Single_dum = (MaritalStatus_mi="Single");
MaritalStatus_mi_Unknown_dum = (MaritalStatus_mi="Unknown");
run;

proc means data=work.fortune_master_dummy_9 sum; var MaritalStatus_mi_Divorce_dum MaritalStatus_mi_Married_dum MaritalStatus_mi_Single_dum 
 MaritalStatus_mi_Unknown_dum; run;

/*RelationshipSatisfaction*/
proc freq data=work.fortune_master_dummy_9; table RelationshipSatisfaction
; run;

data work.fortune_master_dummy_10; set work.fortune_master_dummy_9;
RelationshipSatisfaction1_dum = (RelationshipSatisfaction="1");
RelationshipSatisfaction2_dum = (RelationshipSatisfaction="2");
RelationshipSatisfaction3_dum = (RelationshipSatisfaction="3");
RelationshipSatisfaction4_dum = (RelationshipSatisfaction="4");
run;

proc means data=work.fortune_master_dummy_10 sum; var RelationshipSatisfaction1_dum RelationshipSatisfaction2_dum RelationshipSatisfaction3_dum 
RelationshipSatisfaction4_dum; run;

/*StockOptionLevel*/
proc freq data=work.fortune_master_dummy_10; table StockOptionLevel
; run;

data work.fortune_master_dummy_11; set work.fortune_master_dummy_10;
StockOptionLevel1_dum = (StockOptionLevel="1");
StockOptionLevel2_dum = (StockOptionLevel="2");
StockOptionLevel3_dum = (StockOptionLevel="3");
StockOptionLevel0_dum = (StockOptionLevel="0");
run;

proc means data=work.fortune_master_dummy_11 sum; var StockOptionLevel1_dum StockOptionLevel2_dum StockOptionLevel3_dum 
StockOptionLevel0_dum; run;

/*WorkLifeBalance*/
proc freq data=work.fortune_master_dummy_11; table WorkLifeBalance
; run;

data work.fortune_master_dummy_12; set work.fortune_master_dummy_11;
WorkLifeBalance1_dum = (WorkLifeBalance="1");
WorkLifeBalance2_dum = (WorkLifeBalance="2");
WorkLifeBalance3_dum = (WorkLifeBalance="3");
WorkLifeBalance4_dum = (WorkLifeBalance="4");
run;

proc means data=work.fortune_master_dummy_12 sum; var WorkLifeBalance1_dum WorkLifeBalance2_dum WorkLifeBalance3_dum 
WorkLifeBalance4_dum; run;

/*Education*/
proc freq data=work.fortune_master_dummy_12; table Education
; run;

data work.fortune_master_dummy_13; set work.fortune_master_dummy_12;
Education1_dum = (Education="1");
Education2_dum = (Education="2");
Education3_dum = (Education="3");
Education4_dum = (Education="4");
Education5_dum = (Education="5");
run;

proc means data=work.fortune_master_dummy_13 sum; var Education1_dum Education2_dum Education3_dum 
Education4_dum Education5_dum; run;

/*JobLevel*/
proc freq data=work.fortune_master_dummy_13; table JobLevel
; run;

data work.fortune_master_dummy_14; set work.fortune_master_dummy_13;
JobLevel1_dum = (JobLevel="1");
JobLevel2_dum = (JobLevel="2");
JobLevel3_dum = (JobLevel="3");
JobLevel4_dum = (JobLevel="4");
JobLevel5_dum = (JobLevel="5");
run;

proc means data=work.fortune_master_dummy_14 sum; var JobLevel1_dum JobLevel2_dum JobLevel3_dum JobLevel4_dum JobLevel5_dum; run;

/*EducationField_new*/
%let anal_var = EducationField_new;
%let segment = depart_dt_mi_dum;

proc sort data=work.fortune_master_dummy_14; by &segment; run;
proc freq data=work.fortune_master_dummy_14 order=freq; table &anal_var / out=work.freq (drop = percent);
	by &segment; run;

data work.seg_1 work.seg_0; set work.freq;
	if &segment = 1 then output work.seg_1; 
	if &segment = 0 then output work.seg_0; run;

data work.seg_1; set work.seg_1; count_seg_1 = count; keep &anal_var count_seg_1; run;
data work.seg_0; set work.seg_0; count_seg_0 = count; keep &anal_var count_seg_0; run;

proc sort data=work.seg_1; 		by &anal_var; run;
proc sort data=work.seg_0; 		by &anal_var; run;
proc sort data=work.fortune_master_dummy_14; 	by &anal_var; run;

data work.fortune_master_dummy_15; merge work.fortune_master_dummy_14 work.seg_1 work.seg_0; by &anal_var;
If EducationField_new = "Life Sciences" and count_seg_1>30 and count_seg_0>30 
then EducationField_newLS_dum = 1;
else EducationField_newLS_dum = 0;
if EducationField_new = "Medical" and count_seg_1>30 and count_seg_0>30 
then EducationField_newMD_dum = 1;
else EducationField_newMD_dum = 0;
if EducationField_new = "Marketing" and count_seg_1>30 and count_seg_0>30 
then EducationField_newMk_dum = 1;
else EducationField_newMK_dum = 0;
if EducationField_new = "Technical Degree" and count_seg_1>30 and count_seg_0>30 
then EducationField_newTE_dum = 1;
else EducationField_newTE_dum = 0;
if EducationField_new = "Human Resources" and count_seg_1>30 and count_seg_0>30 
then EducationField_newHR_dum = 1;
else EducationField_newHR_dum = 0;
if EducationField_new = "Other" or sum (EducationField_newLS_dum, EducationField_newMD_dum, EducationField_newMk_dum, 
EducationField_newTE_dum, EducationField_newHR_dum)=0
then EducationField_newOT_dum = 1;
else EducationField_newOT_dum = 0;
run;

proc means data=work.fortune_master_dummy_15 sum; 
var EducationField_newLS_dum EducationField_newMD_dum EducationField_newMk_dum
EducationField_newTE_dum EducationField_newHR_dum EducationField_newOT_dum; 
where &segment=0; run;

proc means data=work.fortune_master_dummy_15 sum; 
var EducationField_newLS_dum EducationField_newMD_dum EducationField_newMk_dum
EducationField_newTE_dum EducationField_newHR_dum EducationField_newOT_dum; 
where &segment=1; run;

data work.fortune_master_dummy_15; set work.fortune_master_dummy_15;
drop count_seg_1 count_seg_0 EducationField_newHR_dum;
run;

/*TrainingTimesLastYear*/
%let anal_var = TrainingTimesLastYear;
%let segment = depart_dt_mi_dum;

proc sort data=work.fortune_master_dummy_15; by &segment; run;
proc freq data=work.fortune_master_dummy_15 order=freq; table &anal_var / out=work.freq (drop = percent);
	by &segment; run;

data work.seg_1 work.seg_0; set work.freq;
	if &segment = 1 then output work.seg_1; 
	if &segment = 0 then output work.seg_0; run;

data work.seg_1; set work.seg_1; count_seg_1 = count; keep &anal_var count_seg_1; run;
data work.seg_0; set work.seg_0; count_seg_0 = count; keep &anal_var count_seg_0; run;

proc sort data=work.seg_1; 		by &anal_var; run;
proc sort data=work.seg_0; 		by &anal_var; run;
proc sort data=work.fortune_master_dummy_15; 	by &anal_var; run;

data work.fortune_master_dummy_16; merge work.fortune_master_dummy_15 work.seg_1 work.seg_0; by &anal_var;
If TrainingTimesLastYear = "0" and count_seg_1>30 and count_seg_0>30 
then TrainingTimesLastYear0_dum = 1;
else TrainingTimesLastYear0_dum = 0;
if TrainingTimesLastYear = "1" and count_seg_1>30 and count_seg_0>30 
then TrainingTimesLastYear1_dum = 1;
else TrainingTimesLastYear1_dum = 0;
if TrainingTimesLastYear = "2" and count_seg_1>30 and count_seg_0>30 
then TrainingTimesLastYear2_dum = 1;
else TrainingTimesLastYear2_dum = 0;
if TrainingTimesLastYear = "3" and count_seg_1>30 and count_seg_0>30 
then TrainingTimesLastYear3_dum = 1;
else TrainingTimesLastYear3_dum = 0;
if TrainingTimesLastYear = "4" and count_seg_1>30 and count_seg_0>30 
then TrainingTimesLastYear4_dum = 1;
else TrainingTimesLastYear4_dum = 0;
if TrainingTimesLastYear = "5" and count_seg_1>30 and count_seg_0>30 
then TrainingTimesLastYear5_dum = 1;
else TrainingTimesLastYear5_dum = 0;
if TrainingTimesLastYear = "6" and count_seg_1>30 and count_seg_0>30 
then TrainingTimesLastYear6_dum = 1;
else TrainingTimesLastYear6_dum = 0;
if sum (TrainingTimesLastYear0_dum, TrainingTimesLastYear1_dum, TrainingTimesLastYear2_dum, 
TrainingTimesLastYear3_dum, TrainingTimesLastYear4_dum, TrainingTimesLastYear5_dum, TrainingTimesLastYear6_dum)=0
then TrainingTimesLastYearOT_dum = 1;
else TrainingTimesLastYearOT_dum = 0;
run;

proc means data=work.fortune_master_dummy_16 sum; 
var TrainingTimesLastYear0_dum TrainingTimesLastYear1_dum TrainingTimesLastYear2_dum TrainingTimesLastYear3_dum
TrainingTimesLastYear4_dum TrainingTimesLastYear5_dum TrainingTimesLastYear6_dum TrainingTimesLastYearOT_dum;
where &segment=0; run;
 
proc means data=work.fortune_master_dummy_16 sum; 
var TrainingTimesLastYear0_dum TrainingTimesLastYear1_dum TrainingTimesLastYear2_dum TrainingTimesLastYear3_dum
TrainingTimesLastYear4_dum TrainingTimesLastYear5_dum TrainingTimesLastYear6_dum TrainingTimesLastYearOT_dum;
where &segment=1; run;

data work.fortune_master_dummy_16; set work.fortune_master_dummy_16;
drop count_seg_1 count_seg_0 TrainingTimesLastYear0_dum TrainingTimesLastYear1_dum TrainingTimesLastYear4_dum 
TrainingTimesLastYear5_dum TrainingTimesLastYear6_dum;
run;

/*birth_state_mi */
%let input_data 	= work.fortune_master_dummy_16; 
%let anal_var 	= birth_state_mi;
%let target_var 	= depart_dt_mi_dum; /* expanded target all annuity insurance customers */ 

*====> First, create file showing level proportions in the “yes” group;

 proc means data= &input_data noprint nway;
 	class &anal_var;
 	var &target_var;
 	output out=work.level mean = prop;
 run;
 
 proc print data=work.level; run;
 
 ods output clusterhistory=work.cluster;

proc cluster data=work.level method=ward outtree=fortree; 
	freq _freq_;
	var prop;
	id &anal_var;
run;

/* examine the hierarchical tree (dendrogram) */

proc tree data=work.fortree out=work.treeout clusters=47; id &anal_var;  run;
/* Use the FREQ procedure to get the Pearson Chi^2 statistic of the full BRANCH*INS (19 x 2) contingency table. */

proc freq data=&input_data noprint;
table &anal_var*&target_var / chisq; output out=work.chi(keep=_pchi_) chisq; run;

/* Use a one-to-many merge to put the Chi^2 statistic onto the clustering results. Calculate a (log) p-value for each level of clustering. */

data work.cutoff;
   if _n_=1 then set work.chi;
   set work.cluster;
   chisquare=_pchi_*rsquared;
   degfree=numberofclusters-1;
   logpvalue=logsdf('CHISQ',chisquare,degfree);
run;
title1 "Plot of the Log of the P-value by Number of Clusters";

proc gplot data=work.cutoff;
plot logpvalue*numberofclusters; run;
/* Fourth, create a macro variable (&ncl) that contains the number of clusters associated with the minimum log p-value. */

proc sql;
   select NumberOfClusters into :ncl
   from work.cutoff
   having logpvalue=min(logpvalue); quit;

/* Fifth, create a dataset with the cluster solution */

proc tree data=work.fortree nclusters=&ncl out=work.clus;
   id &anal_var; run;

proc sort data=work.clus; by clusname; run;

title1 "Levels of Categorical Variable by Cluster";
proc print data=work.clus;
   by clusname;
   id clusname; run;
/* Finally, merge cluster assignment onto master file and create dummies */

data work.clus2; set work.clus; drop clusname; run;
proc sort data=work.clus2; 	by &anal_var; run;
proc sort data=&input_data; 	by &anal_var; run;
data work.fortune_master_dummy_cat; merge &input_data work.clus2; by &anal_var; 
	birth_state_cus1=(cluster=1);
	birth_state_cus2=(cluster=2);
	birth_state_cus3=(cluster=3);
	birth_state_cus4=(cluster=4);
run;

%let dum_vars = birth_state_cus1 birth_state_cus2 birth_state_cus3 birth_state_cus4 ;

proc means data=work.fortune_master_dummy_cat sum; var &dum_vars; run;
proc sort data=work.fortune_master_dummy_cat; by &target_var; run;

proc means data=work.fortune_master_dummy_cat sum;
	var &dum_vars; output out=work.tmp_sum (drop = _TYPE_ _FREQ_ _STAT_)
	sum = &dum_vars;
	by &target_var; where &target_var notin(.); run;

proc transpose data=work.tmp_sum out=work.tmp_sum_t; run;

proc print data=work.tmp_sum_t; run;

data work.fortune_master_dummy_cat; set work.fortune_master_dummy_cat;
drop cluster;
run;

/*binning*/
/*birth_dt_mi*/
data work.binning_birth_dt_mi; set work.fortune_master_dummy_cat;
age = round((mdy(6,2,2018) - birth_dt_mi)/365.25);
/* assume analysis is being done as of June 1, 2015 */
run;

/* The histogram is a “binned” representation of AGE, in this case, 5-year intervals */

proc univariate data=work.binning_birth_dt_mi; var age; histogram age; run;

proc means data=work.binning_birth_dt_mi n nmiss min mean max; var age; run;

/* try 6 bins equal width */
data work.binning_birth_dt_mi; set work.binning_birth_dt_mi;

if age   > 19 and age < 26 then age_dum_lt26 = 1; 		else age_dum_lt26 = 0;
if age ge 26 and age < 33 then age_dum_26_32 = 1; 	else age_dum_26_32 = 0;
if age ge 33 and age < 40 then age_dum_33_39 = 1; 	else age_dum_33_39 = 0;
if age ge 40 and age < 47 then age_dum_40_46 = 1; 	else age_dum_40_46 = 0;
if age ge 47 and age < 54 then age_dum_47_53 = 1; 	else age_dum_47_53 = 0;
if age ge 54 and age <62  then age_dum_54_62 = 1; 	else age_dum_54_62 = 0; run;

proc means data=work.binning_birth_dt_mi n nmiss min mean max sum; var  age_dum_lt26 age_dum_26_32 age_dum_33_39 age_dum_40_46 age_dum_47_53 age_dum_54_62; run;


/*binning other variables*/
/*binning DailyRate_mi*/
data work.binning_DailyRate_mi; set work.binning_birth_dt_mi;
/* assume analysis is being done as of June 1, 2015 */
run;

/* The histogram is a “binned” representation of AGE, in this case, 5-year intervals */

proc univariate data=work.binning_DailyRate_mi; var DailyRate_mi; histogram DailyRate_mi; run;

proc means data=work.binning_DailyRate_mi n nmiss min mean max; var DailyRate_mi; run;

/* try 6 bins equal width */
data work.binning_DailyRate_mi; set work.binning_DailyRate_mi;

if DailyRate_mi < 300 then DailyRate_mi_dum_lt300 = 1; 		else DailyRate_mi_dum_lt300 = 0;
if DailyRate_mi ge 300 and DailyRate_mi < 600 then DailyRate_mi_dum_300_599 = 1; 	else DailyRate_mi_dum_300_599 = 0;
if DailyRate_mi ge 600 and DailyRate_mi < 900 then DailyRate_mi_dum_600_899 = 1; 	else DailyRate_mi_dum_600_899 = 0;
if DailyRate_mi ge 900 and DailyRate_mi < 1200 then DailyRate_mi_dum_900_1199 = 1; 	else DailyRate_mi_dum_900_1199 = 0;
if DailyRate_mi ge 1200 and DailyRate_mi <1500  then DailyRate_mi_dum_1200_1500 = 1; 	else DailyRate_mi_dum_1200_1500 = 0; run;

proc means data=work.binning_DailyRate_mi n nmiss min mean max sum; var  DailyRate_mi_dum_lt300 DailyRate_mi_dum_300_599 DailyRate_mi_dum_600_899 DailyRate_mi_dum_900_1199 DailyRate_mi_dum_1200_1500; run;

/*DistanceFromHome*/
data work.binning_DistanceFromHome; set work.binning_DailyRate_mi;
/* assume analysis is being done as of June 1, 2015 */
run;

/* The histogram is a “binned” representation of AGE, in this case, 5-year intervals */

proc univariate data=work.binning_DistanceFromHome; var DistanceFromHome; histogram DistanceFromHome; run;

proc means data=work.binning_DistanceFromHome n nmiss min mean max; var DistanceFromHome; run;

/* try 6 bins equal width */
data work.binning_DistanceFromHome; set work.binning_DistanceFromHome;

if  DistanceFromHome < 7 then DistanceFromHome_dum_lt7 = 1; 		else DistanceFromHome_dum_lt7 = 0;
if DistanceFromHome ge 7 and DistanceFromHome < 14 then DistanceFromHome_dum_7_13 = 1; 	else DistanceFromHome_dum_7_13 = 0;
if DistanceFromHome ge 14 and DistanceFromHome < 21 then DistanceFromHome_dum_14_20 = 1; 	else DistanceFromHome_dum_14_20 = 0;
if DistanceFromHome ge 21 and DistanceFromHome < 29 then DistanceFromHome_dum_21_29 = 1; 	else DistanceFromHome_dum_21_29 = 0;
 run;

proc means data=work.binning_DistanceFromHome n nmiss min mean max sum; var  DistanceFromHome_dum_lt7 DistanceFromHome_dum_7_13 DistanceFromHome_dum_14_20 DistanceFromHome_dum_21_29  ; run;

/*Data Dictionary*/
data work.fortune_master ;set work.binning_DistanceFromHome;
run;

proc contents data=work.fortune_master; run;
 
data project.fortune_master; set work.fortune_master;
drop HourlyRate_grp TotalWorkingYears_grp anal_var_mean anal_var_std;
run;

proc contents data=project.fortune_master; run;

/*Task 4*/
%let anal_vars = BusinessTravel
DistanceFromHome
Education
EnvironmentSatisfaction
Gender
HourlyRate
JobInvolvement
JobLevel
JobSatisfaction
NumCompaniesWorked
OverTime
PercentSalaryHike
PerformanceRating
RelationshipSatisfaction
StockOptionLevel
TotalWorkingYears
TrainingTimesLastYear
WorkLifeBalance
YearsInCurrentRole
YearsSinceLastPromotion
YearsWithCurrManager
employee_no
fico_scr
first_name
hire_dt
ssn_num
BusinessTravelFreq_dum
BusinessTravelNon_dum
BusinessTravelRare_dum
DailyRate_mi
DailyRate_mi_dum_1200_1500
DailyRate_mi_dum_300_599
DailyRate_mi_dum_600_899
DailyRate_mi_dum_900_1199
DailyRate_mi_dum_lt300
Department_new
Department_newHR_dum
Department_newRD_dum
Department_newSa_dum
DistanceFromHome_dum_14_20
DistanceFromHome_dum_21_29
DistanceFromHome_dum_7_13
DistanceFromHome_dum_lt7
Education1_dum
Education2_dum
Education3_dum
Education4_dum
Education5_dum
EducationField_new
EducationField_newLS_dum
EducationField_newMD_dum
EducationField_newMk_dum
EducationField_newOT_dum
EducationField_newTE_dum
EnvironmentSatisfaction1_dum
EnvironmentSatisfaction2_dum
EnvironmentSatisfaction3_dum
EnvironmentSatisfaction4_dum
GenderF_dum
GenderM_dum
GenderNA_dum
JobInvolvement1_dum
JobInvolvement2_dum
JobInvolvement3_dum
JobInvolvement4_dum
JobLevel1_dum
JobLevel2_dum
JobLevel3_dum
JobLevel4_dum
JobLevel5_dum
JobSatisfaction1_dum
JobSatisfaction2_dum
JobSatisfaction3_dum
JobSatisfaction4_dum
MaritalStatus_mi
MaritalStatus_mi_Divorce_dum
MaritalStatus_mi_Married_dum
MaritalStatus_mi_Single_dum
MaritalStatus_mi_Unknown_dum
MonthlyIncome_mi
OverTimeN_dum
OverTimeY_dum
PerformanceRating3_dum
PerformanceRating4_dum
RelationshipSatisfaction1_dum
RelationshipSatisfaction2_dum
RelationshipSatisfaction3_dum
RelationshipSatisfaction4_dum
StockOptionLevel0_dum
StockOptionLevel1_dum
StockOptionLevel2_dum
StockOptionLevel3_dum
TrainingTimesLastYear2_dum
TrainingTimesLastYear3_dum
TrainingTimesLastYearOT_dum
WorkLifeBalance1_dum
WorkLifeBalance2_dum
WorkLifeBalance3_dum
WorkLifeBalance4_dum
age
age_dum_26_32
age_dum_33_39
age_dum_40_46
age_dum_47_53
age_dum_54_62
age_dum_lt26
birth_dt_mi
birth_state_cus1
birth_state_cus2
birth_state_cus3
birth_state_cus4
birth_state_mi
invsqrt_MonthlyIncome_mi;

proc varclus data=project.fortune_master maxeigen=.7 outtree=work.fortree maxclusters=123 short hi; 
var &anal_vars; run;

proc tree data=work.fortree horizontal; height _maxeig_; run;

/*Task5*/
%let target_var = depart_dt_mi_dum;
%let num_vars = 
DailyRate
DistanceFromHome
Education
EnvironmentSatisfaction
HourlyRate
JobInvolvement
JobLevel
JobSatisfaction
MonthlyIncome
NumCompaniesWorked
PercentSalaryHike
PerformanceRating
RelationshipSatisfaction
StockOptionLevel
TotalWorkingYears
TrainingTimesLastYear
WorkLifeBalance
YearsInCurrentRole
YearsSinceLastPromotion
YearsWithCurrManager
birth_dt
employee_no
fico_scr
hire_dt
ssn_num
BusinessTravelFreq_dum
BusinessTravelNon_dum
BusinessTravelRare_dum
DailyRate_mi
DailyRate_mi_dum
DailyRate_mi_dum_1200_1500
DailyRate_mi_dum_300_599
DailyRate_mi_dum_600_899
DailyRate_mi_dum_900_1199
DailyRate_mi_dum_lt300
Department_newHR_dum
Department_newRD_dum
Department_newSa_dum
DistanceFromHome_dum_14_20
DistanceFromHome_dum_21_29
DistanceFromHome_dum_7_13
DistanceFromHome_dum_lt7
Education1_dum
Education2_dum
Education3_dum
Education4_dum
Education5_dum
EducationField_newLS_dum
EducationField_newMD_dum
EducationField_newMk_dum
EducationField_newOT_dum
EducationField_newTE_dum
EnvironmentSatisfaction1_dum
EnvironmentSatisfaction2_dum
EnvironmentSatisfaction3_dum
EnvironmentSatisfaction4_dum
GenderF_dum
GenderM_dum
GenderNA_dum
JobInvolvement1_dum
JobInvolvement2_dum
JobInvolvement3_dum
JobInvolvement4_dum
JobLevel1_dum
JobLevel2_dum
JobLevel3_dum
JobLevel4_dum
JobLevel5_dum
JobSatisfaction1_dum
JobSatisfaction2_dum
JobSatisfaction3_dum
JobSatisfaction4_dum
MaritalStatus_mi_Divorce_dum
MaritalStatus_mi_Married_dum
MaritalStatus_mi_Single_dum
MaritalStatus_mi_Unknown_dum
MonthlyIncome_mi
MonthlyIncome_mi_dum
OverTimeN_dum
OverTimeY_dum
PerformanceRating3_dum
PerformanceRating4_dum
RelationshipSatisfaction1_dum
RelationshipSatisfaction2_dum
RelationshipSatisfaction3_dum
RelationshipSatisfaction4_dum
StockOptionLevel0_dum
StockOptionLevel1_dum
StockOptionLevel2_dum
StockOptionLevel3_dum
TrainingTimesLastYear2_dum
TrainingTimesLastYear3_dum
TrainingTimesLastYearOT_dum
WorkLifeBalance1_dum
WorkLifeBalance2_dum
WorkLifeBalance3_dum
WorkLifeBalance4_dum
age
age_dum_26_32
age_dum_33_39
age_dum_40_46
age_dum_47_53
age_dum_54_62
age_dum_lt26
birth_dt_mi
birth_dt_mi_dum
birth_state_cus1
birth_state_cus2
birth_state_cus3
birth_state_cus4
invsqrt_MonthlyIncome_mi
outlier_DailyRate_mi
outlier_DistanceFromHome
outlier_HourlyRate
outlier_MonthlyIncome_mi
outlier_PercentSalaryHike
outlier_TotalWorkingYears
outlier_YearsInCurrentRole
outlier_YearsSinceLastPromotion
outlier_YearsWithCurrManager
outlier_fico_scr
outlier_hire_dt;


proc corr data=project.fortune_master out=work.corr;
	var &target_var; with &num_vars; run;

data work.corr; set work.corr; where _TYPE_ in("CORR");
	rename &target_var = corr;
	abs_corr = abs(&target_var); run;

proc sort data=work.corr; by descending abs_corr; run;

proc print data=work.corr; var _name_ abs_corr; run;



