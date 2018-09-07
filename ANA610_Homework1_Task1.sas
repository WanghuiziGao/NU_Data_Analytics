/*Create library on week1 files*/ 
Libname ANA610 'C:\Users\wgao\Desktop\ANA 610\Assignment\Week1\ANA 610 Homework #1 Data';

/*1 contents for cc_act_hw*/
proc contents data=ANA610.cc_act_hw; run;

/*numerical var*/
proc means data=ANA610.cc_act_hw n nmiss min mean median max; var CCBal; run;
proc means data=ANA610.cc_act_hw n nmiss min mean median max; var cc_act_id; run;
proc means data=ANA610.cc_act_hw n nmiss min mean median max; var CCPurc; run;

/*2 census_2010_z5summary*/
proc contents data=ANA610.census_2010_z5summary; run;

proc print data=ANA610.census_2010_z5summary (firstobs=1 obs=10); run;

/*numerical var*/
proc means data=ANA610.census_2010_z5summary n nmiss min mean median max; var MedianHValue; run;
proc means data=ANA610.census_2010_z5summary n nmiss min mean median max; var MedianHHInc; run;
proc means data=ANA610.census_2010_z5summary n nmiss min mean median max; var PctOwnerOcc; run;

/*character var*/
data work.char_census_2010_z5summary; set ANA610.census_2010_z5summary;
len_state=length(state); len_ZCTA5=length(ZCTA5); run;
proc means data=work.char_census_2010_z5summary n nmiss min mean median	max; var len_state len_ZCTA5; run;

/*3 chk_act_hw*/
proc contents data=ANA610.chk_act_hw; run;

proc print data=ANA610.chk_act_hw (firstobs=1 obs=30); run;

/*numerical var: ATMAmt CashBk Checks DDABal Dep DepAmt NSF NSFAmt Phone Teller chk_act_id*/
%let anal_var=ATMAmt CashBk Checks DDABal Dep DepAmt NSF NSFAmt Phone Teller chk_act_id;
proc means data=ANA610.chk_act_hw n nmiss min mean median max; var &anal_var; run;

/*categorical var*/
proc freq data=ANA610.chk_act_hw; table ATM DirDep; run;

/*4 client_address_hw*/
proc contents data=ANA610.client_address_hw; run;

/*character var*/
data work.char_client_address_hw; set ANA610.client_address_hw;
len_CLIENT_ID=length(CLIENT_ID); len_ZIP_5=length(ZIP_5); run;
proc means data=work.char_client_address_hw n nmiss min mean median	max; var len_CLIENT_ID len_ZIP_5; run;

/*5 client_cc_act_hw*/
proc contents data=ANA610.client_cc_act_hw; run;

/*numerical var*/
proc means data=ANA610.client_cc_act_hw n nmiss min mean median max; var cc_act_id; run;

/*character var*/
data work.char_client_cc_act_hw; set ANA610.client_cc_act_hw;
len_CLIENT_ID=length(CLIENT_ID); run;
proc means data=work.char_client_cc_act_hw n nmiss min mean median	max; var len_CLIENT_ID; run;

/*6 client_chk_act_hw*/
proc contents data=ANA610.client_chk_act_hw; run;

/*numerical var*/
proc means data=ANA610.client_chk_act_hw n nmiss min mean median max; var chk_act_id; run;

/*character var*/
data work.char_client_chk_act_hw; set ANA610.client_chk_act_hw;
len_CLIENT_ID=length(CLIENT_ID); run;
proc means data=work.char_client_chk_act_hw n nmiss min mean median	max; var len_CLIENT_ID; run;

/*7 client_hw*/
proc contents data=ANA610.client_hw; run;
proc print data=ANA610.client_hw (firstobs=1 obs=30); run;

/*character var*/
data work.char_client_hw; set ANA610.client_hw;
len_CLIENT_ID=length(CLIENT_ID); len_FST_NM=length(FST_NM); len_LST_NM=length(LST_NM); len_ZIP_5=length(ZIP_5); run;
proc means data=work.char_client_hw n nmiss min mean median	max; var len_CLIENT_ID len_FST_NM len_LST_NM len_ZIP_5; run;

/*date var*/
proc tabulate data=char_client_hw;
var birth_dt orig_dt; 
table birth_dt orig_dt, n nmiss (min mean median max)*f=mmddyy10.; run;

data work.year_client_hw; set ANA610.client_hw;
year_birth_dt=year(birth_dt); year_orig_dt=year(orig_dt); run;

proc freq data=work.year_client_hw;
table year_birth_dt year_orig_dt; run;

