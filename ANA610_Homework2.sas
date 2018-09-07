libname week2 'C:\Users\wgao\Desktop\ANA 610\Assignment\Week2';

/*Task1 Qestion1*/
/*check missing value for CONTROL_NUMBER*/
data work.char_s_pml_donor_hw; set week2.s_pml_donor_hw;
	len_CONTROL_NUMBER=length(CONTROL_NUMBER); run;
proc means data=work.char_s_pml_donor_hw n nmiss min mean median max; 
	var len_CONTROL_NUMBER; run; /*There's no missing value for CONTROL_NUMBER*/

/*histogram before imputation*/
proc univariate data=week2.s_pml_donor_hw; var DONOR_AGE; histogram DONOR_AGE / normal;
run;

/*create missing value indicator for DONOR_AGE*/
data work.s_pml_donor_hw; set week2.s_pml_donor_hw;
	array red DONOR_AGE;
	do i = 1 to dim(red);
		if red(i) in (.) then DONOR_AGE_mi_dum = 1; else DONOR_AGE_mi_dum = 0;
	end;
	drop i; run;

/*check if correct count*/
proc means data=work.s_pml_donor_hw sum; var DONOR_AGE_mi_dum; run;

/*impute by mean*/
proc stdize data=work.s_pml_donor_hw
	method=mean
	reponly
	out=work.imputed_mean; 	
	var DONOR_AGE;
run;

/*process and merge*/
data work.imputed_mean; set work.imputed_mean (rename =(DONOR_AGE = DONOR_AGE_mi));
	keep CONTROL_NUMBER DONOR_AGE_mi DONOR_AGE_mi_dum; run;

proc sort data=work.s_pml_donor_hw; 	by CONTROL_NUMBER; run;
proc sort data=work.imputed_mean; 		by CONTROL_NUMBER; run;

data work.s_pml_donor_hw_mi; merge work.s_pml_donor_hw work.imputed_mean; by CONTROL_NUMBER;
	array red DONOR_AGE;
	do i = 1 to dim (red);
		if red(i) = . then red(i) = 0;
	end;
	drop i; run;

/*check final stats*/
proc means data=work.s_pml_donor_hw_mi n nmiss min mean median max; 
	var DONOR_AGE_mi; run;

proc means data=work.s_pml_donor_hw_mi sum; var DONOR_AGE_mi_dum; run; 

/*histogram before and after*/
proc univariate data=work.s_pml_donor_hw_mi; var DONOR_AGE DONOR_AGE_mi; histogram DONOR_AGE DONOR_AGE_mi / normal;
run;

/*impute by median*/
proc stdize data=work.s_pml_donor_hw
	method=median
	reponly
	out=work.imputed_median; 	
	var DONOR_AGE;
run;

/*process and merge*/
data work.imputed_median; set work.imputed_median (rename =(DONOR_AGE = DONOR_AGE_mi));
	keep CONTROL_NUMBER DONOR_AGE_mi DONOR_AGE_mi_dum; run;

proc sort data=work.s_pml_donor_hw; 	by CONTROL_NUMBER; run;
proc sort data=work.imputed_median; 		by CONTROL_NUMBER; run;

data work.s_pml_donor_hw_mi; merge work.s_pml_donor_hw work.imputed_median; by CONTROL_NUMBER;
	array red DONOR_AGE;
	do i = 1 to dim (red);
		if red(i) = . then red(i) = 0;
	end;
	drop i; run;

/*check final stats*/
proc means data=work.s_pml_donor_hw_mi n nmiss min mean median max; 
	var DONOR_AGE_mi; run;

proc means data=work.s_pml_donor_hw_mi sum; var DONOR_AGE_mi_dum; run; 

/*histogram before and after*/
proc univariate data=work.s_pml_donor_hw_mi; var DONOR_AGE DONOR_AGE_mi; histogram DONOR_AGE DONOR_AGE_mi / normal;
run;

