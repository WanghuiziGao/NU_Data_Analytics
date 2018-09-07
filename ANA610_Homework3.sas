libname week3 'C:\Users\wgao\Desktop\ANA 610\Assignment\Week3';

/*Task1*/
proc contents data=week3.S_pml_donor_hw out=work.cat_cont; run;
data work.cat_cont; set work.cat_cont; keep name nobs; run;

/* example using one variable (watch out for capitalization in the variable name) */
%let cat_var = STATE;

proc freq data=week3.S_pml_donor_hw noprint; table &cat_var / out=work.cat_counts; run;
proc freq data=work.cat_counts noprint; table &cat_var / out=work.cat_counts; run;
proc sql; select count(*) into: TotalCats from work.cat_counts; quit;

data work.new; set work.cat_cont; where name ="&cat_var"; 
	level = scan("&TotalCats", _n_);
	card_ratio = level/nobs;
run;

proc print data=work.new; run;

/*Task2*/
/*DONOR_GENDER*/
proc freq data=week3.S_pml_donor_hw; table DONOR_GENDER; run;
*====> 4 levels...can create dummies as follows;

data work.dummy_DONOR_GENDER; set week3.S_pml_donor_hw;
genderA_dum = (DONOR_GENDER="A");
genderF_dum = (DONOR_GENDER="F");  
genderM_dum = (DONOR_GENDER="M"); 
genderU_dum = (DONOR_GENDER="U");   
run;

proc means data=work.dummy_DONOR_GENDER nmiss min mean max sum; var genderA_dum genderF_dum genderM_dum genderU_dum;
run;

/*URBANICITY*/
proc freq data=week3.S_pml_donor_hw; table URBANICITY; run;
*====> 6 levels...can create dummies as follows;

data work.dummy_URBANICITY; set week3.S_pml_donor_hw;
urbanUNKNOWN_dum = (URBANICITY="?");
urbanC_dum = (URBANICITY="C");
urbanR_dum = (URBANICITY="R");
urbanS_dum = (URBANICITY="S");
urbanT_dum = (URBANICITY="T");
urbanU_dum = (URBANICITY="U");
run;

proc means data=work.dummy_URBANICITY nmiss min mean max sum; var urbanUNKNOWN_dum urbanC_dum urbanR_dum urbanS_dum urbanT_dum urbanU_dum;
run;

/*RECENCY_STATUS_96NK*/
proc freq data=week3.S_pml_donor_hw; table RECENCY_STATUS_96NK; run;
*====> 6 levels...can create dummies as follows;

data work.dummy_RECENCY_STATUS_96NK; set week3.S_pml_donor_hw;
nk96A_dum = (RECENCY_STATUS_96NK="A");
nk96E_dum = (RECENCY_STATUS_96NK="E");
nk96F_dum = (RECENCY_STATUS_96NK="F");
nk96L_dum = (RECENCY_STATUS_96NK="L");
nk96N_dum = (RECENCY_STATUS_96NK="N");
nk96S_dum = (RECENCY_STATUS_96NK="S");
run;

proc means data=work.dummy_RECENCY_STATUS_96NK nmiss min mean max sum; var nk96A_dum nk96E_dum nk96F_dum nk96L_dum nk96N_dum nk96S_dum;
run;

/*Task3 Queation1*/
data work.S_pml_donor_hw; set week3.S_pml_donor_hw; recent_star_status2 = recent_star_status + 1; run;

%let anal_var = recent_star_status2;

/* Find freq by segment level and merge onto master */
proc freq data=work.S_pml_donor_hw order=freq; table &anal_var / out=work.freq (drop = percent);
run;
*====> 23 value levels and no missing value for recent_star_status2;

proc sort data=work.freq; 		by &anal_var; run;
proc sort data=work.S_pml_donor_hw; 	by &anal_var; run;

/* Create our dummy variables while applying the check for min_count by segment level */
%let min_count = 30;

data work.dummies; merge work.S_pml_donor_hw work.freq; by &anal_var;

	array red(23) stdum_1-stdum_23;
		do i = 1 to dim(red);
			if (&anal_var = i and count ge &min_count) then red(i) = 1;
			else red(i) = 0; 
		end;

/* Create reference dummy variable “Other” if no Branch dummies created above. */

	if sum(of stdum_1-stdum_23) = 0 then stdum_oth = 1; else stdum_oth = 0; 
drop i; run;

/*check result*/
proc means data=work.dummies nmiss min mean max sum; var stdum_1-stdum_23 stdum_oth; output out=work.tmp_sum (drop = _TYPE_ _FREQ_ _STAT_)
sum = stdum_1-stdum_23 stdum_oth;
run;


/*Task3 Queation2*/
data work.S_pml_donor_hw; set week3.S_pml_donor_hw; recent_star_status2 = recent_star_status + 1; run;

%let anal_var = recent_star_status2;
%let segment = TARGET_B;

proc freq data=work.S_pml_donor_hw; table &segment; run;
*====> no missing value for TARGET_B;

/* Find freq by segment level and merge onto master */
proc sort data=work.S_pml_donor_hw; by &segment; run;
proc freq data=work.S_pml_donor_hw order=freq; table &anal_var / out=work.freq (drop = percent);
	by &segment; run;

data work.seg_1 work.seg_0; set work.freq;
	if &segment = 1 then output work.seg_1; 
	if &segment = 0 then output work.seg_0; run;

data work.seg_1; set work.seg_1; count_seg_1 = count; keep &anal_var count_seg_1; run;
data work.seg_0; set work.seg_0; count_seg_0 = count; keep &anal_var count_seg_0; run;

proc sort data=work.seg_1; 		by &anal_var; run;
proc sort data=work.seg_0; 		by &anal_var; run;
proc sort data=work.S_pml_donor_hw; 	by &anal_var; run;