/*8 client_ins_act_hw*/
proc contents data=ANA610.client_ins_act_hw; run;

/*numerical var*/
proc means data=ANA610.client_ins_act_hw n nmiss min mean median max; var ins_act_id; run;

/*character var*/
data work.char_client_ins_act_hw; set ANA610.client_ins_act_hw;
len_CLIENT_ID=length(CLIENT_ID); run;
proc means data=work.char_client_ins_act_hw n nmiss min mean median	max; var len_CLIENT_ID; run;

/*9 client_ira_act_hw*/
proc contents data=ANA610.client_ira_act_hw; run;

/*numerical var*/
proc means data=ANA610.client_ira_act_hw n nmiss min mean median max; var ira_act_id; run;

/*character var*/
data work.char_client_ira_act_hw; set ANA610.client_ira_act_hw;
len_CLIENT_ID=length(CLIENT_ID); run;
proc means data=work.char_client_ira_act_hw n nmiss min mean median	max; var len_CLIENT_ID; run;

/*10 client_mmk_act_hw*/
proc contents data=ANA610.client_mmk_act_hw; run;

/*numerical var*/
proc means data=ANA610.client_mmk_act_hw n nmiss min mean median max; var mmk_act_id; run;

/*character var*/
data work.char_client_mmk_act_hw; set ANA610.client_mmk_act_hw;
len_CLIENT_ID=length(CLIENT_ID); run;
proc means data=work.char_client_mmk_act_hw n nmiss min mean median	max; var len_CLIENT_ID; run;

/*11 client_mtg_act_hw*/
proc contents data=ANA610.client_mtg_act_hw; run;

/*numerical var*/
proc means data=ANA610.client_mtg_act_hw n nmiss min mean median max; var mtg_act_id; run;

/*character var*/
data work.char_client_mtg_act_hw; set ANA610.client_mtg_act_hw;
len_CLIENT_ID=length(CLIENT_ID); run;
proc means data=work.char_client_mtg_act_hw n nmiss min mean median	max; var len_CLIENT_ID; run;

/*12 client_sav_act_hw*/
proc contents data=ANA610.client_sav_act_hw; run;

/*numerical var*/
proc means data=ANA610.client_sav_act_hw n nmiss min mean median max; var sav_act_id; run;

/*character var*/
data work.char_client_sav_act_hw; set ANA610.client_sav_act_hw;
len_CLIENT_ID=length(CLIENT_ID); run;
proc means data=work.char_client_sav_act_hw n nmiss min mean median	max; var len_CLIENT_ID; run;

/*13 credit_bureau_hw.txt*/
proc import datafile='C:\Users\wgao\Desktop\ANA 610\Assignment\Week1\ANA 610 Homework #1 Data\credit_bureau_hw.txt' out=work.credit_bureau_hw; run;

proc contents data=work.credit_bureau_hw; run;

/*numerical var: CLIENT_ID FICO_CR_SCR FST_TL_YR TL_CNT*/
%let anal_var=CLIENT_ID FICO_CR_SCR FST_TL_YR TL_CNT;
proc means data=work.credit_bureau_hw n nmiss min mean median max; var &anal_var; run;

/*14 ins_act_hw*/
proc contents data=ANA610.ins_act_hw; run;

/*numerical var*/
proc means data=ANA610.ins_act_hw n nmiss min mean median max; var ins_act_id; run;

/*date var*/
data work.char_ins_act_hw; set ANA610.ins_act_hw;
proc tabulate data=char_ins_act_hw;
var ins_act_open_dt; 
table ins_act_open_dt, n nmiss (min mean median max)*f=mmddyy10.; run;

data work.year_ins_act_hw; set ANA610.ins_act_hw;
year_ins_act_open_dt=year(ins_act_open_dt); run;

proc freq data=work.year_ins_act_hw;
table year_ins_act_open_dt; run;

/*15 ira_act_hw*/
proc contents data=ANA610.ira_act_hw; run;

/*numerical var: IRABal ira_act_id*/
%let anal_var=IRABal ira_act_id;
proc means data=ANA610.ira_act_hw n nmiss min mean median max; var &anal_var; run;

/*16 mmk_act_hw*/
proc contents data=ANA610.mmk_act_hw; run;

/*numerical var: MMBal mmk_act_id*/
%let anal_var=MMBal mmk_act_id;
proc means data=ANA610.mmk_act_hw n nmiss min mean median max; var &anal_var; run;

/*17 mtg_act_hw*/
proc contents data=ANA610.mtg_act_hw; run;