/*median segmentation imputation using 12 groups of MEDIAN_HOUSEHOLD_INCOME*/
data work.s_pml_donor_hw; set week2s_pml_donor_hw;
	array red DONOR_AGE;
	do i = 1 to dim(red);
		if red(i) in (.) then DONOR_AGE_mi_dum = 1; else DONOR_AGE_mi_dum = 0;
	end;
	drop i; run;

/*PROC RANK ranks obs by MEDIAN_HOUSEHOLD_INCOME and breaks into 12 groups*/
proc rank data=work.s_pml_donor_hw out=work.s_pml_donor_hw_rank groups=12;
	var MEDIAN_HOUSEHOLD_INCOME;
	ranks MEDIAN_HOUSEHOLD_INCOME_grp; run;

proc means data=work.s_pml_donor_hw_rank median;
	class MEDIAN_HOUSEHOLD_INCOME_grp;
	var DONOR_AGE;
run;

/*sort then impute*/
proc sort data=work.s_pml_donor_hw_rank; by MEDIAN_HOUSEHOLD_INCOME_grp; run;

proc stdize data=work.s_pml_donor_hw_rank
	method=median
	reponly
	out=work.imputed_segment_median;
	var DONOR_AGE;
	by MEDIAN_HOUSEHOLD_INCOME_grp;
run;

/*process and merge*/
data work.imputed_segment_median; set work.imputed_segment_median (rename =(DONOR_AGE = DONOR_AGE_mi));
	keep CONTROL_NUMBER DONOR_AGE_mi DONOR_AGE_mi_dum;  run;

proc sort data=work.s_pml_donor_hw_rank; 	by CONTROL_NUMBER; run;
proc sort data=work.imputed_segment_median; 		by CONTROL_NUMBER; run;

data work.s_pml_donor_hw_mi; merge work.s_pml_donor_hw_rank work.imputed_segment_median; by CONTROL_NUMBER;
	array red DONOR_AGE_mi;
	do i = 1 to dim (red);
		if red(i) = . then red(i) = 0;
	end;
	drop i; run;

/*check final stats*/
proc means data=work.s_pml_donor_hw_mi median mean;
	class  MEDIAN_HOUSEHOLD_INCOME_grp;
	var DONOR_AGE DONOR_AGE_mi;
run;

/*histogram*/
proc univariate data=work.s_pml_donor_hw_mi; var DONOR_AGE DONOR_AGE_mi;
	histogram DONOR_AGE DONOR_AGE_mi / normal;
run;

/*Task1 Qestion2*/
/*check missing values for STATE*/
proc freq data=week2.s_pml_donor_hw; tables STATE; run;

/*create "Unknown" category for missing values of STATE*/
data work.s_pml_donor_hw; set week2.s_pml_donor_hw;
	if STATE in (" ") 
	then STATE_impute="Unknown";
	else if STATE notin (" ") 
	then STATE_impute=STATE;
run;

/*check result*/
proc freq data=work.s_pml_donor_hw; tables STATE_impute; run;

/*Task2 outlier check for CARD_PROM_12*/
/*Range check*/
%let anal_var = CARD_PROM_12;

proc univariate data=week2.s_pml_donor_hw nextrobs=10;
	var &anal_var;
	histogram &anal_var / normal;
run;

/*Top/bottom X%*/
proc univariate data=week2.s_pml_donor_hw; var &anal_var;
	histogram &anal_var;
	output out=work.tmp pctlpts= 1 99 pctlpre = percent; 
run;

proc print data=work.tmp; run;

data work.hi_low;
	set week2.s_pml_donor_hw;
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

proc print data=work.hi_low; var CONTROL_NUMBER &anal_var range; run;

/*Standard Deviation*/
proc means data=week2.s_pml_donor_hw noprint; var &anal_var;
	output out=work.tmp(drop = _freq_ _type_) mean=anal_var_mean std=anal_var_std; 
run;

proc print data=work.tmp; run;

%let n_std = 3;

data work.std_test;
	set week2.s_pml_donor_hw;
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
	
proc print data=work.std_test; var CONTROL_NUMBER &anal_var range; run;

