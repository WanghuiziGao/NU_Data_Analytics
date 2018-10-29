libname homework 'C:\NU SAS Data Sets';
data work.Chis2009; set homework.Adult2009; run;

/*Data Quality Issue*/
proc format;
	value AB1_fmt 1='Excellent' 2='Verygood' 3='Good' 4='Fair' 5='Poor';
	value REGACT_fmt 1='Regular' 2='Some' 3='No';
	value AE15_fmt 1='Yes' 2='No';
	value BINGE12_fmt 1='No' 2='Onceayear' 3='Lessthanmonthly' 4='Monthly' 5='Lessthanweekly' 6='Dailyorweekly';
run;

proc freq data=Chis2009;
	table AB1 REGACT AE15 BINGE12;
	format AB1 AB1_fmt. REGACT REGACT_fmt. AE15 AE15_fmt. BINGE12 BINGE12_fmt.;
run;

/*Recoding*/
data work.Chisclean; set work.Chis2009;
	keep AB1 REGACT AE15 BINGE12;
run;

/*physical activity*/
data work.Chisclean; set work.Chisclean;
	if REGACT=3 then physicalact=0; *no physical activity; 
	if REGACT=2 then physicalact=1; *some physical activity;
	if REGACT=1 then physicalact=2; *regular physical activity;
/*smoking*/
	if AE15=2 then smoking=0; *no;
	else smoking=1; *yes;
/*binge drinking*/
	if BINGE12=1 then bingedr=0; *no;
	else bingedr=1; *yes;
	drop REGACT AE15 BINGE12;	
run;

/*check recoding result*/
proc format;
	value physicalact_fmt 0='No' 1='Some' 2='Regular';
	value smoking_fmt 0='No' 1='Yes';
	value bingedr_fmt 0='No' 1='Yes';
run;

proc freq data=Chisclean;
	table physicalact smoking bingedr;
	format physicalact physicalact_fmt. smoking smoking_fmt. bingedr bingedr_fmt.;
run;

/*EDA*/
proc freq data=Chisclean;  *table 1;
	tables (smoking bingedr)*physicalact / chisq;
	format physicalact physicalact_fmt. smoking smoking_fmt. bingedr bingedr_fmt.;
run;

proc freq data=Chisclean;  *table 2;
	tables (physicalact smoking bingedr)*AB1 / chisq;
	format AB1 AB1_fmt. physicalact physicalact_fmt. smoking smoking_fmt. bingedr bingedr_fmt.;
run;

*Multicollinearity;
proc reg data=Chisclean;
	model AB1=physicalact smoking bingedr / vif;
run;

/*Proportionality Test*/
proc logistic data=Chisclean descending;
	class physicalact (ref = '0') smoking (ref='0') bingedr (ref='0') / param=reference;
	model AB1=physicalact smoking bingedr / rl lackfit;
run;

/*Multinomial Logistic Regression*/
proc logistic data=Chisclean descending;
	class AB1(ref = '5') physicalact (ref = '0') smoking (ref='0') bingedr (ref='0') / param=reference;
	model AB1=physicalact smoking bingedr / link=glogit rl lackfit;
run;

