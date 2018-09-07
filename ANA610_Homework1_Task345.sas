/*Create library on week1 files*/ 
Libname ANA610 'C:\Users\wgao\Desktop\ANA 610\Assignment\Week1\ANA 610 Homework #1 Data';

proc contents data=ANA610.s_pml_donor_hw; run;

proc print data=ANA610.s_pml_donor_hw (firstobs=1 obs=20); run;

/*numerical var: CARD_PROM_12 DONOR_AGE FREQUENCY_STATUS_97NK INCOME_GROUP IN_HOUSE LAST_GIFT_AMT 
LIFETIME_AVG_GIFT_AMT LIFETIME_CARD_PROM LIFETIME_GIFT_AMOUNT LIFETIME_GIFT_COUNT LIFETIME_GIFT_RANGE 
LIFETIME_MAX_GIFT_AMT LIFETIME_MIN_GIFT_AMT LIFETIME_PROM MEDIAN_HOME_VALUE MEDIAN_HOUSEHOLD_INCOME
MONTHS_SINCE_FIRST_GIFT MONTHS_SINCE_LAST_GIFT MONTHS_SINCE_LAST_PROM_RESP MONTHS_SINCE_ORIGIN
MOR_HIT_RATE NUMBER_PROM_12 PCT_MALE_MILITARY PCT_MALE_VETERANS PCT_OWNER_OCCUPIED PCT_VIETNAM_VETERANS
PCT_WWII_VETERANS PEP_STAR PER_CAPITA_INCOME PUBLISHED_PHONE RECENT_AVG_CARD_GIFT_AMT RECENT_AVG_GIFT_AMT 
RECENT_CARD_RESPONSE_COUNT RECENT_CARD_RESPONSE_PROP RECENT_RESPONSE_COUNT RECENT_RESPONSE_PROP
RECENT_STAR_STATUS TARGET_B TARGET_D WEALTH_RATING*/
%let anal_var=CARD_PROM_12 DONOR_AGE FREQUENCY_STATUS_97NK INCOME_GROUP IN_HOUSE LAST_GIFT_AMT 
LIFETIME_AVG_GIFT_AMT LIFETIME_CARD_PROM LIFETIME_GIFT_AMOUNT LIFETIME_GIFT_COUNT LIFETIME_GIFT_RANGE 
LIFETIME_MAX_GIFT_AMT LIFETIME_MIN_GIFT_AMT LIFETIME_PROM MEDIAN_HOME_VALUE MEDIAN_HOUSEHOLD_INCOME
MONTHS_SINCE_FIRST_GIFT MONTHS_SINCE_LAST_GIFT MONTHS_SINCE_LAST_PROM_RESP MONTHS_SINCE_ORIGIN
MOR_HIT_RATE NUMBER_PROM_12 PCT_MALE_MILITARY PCT_MALE_VETERANS PCT_OWNER_OCCUPIED PCT_VIETNAM_VETERANS
PCT_WWII_VETERANS PEP_STAR PER_CAPITA_INCOME PUBLISHED_PHONE RECENT_AVG_CARD_GIFT_AMT RECENT_AVG_GIFT_AMT 
RECENT_CARD_RESPONSE_COUNT RECENT_CARD_RESPONSE_PROP RECENT_RESPONSE_COUNT RECENT_RESPONSE_PROP
RECENT_STAR_STATUS TARGET_B TARGET_D WEALTH_RATING;
proc means data=ANA610.s_pml_donor_hw n nmiss min mean median max; var &anal_var; run;

/*categorical var*/
proc freq data=ANA610.s_pml_donor_hw; table DONOR_GENDER HOME_OWNER IN_HOUSE INCOME_GROUP OVERLAY_SOURCE 
PEP_STAR PUBLISHED_PHONE RECENCY_STATUS_96NK SES TARGET_B URBANICITY WEALTH_RATING; run;

/*character var*/
data work.char_s_pml_donor_hw; set ANA610.s_pml_donor_hw;
len_CLUSTER_CODE=length(CLUSTER_CODE); len_CONTROL_NUMBER=length(CONTROL_NUMBER); len_STATE=length(STATE); run;
proc means data=work.char_s_pml_donor_hw n nmiss min mean median	max; var len_CLUSTER_CODE len_CONTROL_NUMBER len_STATE; run;


/*number of observations for orginal dataset*/
proc sql; select count(*) into : nobs from ANA610.s_pml_donor_hw; quit;

/*sort dataset by CONTROL_NUMBER, remove duplicate values and create a clean dataset */
proc sort data=ANA610.s_pml_donor_hw out=work.clean nodupkey; by CONTROL_NUMBER; run;

/*number of observations for clean dataset*/
proc sql; select count(*) into : nobs from work.clean; quit;


proc means data=ANA610.s_pml_donor_hw n nmiss min mean median max; var MOR_HIT_RATE; run;

proc univariate data=ANA610.s_pml_donor_hw nextrobs=10; var MOR_HIT_RATE;
	histogram MOR_HIT_RATE / normal;
run;


proc means data=ANA610.s_pml_donor_hw n nmiss min mean median max; var MONTHS_SINCE_LAST_PROM_RESP; run;

proc univariate data=ANA610.s_pml_donor_hw nextrobs=10; var MONTHS_SINCE_LAST_PROM_RESP;
	histogram MONTHS_SINCE_LAST_PROM_RESP / normal;
run;

proc freq data=ANA610.s_pml_donor_hw; table STATE; run;

data work.char_s_pml_donor_hw; set ANA610.s_pml_donor_hw;
len_STATE=length(STATE); run;
proc means data=work.char_s_pml_donor_hw n nmiss min mean median	max; var len_STATE; run;

data work.date_s_pml_donor_hw; set ANA610.s_pml_donor_hw; 
date_first_gift='01jun1997'd-months_since_first_gift*30.4;
date_last_gift='01jun1997'd-months_since_last_gift*30.4;
date_origin='01jun1997'd-months_since_origin*30.4;
format date_first_gift date_last_gift date_origin mmddyy10.;
run;

/*sort data by date_origin*/
proc sort data=work.date_s_pml_donor_hw; by date_origin; run;


/*sort data by date_first_gift*/
proc sort data=work.date_s_pml_donor_hw; by date_first_gift; run;

/*sort data by date_last_gift*/
proc sort data=work.date_s_pml_donor_hw; by date_last_gift; run;

data work.year_s_pml_donor_hw; set work.date_s_pml_donor_hw; 
year_origin=year(date_origin);
year_first_gift=year(date_first_gift);
year_last_gift=year(date_last_gift);
run;

proc freq data=work.year_s_pml_donor_hw; 
table year_origin; 
run;

/*sort data by LAST_GIFT_AMT*/
proc sort data=work.year_s_pml_donor_hw; by LAST_GIFT_AMT; run;

proc means data=work.year_s_pml_donor_hw mean;
var LAST_GIFT_AMT;
class year_last_gift state;
run;

proc univariate data=work.year_s_pml_donor_hw; var LAST_GIFT_AMT;
	histogram LAST_GIFT_AMT / normal;
run;

data ANA610.year_s_pml_donor_hw; set work.year_s_pml_donor_hw; run;

/*question2c resubmission*/
data work.trend; set work.year_s_pml_donor_hw;
	keep year_last_gift LAST_GIFT_AMT;

proc sort data=work.trend; by year_last_gift; run;

proc means data=work.trend n mean; var LAST_GIFT_AMT;
	class year_last_gift;
run;