/*Trimmed Statistics*/
proc rank data=week2.s_pml_donor_hw (keep=CONTROL_NUMBER &anal_var) out=work.tmp_rank groups = 20;
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
	set week2.s_pml_donor_hw;
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

proc print data=work.std_test; var CONTROL_NUMBER &anal_var range; run;

/*IQR*/
proc means data=week2.s_pml_donor_hw noprint; var &anal_var;
	output out=work.tmp(drop = _freq_ _type_) q3 = upper q1 = lower qrange = IQR;
run;

proc print data=work.tmp; run;

%let iqr_mult = 3;

data work.iqr_test;
	set week2.s_pml_donor_hw;
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

proc print data=work.iqr_test; var CONTROL_NUMBER &anal_var range; run;

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

%clust_out(week2.S_pml_donor_hw, CARD_PROM_12, CONTROL_NUMBER notin(" "), .009, work.clus_out);

/*Task2 outlier check for LIFETIME_GIFT_RANGE*/
/*Range check*/
%let anal_var = LIFETIME_GIFT_RANGE;

proc univariate data=week2.s_pml_donor_hw nextrobs=10;
	var &anal_var;
	histogram &anal_var / normal;
run;

/*Top/bottom X%*/
proc univariate data=week2.s_pml_donor_hw; var &anal_var;
	histogram &anal_var;
	output out=work.tmp pctlpts= 1 99 pctlpre = percent; 
run;

proc print data=work.tmp; run;

data work.hi_low;
	set week2.s_pml_donor_hw;
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

proc print data=work.hi_low; var CONTROL_NUMBER &anal_var range; run;

/*Standard Deviation*/
proc means data=week2.s_pml_donor_hw noprint; var &anal_var;
	output out=work.tmp(drop = _freq_ _type_) mean=anal_var_mean std=anal_var_std; 
run;

proc print data=work.tmp; run;

%let n_std = 3;

data work.std_test;
	set week2.s_pml_donor_hw;
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
	
proc print data=work.std_test; var CONTROL_NUMBER &anal_var range; run;

/*Trimmed Statistics*/
proc rank data=week2.s_pml_donor_hw (keep=CONTROL_NUMBER &anal_var) out=work.tmp_rank groups = 20;
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
	set week2.s_pml_donor_hw;
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

proc print data=work.std_test; var CONTROL_NUMBER &anal_var range; run;

/*IQR*/
proc means data=week2.s_pml_donor_hw noprint; var &anal_var;
	output out=work.tmp(drop = _freq_ _type_) q3 = upper q1 = lower qrange = IQR;
run;

proc print data=work.tmp; run;

%let iqr_mult = 3;

data work.iqr_test;
	set week2.s_pml_donor_hw;
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

proc print data=work.iqr_test; var CONTROL_NUMBER &anal_var range; run;

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

%clust_out(week2.S_pml_donor_hw, LIFETIME_GIFT_RANGE, CONTROL_NUMBER notin(" "), .005, work.clus_out);

/*Task3 Question1*/
%let anal_var = CARD_PROM_12 DONOR_AGE LAST_GIFT_AMT LIFETIME_AVG_GIFT_AMT LIFETIME_CARD_PROM LIFETIME_GIFT_AMOUNT
LIFETIME_GIFT_COUNT LIFETIME_GIFT_RANGE LIFETIME_MAX_GIFT_AMT LIFETIME_MIN_GIFT_AMT LIFETIME_PROM MEDIAN_HOME_VALUE
MEDIAN_HOUSEHOLD_INCOME MONTHS_SINCE_FIRST_GIFT MONTHS_SINCE_LAST_GIFT MONTHS_SINCE_LAST_PROM_RESP MONTHS_SINCE_ORIGIN
MOR_HIT_RATE NUMBER_PROM_12 PCT_MALE_MILITARY PCT_MALE_VETERANS PCT_OWNER_OCCUPIED PCT_VIETNAM_VETERANS 
PCT_WWII_VETERANS PER_CAPITA_INCOME RECENT_AVG_CARD_GIFT_AMT RECENT_AVG_GIFT_AMT RECENT_CARD_RESPONSE_COUNT
RECENT_CARD_RESPONSE_PROP RECENT_RESPONSE_COUNT RECENT_RESPONSE_PROP;