/*numerical var: MTGBal mtg_act_id*/
%let anal_var=MTGBal mtg_act_id;
proc means data=ANA610.mtg_act_hw n nmiss min mean median max; var &anal_var; run;

/*18 sav_act_hw*/
proc contents data=ANA610.sav_act_hw; run;

/*numerical var: SavBal sav_act_id*/
%let anal_var=SavBal sav_act_id;
proc means data=ANA610.sav_act_hw n nmiss min mean median max; var &anal_var; run;

/*19 State_FIPS.csv*/
proc import datafile='C:\Users\wgao\Desktop\ANA 610\Assignment\Week1\ANA 610 Homework #1 Data\State_FIPS.csv' out=work.State_FIPS; run;

proc contents data=work.State_FIPS; run;
proc print data=work.State_FIPS (firstobs=1 obs=30); run;

/*numerical var*/
proc means data=work.State_FIPS n nmiss min mean median max; var STATE_FIPS; run;

/*character var*/
data work.char_State_FIPS; set work.State_FIPS;
len_STATE=length(STATE); len_STATE_NAME=length(STATE_NAME); run;
proc means data=work.char_State_FIPS n nmiss min mean median max; var len_STATE len_STATE_NAME; run;

/* merge insurance files */
proc sort data=ANA610.client_ins_act_hw; 	by ins_act_id; run;
proc sort data=ANA610.ins_act_hw; 		by ins_act_id; run;

data work.client_ins; merge ANA610.client_ins_act_hw ANA610.ins_act_hw; by ins_act_id; run;

/* merge checking files */
proc sort data=ANA610.client_chk_act_hw; 	by chk_act_id; run;
proc sort data=ANA610.chk_act_hw; 		by chk_act_id; run;

data work.client_chk; merge ANA610.client_chk_act_hw ANA610.chk_act_hw; by chk_act_id; run;

/* merge mortgage files */
proc sort data=ANA610.client_mtg_act_hw; 	by mtg_act_id; run;
proc sort data=ANA610.mtg_act_hw; 		by mtg_act_id; run;

data work.client_mtg; merge ANA610.client_mtg_act_hw ANA610.mtg_act_hw; by mtg_act_id; run;

/* merge ira files */
proc sort data=ANA610.client_ira_act_hw; 	by ira_act_id; run;
proc sort data=ANA610.ira_act_hw; 		by ira_act_id; run;

data work.client_ira; merge ANA610.client_ira_act_hw ANA610.ira_act_hw; by ira_act_id; run;

/* merge cc files */
proc sort data=ANA610.client_cc_act_hw; 	by cc_act_id; run;
proc sort data=ANA610.cc_act_hw; 		by cc_act_id; run;

data work.client_cc; merge ANA610.client_cc_act_hw ANA610.cc_act_hw; by cc_act_id; run;

/* merge sav files */
proc sort data=ANA610.client_sav_act_hw; 	by sav_act_id; run;
proc sort data=ANA610.sav_act_hw; 		by sav_act_id; run;

data work.client_sav; merge ANA610.client_sav_act_hw ANA610.sav_act_hw; by sav_act_id; run;

/* merge mmk files */
proc sort data=ANA610.client_mmk_act_hw; 	by mmk_act_id; run;
proc sort data=ANA610.mmk_act_hw; 		by mmk_act_id; run;

data work.client_mmk; merge ANA610.client_mmk_act_hw ANA610.mmk_act_hw; by mmk_act_id; run;

/* merge census data with state_fips, then merge with client address data */
proc import datafile='C:\Users\wgao\Desktop\ANA 610\Assignment\Week1\ANA 610 Homework #1 Data\State_FIPS.csv' out=work.state_fips replace; run;

data work.census; set ANA610.census_2010_z5summary;
	keep zip_5 state_fips MedianHValue MedianHHInc PctOwnerOcc;
		zip_5 = zcta5; state_fips = input(state,2.); run;
proc contents data=work.census; run;

proc sort data=work.census; 		by state_fips; run;
proc sort data=work.state_fips; 		by state_fips; run;

data work.census2; merge work.census (in=a) work.state_fips; by state_fips; if a; run;

/*now merge census data onto client_address data*/
proc sort data=ANA610.client_address_hw; 	by zip_5; run;
proc sort data=work.census2; 			by zip_5; run;

data work.client_address; merge ANA610.client_address_hw (in=a) work.census2; by zip_5; if a; run;


/*merge credit info for .txt*/
proc import datafile='C:\Users\wgao\Desktop\ANA 610\Assignment\Week1\ANA 610 Homework #1 Data\credit_bureau_hw.txt' out=work.credit_bureau; run;
data work.credit_bureau_nu; set work.credit_bureau;
	client_id_nu = client_id; 
	drop client_id;
	run;
