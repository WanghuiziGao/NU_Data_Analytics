libname homework 'C:\NU SAS Data Sets';
data work.Chis2009; set homework.Adult2009; run;

/*2*/
proc freq data=work.Chis2009; 
table REGACT SRSEX; run;

proc means data=work.Chis2009;
	var AE7 AC31 AC38YR;
run;

proc sort data = work.Chis2009;
  by REGACT;
run;

proc means data=work.Chis2009 mean;
	by REGACT;	
	var AE7 AC31 AC38YR;
run;

proc corr data=work.Chis2009;
var AE7 AC31 AC38YR;
run;

/*3*/
data work.Chisclean; set work.Chis2009;
	AC38YRCL=AC38YR;
	if AC38YR=-1 then AC38YRCL=0;
run;

proc univariate data=work.Chisclean; 
var AC38YRCL; 
run;

proc sort data = work.Chisclean;
  by REGACT;
run;
proc means data = work.Chisclean;
  by REGACT;
  var AC38YRCL;
run;

/*4*/
proc glm data = work.Chisclean;
  class REGACT;
  model AE7 AC31 AC38YRCL = REGACT SRSEX/ SS3;
  manova h = REGACT;
  contrast 'Regular Physical Exercise vs No Physical Exercise' REGACT   1  0 -1;
  contrast 'Regular Physical Exercise vs Some Physical Exercise' REGACT 1 -1  0;
  contrast 'Some Physical Exercise vs No Physical Exercise'  REGACT     0  1 -1;
  contrast 'Any Physical Exercise vs No Physical Exercise' REGACT       1  1 -2;
run;