proc univariate data=week2.s_pml_donor_hw; var &anal_var;
	histogram &anal_var; run;

/*Task3 Question2 Standard Deviation method*/
/*CARD_PROM_12*/
%let anal_var = CARD_PROM_12;

proc means data=week2.s_pml_donor_hw noprint; var &anal_var;
	output out=work.tmp(drop = _freq_ _type_) mean=anal_var_mean std=anal_var_std; 
run;

proc print data=work.tmp; run;

%let n_std = 3;

data work.std_test;
	set week2.s_pml_donor_hw;
	if _n_ = 1 then set work.tmp;
	if &anal_var le anal_var_mean - &n_std*anal_var_std then do;
		range = "low ";
		output;
	end;
	if &anal_var ge anal_var_mean + &n_std*anal_var_std then do;
		range = "high";
		output;
	end;
	else if &anal_var lt anal_var_mean + &n_std*anal_var_std and &anal_var gt anal_var_mean - &n_std*anal_var_std then do;
		range = "mid";
		output;
	end; run;

proc freq data=work.std_test; table range; run;

/*histogram before*/
%let anal_var = CARD_PROM_12;

proc univariate data=work.std_test; var &anal_var;
	histogram &anal_var; run;

/*histogram after*/
proc univariate data=work.std_test; var &anal_var;
	histogram &anal_var; where range = "mid"; run;

/*LIFETIME_GIFT_RANGE*/
%let anal_var = LIFETIME_GIFT_RANGE;

proc means data=week2.s_pml_donor_hw noprint; var &anal_var;
	output out=work.tmp(drop = _freq_ _type_) mean=anal_var_mean std=anal_var_std; 
run;

proc print data=work.tmp; run;

%let n_std = 3;

data work.std_test;
	set week2.s_pml_donor_hw;
	if _n_ = 1 then set work.tmp;
	if &anal_var le anal_var_mean - &n_std*anal_var_std then do;
		range = "low ";
		output;
	end;
	if &anal_var ge anal_var_mean + &n_std*anal_var_std then do;
		range = "high";
		output;
	end;
	else if &anal_var lt anal_var_mean + &n_std*anal_var_std and &anal_var gt anal_var_mean - &n_std*anal_var_std then do;
		range = "mid";
		output;
	end; run;

proc freq data=work.std_test; table range; run;

/*histogram before*/
%let anal_var = LIFETIME_GIFT_RANGE;

proc univariate data=work.std_test; var &anal_var;
	histogram &anal_var; run;

/*histogram after*/
proc univariate data=work.std_test; var &anal_var;
	histogram &anal_var; where range = "mid"; run;

/*Task3 Question3*/
/*LIFETIME_GIFT_RANGE*/
%let anal_var = LIFETIME_GIFT_RANGE;

proc univariate data=week2.S_pml_donor_hw; var &anal_var;
	histogram &anal_var / normal;
run;

data work.tmp; set week2.S_pml_donor_hw;
	if &anal_var ne 0 then do;
		sq_anal_var = (&anal_var)**2;
		sqrt_anal_var = sqrt(&anal_var);
		inv_anal_var = 1/(&anal_var);
		invsqrt_anal_var = 1/(sqrt(&anal_var));
		invsq_anal_var = 1/((&anal_var)**2);
		log_anal_var = log(&anal_var);
		end;
	else do;
		sq_anal_var = 0;
		sqrt_anal_var = 0;
		inv_anal_var = 0;
		invsqrt_anal_var = 0;
		invsq_anal_var = 0;
		log_anal_var = 0;
		end;
run;

proc univariate data=work.tmp ; 
	var sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var;
	histogram sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var / normal;
run;

/*LIFETIME_MAX_GIFT_AMT*/
%let anal_var = LIFETIME_MAX_GIFT_AMT;

