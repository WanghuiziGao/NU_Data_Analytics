/*Cody 10.2*/
DATA PRINCIPAL;
  DO SUBJ = 1 TO 200;
     X1 = ROUND(RANNOR(123)*50 + 500);
     X2 = ROUND(RANNOR(123)*50 + 100 + .8*X1);
     X3 = ROUND(RANNOR(123)*50 + 100 + X1 - .5*X2);
     X4 = ROUND(RANNOR(123)*50 + .3*X1 + .3*X2 + .3*X3);
     OUTPUT;
  END;
RUN;

/*Factor Analysis*/
proc factor data = PRINCIPAL
	SCREE priors=SMC;
VAR X1-X4;
RUN;

/*Ratation*/
proc factor data = PRINCIPAL
	SCREE priors=SMC N=2 REORDER  ROUND FLAG=.3 ROTATE=VARIMAX;
VAR X1-X4;
RUN;

proc factor data = PRINCIPAL
	SCREE priors=SMC N=2 ROTATE=VARIMAX
	OUT=cody10;
VAR X1-X4;
RUN;

proc print data=cody10 (obs=10);
run;

/*Homework Week1*/
libname homework 'C:\NU SAS Data Sets';
data work.Chis2009; set homework.Adult2009; run;

proc freq data=work.Chis2009; table AB1 REGACT AE15 NUMCIG; run;
proc univariate data=work.Chis2009; var AE2 AE3 AE7 AC13 AC14 AC31 AC36 AD39W AD42W AE25AMIN AE27AMIN AC38YR; run;

data work.Chisclean; set work.Chis2009;
/*missing values treatment*/
/*change -1 to 0*/
	AD39WCL=AD39W;
	if AD39W=-1 then AD39WCL=0;
	AD42WCL=AD42W;
	if AD42W=-1 then AD42WCL=0;
	AE25AMINCL=AE25AMIN;
	if AE25AMIN=-1 then AE25AMINCL=0;
	AE27AMINCL=AE27AMIN;
	if AE27AMIN=-1 then AE27AMINCL=0;
	AC38YRCL=AC38YR;
	if AC38YR=-1 then AC38YRCL=0;
run;

proc univariate data=work.Chisclean; var AD39WCL AD42WCL AE25AMINCL AE27AMINCL AC38YRCL; run;

/*Factor Analysis*/
PROC FACTOR DATA=work.Chisclean SCREE PRIORS=SMC;
	VAR REGACT AE15 NUMCIG AE2 AE3 AE7 AC13 AC14 AC31 AC36 AD39WCL AD42WCL AE25AMINCL AE27AMINCL AC38YRCL;
run;

/*try 4 factors*/
PROC FACTOR DATA=work.Chisclean SCREE PRIORS=SMC n=4 REORDER  ROUND FLAG=.3;
	VAR REGACT AE15 NUMCIG AE2 AE3 AE7 AC13 AC14 AC31 AC36 AD39WCL AD42WCL AE25AMINCL AE27AMINCL AC38YRCL;
run;

/*try 3 factors*/
PROC FACTOR DATA=work.Chisclean SCREE PRIORS=SMC n=3 REORDER  ROUND FLAG=.3;
	VAR REGACT AE15 NUMCIG AE2 AE3 AE7 AC13 AC14 AC31 AC36 AD39WCL AD42WCL AE25AMINCL AE27AMINCL AC38YRCL;
run;

/*try 3 factors with rotation*/
PROC FACTOR DATA=work.Chisclean SCREE PRIORS=SMC n=3 REORDER  ROUND FLAG=.3 ROTATE=VARIMAX;
	VAR REGACT AE15 NUMCIG AE2 AE3 AE7 AC13 AC14 AC31 AC36 AD39WCL AD42WCL AE25AMINCL AE27AMINCL AC38YRCL;
run;

PROC FACTOR DATA=work.Chisclean SCREE PRIORS=SMC n=3 REORDER  ROUND FLAG=.3 ROTATE=VARIMAX out=Chisscore;
	VAR REGACT AE15 NUMCIG AE2 AE3 AE7 AC13 AC14 AC31 AC36 AD39WCL AD42WCL AE25AMINCL AE27AMINCL AC38YRCL;
run;

proc print data=Chisscore (obs=10);
run;

/*logistic regression*/
proc logistic data=Chisscore;
  model AB1 = REGACT AE15 NUMCIG AE2 AE3 AE7 AC13 AC14 AC31 AC36 AD39WCL AD42WCL AE25AMINCL AE27AMINCL AC38YRCL;
run;

proc logistic data=Chisscore;
  model AB1 = factor1 factor2 factor3;
run;