data work.client_hw_nu; set ANA610.client_hw;
	client_id_nu = input(client_id,10.); run;
 
proc sort data=work.credit_bureau_nu; 			by client_id_nu; run;
proc sort data=work.client_hw_nu; 			by client_id_nu; run;

data work.annuity_master_nu;
merge work.client_hw_nu (in=a) work.credit_bureau_nu; by client_id_nu; if a; run;
proc contents data=work.annuity_master_nu; run;

data work.annuity_master_merge; set work.annuity_master_nu;
drop client_id_nu; run;
proc contents data=work.annuity_master_merge; run;

/*merge all the others*/
proc sort data=work.annuity_master_merge; 		by client_id; run;
proc sort data=work.client_ins; 		by client_id; run;
proc sort data=work.client_chk; 		by client_id; run;
proc sort data=work.client_mtg; 		by client_id; run;
proc sort data=work.client_ira; 		by client_id; run;
proc sort data=work.client_cc; 		by client_id; run;
proc sort data=work.client_sav; 		by client_id; run;
proc sort data=work.client_mmk; 		by client_id; run;
proc sort data=work.client_address;		by client_id; run;

data work.annuity_master;
	merge work.annuity_master_merge (in=a) work.client_ins work.client_chk work.client_mtg work.client_ira work.client_cc work.client_sav work.client_mmk work.client_address; by client_id; if a;

  if ins_act_id notin ("  ") then ins = 1; else ins = 0;
  if chk_act_id notin ("  ") then chk = 1; else chk = 0;
  if mtg_act_id notin ("  ") then mtg = 1; else mtg = 0;
  if cc_act_id  notin ("  ") then cc  = 1; else cc  = 0;
  if sav_act_id notin ("  ") then sav = 1; else sav = 0; 
  if ira_act_id notin ("  ") then ira = 1; else ira = 0;
  if mmk_act_id notin ("  ") then mmk = 1; else mmk = 0;

array red ddabal cashbk checks dirdep nsf nsfamt phone teller atm atmamt dep depamt ;
  	do i = 1 to dim(red); if chk_act_id in ("  ") and red(i) = . then red(i) = 0; end;
  array blue mtgbal;
  	do i = 1 to dim(blue); if mtg_act_id in ("  ") and blue(i) = . then blue(i) = 0; end;   
  array yellow irabal;
  	do i = 1 to dim(yellow); if ira_act_id in ("  ") and yellow(i) = . then yellow(i) = 0; end;   
  array black ccbal ccpurc;
  	do i = 1 to dim(black); if cc_act_id in ("  ") and black(i) = . then black(i) = 0; end;   
  array brown savbal;
  	do i = 1 to dim(brown); if sav_act_id in ("  ") and brown(i) = . then brown(i) = 0; end; 
  array green mmbal;
  	do i = 1 to dim(green); if mmk_act_id in ("  ") and green(i) = . then green(i) = 0; end; 

if sum (ins, chk, mtg, cc, sav, ira) >= 1
and (mdy(6,1,2015) - birth_dt)/365 ge 18
and orig_dt le mdy(6,1,2014)
and fico_cr_scr ge 650
and mmk_act_id notin(.)
then mmk_q = 1; 

else if sum (ins, chk, mtg, cc, sav, ira) >= 1
and (mdy(6,1,2015) - birth_dt)/365 ge 18
and orig_dt le mdy(6,1,2014)
and fico_cr_scr ge 650
and mmk_act_id in(.)
then mmk_q = 0; 

   drop i; run;

proc contents data=work.annuity_master; run;

proc freq data=work.annuity_master; table mmk_q; run;

/*modeling sample*/
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id notin(.); quit;
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id notin(.) and sum (ins, chk, mtg, cc, sav, ira) >= 1; quit;
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id notin(.) and (mdy(6,1,2015) - birth_dt)/365 ge 18; quit;
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id notin(.) and orig_dt le mdy(6,1,2014); quit;
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id notin(.) and fico_cr_scr ge 650; quit;
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id in(.); quit;
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id in(.) and sum (ins, chk, mtg, cc, sav, ira) >= 1; quit;
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id in(.) and (mdy(6,1,2015) - birth_dt)/365 ge 18; quit;
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id in(.) and orig_dt le mdy(6,1,2014); quit;
proc sql; select count(*) as obs_count from work.annuity_master where mmk_act_id in(.) and fico_cr_scr ge 650; quit;

/*save modeling sample dataset*/
data ANA610.annuity_master; set work.annuity_master; run;