proc univariate data=week2.S_pml_donor_hw; var &anal_var;
	histogram &anal_var / normal;
run;

data work.tmp; set week2.S_pml_donor_hw;
	if &anal_var ne 0 then do;
		sq_anal_var = (&anal_var)**2;
		sqrt_anal_var = sqrt(&anal_var);
		inv_anal_var = 1/(&anal_var);
		invsqrt_anal_var = 1/(sqrt(&anal_var));
		invsq_anal_var = 1/((&anal_var)**2);
		log_anal_var = log(&anal_var);
		end;
	else do;
		sq_anal_var = 0;
		sqrt_anal_var = 0;
		inv_anal_var = 0;
		invsqrt_anal_var = 0;
		invsq_anal_var = 0;
		log_anal_var = 0;
		end;
run;

proc univariate data=work.tmp ; 
	var sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var;
	histogram sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var / normal;
run;

/*MOR_HIT_RATE*/
%let anal_var = MOR_HIT_RATE;

proc univariate data=week2.S_pml_donor_hw; var &anal_var;
	histogram &anal_var / normal;
run;

data work.tmp; set week2.S_pml_donor_hw;
	if &anal_var ne 0 then do;
		sq_anal_var = (&anal_var)**2;
		sqrt_anal_var = sqrt(&anal_var);
		inv_anal_var = 1/(&anal_var);
		invsqrt_anal_var = 1/(sqrt(&anal_var));
		invsq_anal_var = 1/((&anal_var)**2);
		log_anal_var = log(&anal_var);
		end;
	else do;
		sq_anal_var = 0;
		sqrt_anal_var = 0;
		inv_anal_var = 0;
		invsqrt_anal_var = 0;
		invsq_anal_var = 0;
		log_anal_var = 0;
		end;
run;

proc univariate data=work.tmp ; 
	var sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var;
	histogram sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var / normal;
run;

/*LIFETIME_MIN_GIFT_AMT*/
%let anal_var = LIFETIME_MIN_GIFT_AMT;

proc univariate data=week2.S_pml_donor_hw; var &anal_var;
	histogram &anal_var / normal;
run;

data work.tmp; set week2.S_pml_donor_hw;
	if &anal_var ne 0 then do;
		sq_anal_var = (&anal_var)**2;
		sqrt_anal_var = sqrt(&anal_var);
		inv_anal_var = 1/(&anal_var);
		invsqrt_anal_var = 1/(sqrt(&anal_var));
		invsq_anal_var = 1/((&anal_var)**2);
		log_anal_var = log(&anal_var);
		end;
	else do;
		sq_anal_var = 0;
		sqrt_anal_var = 0;
		inv_anal_var = 0;
		invsqrt_anal_var = 0;
		invsq_anal_var = 0;
		log_anal_var = 0;
		end;
run;

proc univariate data=work.tmp ; 
	var sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var;
	histogram sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var / normal;
run;

/*PCT_MALE_MILITARY*/
%let anal_var = PCT_MALE_MILITARY;

proc univariate data=week2.S_pml_donor_hw; var &anal_var;
	histogram &anal_var / normal;
run;

data work.tmp; set week2.S_pml_donor_hw;
	if &anal_var ne 0 then do;
		sq_anal_var = (&anal_var)**2;
		sqrt_anal_var = sqrt(&anal_var);
		inv_anal_var = 1/(&anal_var);
		invsqrt_anal_var = 1/(sqrt(&anal_var));
		invsq_anal_var = 1/((&anal_var)**2);
		log_anal_var = log(&anal_var);
		end;
	else do;
		sq_anal_var = 0;
		sqrt_anal_var = 0;
		inv_anal_var = 0;
		invsqrt_anal_var = 0;
		invsq_anal_var = 0;
		log_anal_var = 0;
		end;
run;

proc univariate data=work.tmp ; 
	var sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var;
	histogram sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var / normal;
run;

/*LIFETIME_AVG_GIFT_AMT*/
%let anal_var = LIFETIME_AVG_GIFT_AMT;