/* Create our dummy variables while applying the check for min_count by segment level */

%let min_count = 30;

data work.dummies; merge work.S_pml_donor_hw work.seg_1 work.seg_0; by &anal_var;

	array red(23) stdum_1-stdum_23;
		do i = 1 to dim(red);
			if (&anal_var = i and count_seg_0 ge &min_count and count_seg_1 ge &min_count) then red(i) = 1;
			else red(i) = 0; 
		end;

/* Create reference dummy variable “Other” if no Branch dummies created above. */

	if sum(of stdum_1-stdum_23) = 0 then stdum_oth = 1; else stdum_oth = 0; 
drop i; run;

/*check result*/
proc sort data=work.dummies; by &segment; run;

proc means data=work.dummies nmiss min mean max sum; var stdum_1-stdum_23 stdum_oth; output out=work.tmp_sum (drop = _TYPE_ _FREQ_ _STAT_)
sum = stdum_1-stdum_23 stdum_oth;
by &segment; run;

proc transpose data=work.tmp_sum out=work.tmp_sum_t; run;

proc print data=work.tmp_sum_t; run;

/*Task4*/
%let input_data = week3.S_pml_donor_hw; 
%let anal_var = RECENT_STAR_STATUS;
%let target_var = Target_B;

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

proc tree data=work.fortree out=work.treeout clusters=23; id &anal_var;  run;

proc freq data=&input_data noprint;
table &anal_var*&target_var / chisq; output out=work.chi(keep=_pchi_) chisq; run;

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

proc sql;
   select NumberOfClusters into :ncl
   from work.cutoff
   having logpvalue=min(logpvalue); quit;

proc tree data=work.fortree nclusters=&ncl out=work.clus;
   id &anal_var; run;

proc sort data=work.clus; by clusname; run;

title1 "Levels of Categorical Variable by Cluster";
proc print data=work.clus;
   by clusname;
   id clusname; run;

data work.clus2; set work.clus; drop clusname; run;
proc sort data=work.clus2; 	by &anal_var; run;
proc sort data=&input_data; 	by &anal_var; run;
data work.scored; merge &input_data work.clus2; by &anal_var; 
	stdum_cus1=(cluster=1);
	stdum_cus2=(cluster=2);
	stdum_cus3=(cluster=3);
run;

%let dum_vars = stdum_cus1 stdum_cus2 stdum_cus3;

proc means data=work.scored sum; var &dum_vars; run;

proc sort data=work.scored; by &target_var; run;

proc means data=work.scored sum;
	var &dum_vars; output out=work.tmp_sum (drop = _TYPE_ _FREQ_ _STAT_)
	sum = &dum_vars;
	by &target_var; run;

proc transpose data=work.tmp_sum out=work.tmp_sum_t; run;

proc print data=work.tmp_sum_t; run;

/*Task5*/
%let anal_var = RECENT_STAR_STATUS;
%let target_var = Target_B;
%let dataset = week3.S_pml_donor_hw;

proc sort data=&dataset; by &anal_var; run;

/* calculate level data */
proc means data=&dataset sum noprint; var &target_var; by &anal_var;
	output out=work.level_sum (drop= _TYPE_ _STAT_) sum = events; run;

/* calculate total data */
proc means data=&dataset sum noprint; var &target_var;
	output out=work.total_sum (drop= _TYPE_ _STAT_) sum = tot_events; run;
data work.total_sum; set work.total_sum; drop _FREQ_;
	tot_non_events 	=	_FREQ_ - tot_events;
	tot_obs		= 	_FREQ_;
	tot_event_prob	=	tot_events/_FREQ_; run;

data work.level_sum; 
	if _n_ = 1 then set work.total_sum;
	set work.level_sum; 

non_events 	= 	_freq_ - events;
pct_events	=	(events/tot_events);
pct_non_events 	= 	(non_events/tot_non_events);

woe 		= 	log((events/tot_events)/(non_events/tot_non_events));
iv		=	((events/tot_events)-(non_events/tot_non_events))*woe;
run;

/* print out results */
proc print data=work.level_sum;
	var &anal_var _freq_ events non_events pct_events pct_non_events woe iv; run;

/* get the variable-level IV */
proc sql; select sum(iv) into: IV from work.level_sum; quit;

/*Task5 Question2*/
%let anal_var = INCOME_GROUP;
%let target_var = Target_B;
%let dataset = week3.S_pml_donor_hw;

proc sort data=&dataset; by &anal_var; run;

/* calculate level data */
proc means data=&dataset sum noprint; var &target_var; by &anal_var;
	output out=work.level_sum (drop= _TYPE_ _STAT_) sum = events; run;

/* calculate total data */
proc means data=&dataset sum noprint; var &target_var;
	output out=work.total_sum (drop= _TYPE_ _STAT_) sum = tot_events; run;
data work.total_sum; set work.total_sum; drop _FREQ_;
	tot_non_events 	=	_FREQ_ - tot_events;
	tot_obs		= 	_FREQ_;
	tot_event_prob	=	tot_events/_FREQ_; run;

data work.level_sum; 
	if _n_ = 1 then set work.total_sum;
	set work.level_sum; 

non_events 	= 	_freq_ - events;
pct_events	=	(events/tot_events);
pct_non_events 	= 	(non_events/tot_non_events);

woe 		= 	log((events/tot_events)/(non_events/tot_non_events));
iv		=	((events/tot_events)-(non_events/tot_non_events))*woe;
run;

/* print out results */
proc print data=work.level_sum;
	var &anal_var _freq_ events non_events pct_events pct_non_events woe iv; run;

/* get the variable-level IV */
proc sql; select sum(iv) into: IV from work.level_sum; quit;














