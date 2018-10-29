/*8.2*/
DATA STATIN;
   DO SUBJ = 1 TO 20;
      IF RANUNI(1557) LT .5 THEN GENDER = 'FEMALE';
      ELSE GENDER = 'MALE';
      IF RANUNI(0) LT .3 THEN DIET = 'HIGH FAT';
      ELSE DIET = 'LOW FAT';
      DO DRUG = 'A','B','C';
         LDL = ROUND(RANNOR(1557)*20 + 110 
                     + 5*(DRUG EQ 'A') 
                     - 10*(DRUG EQ 'B')
                     - 5*(GENDER EQ 'FEMALE')
                     + 10*(DIET EQ 'HIGH FAT'));
         HDL = ROUND(RANNOR(1557)*10 + 20 
                     + .2*LDL 
                     + 12*(DRUG EQ 'B'));
         TOTAL = ROUND(RANNOR(1557)*20 + LDL + HDL + 50
                     -10*(GENDER EQ 'FEMALE')
                     +10*(DIET EQ 'HIGH FAT'));
         OUTPUT;
      END;
   END;
RUN;

proc print data = STATIN;
run;

proc freq data=STATIN;
	table drug;
run;

PROC ANOVA DATA=STATIN;
	CLASS SUBJ DRUG;
	MODEL LDL HDL TOTAL = SUBJ DRUG;
	MEANS DRUG / SNK; *quite similar with tukey test;
RUN;

/*8.4*/
proc freq data=STATIN;
	table drug gender;
run;

proc glm data=STATIN;
	class GENDER DRUG;
	model LDL HDL TOTAL = GENDER DRUG GENDER*DRUG;
run; 

/*Interaction Plot*/
proc means data=STATIN noprint nway;
	class drug gender;
	var LDL HDL TOTAL;
	output out=Interact mean=;
run;

symbol1 c=blue v=star h=.8 i=j;
symbol2 c=red v=dot h=.8 i=j;

proc gplot data=Interact;
	title "Interaction Plot";
	plot (LDL HDL TOTAL)*drug = Gender;
run;

/*8.8*/
PROC SORT DATA=STATIN;
   BY SUBJ;
RUN;
DATA REPEAT;
   DO I = 1 TO 3;
      SET STATIN;
      IF I = 1 THEN LDL_A = LDL;
      ELSE IF I = 2 THEN LDL_B = LDL;
      ELSE IF I = 3 THEN DO;
         LDL_C = LDL;
         OUTPUT;
      END;
   END;
   DROP LDL I DRUG;
RUN;

proc print data = REPEAT;
run;

proc glm data=REPEAT;
	class GENDER;
	model LDL_A LDL_B LDL_C = GENDER / nouni;
	repeated time 3;
	means GENDER / SNK;
run; 