proc univariate data=week2.S_pml_donor_hw; var &anal_var;
	histogram &anal_var / normal;
run;

data work.tmp; set week2.S_pml_donor_hw;
	if &anal_var ne 0 then do;
		sq_anal_var = (&anal_var)**2;
		sqrt_anal_var = sqrt(&anal_var);
		inv_anal_var = 1/(&anal_var);
		invsqrt_anal_var = 1/(sqrt(&anal_var));
		invsq_anal_var = 1/((&anal_var)**2);
		log_anal_var = log(&anal_var);
		end;
	else do;
		sq_anal_var = 0;
		sqrt_anal_var = 0;
		inv_anal_var = 0;
		invsqrt_anal_var = 0;
		invsq_anal_var = 0;
		log_anal_var = 0;
		end;
run;

proc univariate data=work.tmp ; 
	var sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var;
	histogram sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var / normal;
run;

/*LAST_GIFT_AMT*/
%let anal_var = LAST_GIFT_AMT;

proc univariate data=week2.S_pml_donor_hw; var &anal_var;
	histogram &anal_var / normal;
run;

data work.tmp; set week2.S_pml_donor_hw;
	if &anal_var ne 0 then do;
		sq_anal_var = (&anal_var)**2;
		sqrt_anal_var = sqrt(&anal_var);
		inv_anal_var = 1/(&anal_var);
		invsqrt_anal_var = 1/(sqrt(&anal_var));
		invsq_anal_var = 1/((&anal_var)**2);
		log_anal_var = log(&anal_var);
		end;
	else do;
		sq_anal_var = 0;
		sqrt_anal_var = 0;
		inv_anal_var = 0;
		invsqrt_anal_var = 0;
		invsq_anal_var = 0;
		log_anal_var = 0;
		end;
run;

proc univariate data=work.tmp ; 
	var sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var;
	histogram sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var / normal;
run;

/*LIFETIME_GIFT_AMOUNT*/
%let anal_var = LIFETIME_GIFT_AMOUNT;

proc univariate data=week2.S_pml_donor_hw; var &anal_var;
	histogram &anal_var / normal;
run;

data work.tmp; set week2.S_pml_donor_hw;
	if &anal_var ne 0 then do;
		sq_anal_var = (&anal_var)**2;
		sqrt_anal_var = sqrt(&anal_var);
		inv_anal_var = 1/(&anal_var);
		invsqrt_anal_var = 1/(sqrt(&anal_var));
		invsq_anal_var = 1/((&anal_var)**2);
		log_anal_var = log(&anal_var);
		end;
	else do;
		sq_anal_var = 0;
		sqrt_anal_var = 0;
		inv_anal_var = 0;
		invsqrt_anal_var = 0;
		invsq_anal_var = 0;
		log_anal_var = 0;
		end;
run;

proc univariate data=work.tmp ; 
	var sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var;
	histogram sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var / normal;
run;

/*RECENT_AVG_GIFT_AMT*/
%let anal_var = RECENT_AVG_GIFT_AMT;

proc univariate data=week2.S_pml_donor_hw; var &anal_var;
	histogram &anal_var / normal;
run;

data work.tmp; set week2.S_pml_donor_hw;
	if &anal_var ne 0 then do;
		sq_anal_var = (&anal_var)**2;
		sqrt_anal_var = sqrt(&anal_var);
		inv_anal_var = 1/(&anal_var);
		invsqrt_anal_var = 1/(sqrt(&anal_var));
		invsq_anal_var = 1/((&anal_var)**2);
		log_anal_var = log(&anal_var);
		end;
	else do;
		sq_anal_var = 0;
		sqrt_anal_var = 0;
		inv_anal_var = 0;
		invsqrt_anal_var = 0;
		invsq_anal_var = 0;
		log_anal_var = 0;
		end;
run;

proc univariate data=work.tmp ; 
	var sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var;
	histogram sq_anal_var sqrt_anal_var inv_anal_var invsqrt_anal_var invsq_anal_var log_anal_var / normal;
run;
