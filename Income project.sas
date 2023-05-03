
*PART 1: LOADING DATA;

libname Project '/home/u63044900/Project';

PROC IMPORT out=PROJECT.Income
			DATAFILE= '/home/u63044900/Project/Rawdata.csv'
			DBMS=CSV REPLACE;
			GETNAMES=YES;
RUN;

*Create unique ID for dataset;
DATA PROJECt.Income;
set project.Income;
obs_id=_N_;
Run;

PROC PRINT DATA=PROJECT.income (obs=20);
run;	

Proc Contents Data=project.income;
run;
*	- There are 15 variables, including
+ 9 characteristic variables: Education, Income, MartialStatus, NativeCountry, Occupation, Race, Relationship, Sex, I
+ 6 numerical variables: Age, CapitalGain, CapitalLoss, EducationNum, HoursPerWeek, fnlwgt
-	There are 32,561 instances in this dataset
-	The dependent variable is "income" as the objective of analysing the dataset is to predict the income of people using the
-	The independent variable are the rest except for fnlwgt as this variable was just used to show how many times an isntance

*	Examine the target variable "Income";

PROC Freq Data=project.income; Table income;
Run;

*	The target variable ''Income" is a binary variable with two values of:
-	"<=50K" accounted for 75.92%
-	">50K" accounted for 24.08%;

*PART 2 - WORKING WITH CATEGORICAL VARIABLES;
*2.1 
*List the type, format and value for all categorical variables and check any error by using Proc Contents;
Proc Contents Data=project.income;
run;

*There are 9 Categorica variables, which are all formatted as chacarter. 
They are Education, Income, MartialStatus, NativeCountry,Occupation, Race, Relationship, Sex, Workclass;


*2.2.1;
*Check for missing value for all categorical variables by printing Proc Freq Table;
PROC Freq Data=project.income;
Table _character_;
Run;
*3 out of 9 categorical varaibles have missing values, which are 
workclass (1836 missing, 5.64% of total observations), 
occupation (1843missing, 5.66 of total observations) 
and nativecountry (583 missing, 1.79% of total observations);
*2.2.2 (infomat method to check for missing value)
*	Check for missing value for all categroical variables by using infomat method;
Data project.income_informat;
set project.income;
Run;

Proc Format;
Value $workclass "?"="Missing";
Value $occupation "?"="Missing";
VAlue $nativecountry "?"="Missing";
Run;

Proc Freq Data=project.income_informat;
table workclass occupation nativecountry;
format workclass $workclass.
       occupation $occupation.
       nativecountry $nativecountry.;
Title "Three categorical variables using the specified format";
Run;
*2.3 Treat Missing values by deleting them. 

/* Step 1: Create barchart for three variables with missing values to check the disbutions*/;

proc sgplot data=project.income;
vbar workclass;
Title "Barchart of workclass";
run;

proc sgplot data=project.income;
vbar occupation;
Title "Barchart of occupation";
run;

proc sgplot data=project.income;
vbar nativecountry;
Title "Barchart of nativecountry";
run;

* We choose to delete all missing values:
Reason 1 the proportion of missing values 
is small (less than 5% or so), you consider deleting the observations 
with missing values"?"
Reason 2 Consider the impact of missing values: the missing values 
are not likely to bias the results or affect the interpretation of 
our analysis, deleting the missing values may be more appropriate.;

/* Step2: delete the missing values of "?"for three variables*/

Data project.income_dm;
set project.income;
if workclass = "?" or occupation="?" or nativecountry ="?" then delete;
run;

Proc freq data=project.income;
table workclass occupation nativecountry;
run;

Proc freq data=project.income_dm;
table workclass occupation nativecountry;
run;

/* Step3: Only keep the observations where nativecounytry="united stated"*/

Data project.income_us;
Set project.income_dm(where=(nativecountry='United-States'));
Run;

proc freq data=project.income_us;
table nativecountry;
run;
*Part 4.4 Create one or more derived variables. ;
data new_variable;
set project.income;
Total_Hours_Worked_In_Oneyear = Hoursperweek*52;
format Total_Hours_Worked_In_Oneyear rounded.;
run;
proc print data=new_variable;
run;
*Part 2.5 Combine values in one for a categorical variable.;

proc format;
value age low-17 = 'Minor'
		  18-30 = 'Young Adult'
		  31-60 = 'Adult'
		  61-high = 'Old Adult';
value Hoursperweek low-20 = 'Part Time'
				   21-40 = 'Full Time'
				   41-High = 'OverTime';
run;
data categorical_var;
set new_variable;
format Age age. 
	   Hoursperweek Hoursperweek.;
proc print data = categorical_var(obs=20);
run;






*PART 3: NUMERICAL DATA

*Part 3.1 Check Errors of Numerical Data ;

Title 'Listing the Variables of Income Dataset';
PROC CONTENTS data=project.income;
Run;

Title 'Examining numeric variables in the Income data set';
PROC MEANS Data=project.income n nmiss min mode mean stddev max maxdec=3;
VAR _numeric_;
RUN;

Title 'Checking frequency of numeric variables';
PROC FREQ Data=project.income;
TABLES Age EducationNum CapitalGain CapitalLoss HoursPerWeek;
RUN;


Title "Running PROC UNIVARIATE on Age, Working Hours Per Week and Years of Education";
ODS Select ExtremeObs Quantiles Histogram;
proc univariate data=PROJECT.updated_income nextrobs=10;
   id obs_id;
   var Age EducationNum HoursPerWeek;
   histogram /normal;
run;

*Part 3.2 Correct erors;

Title 'Dropping Not-Used Variables';
DATA PROJECT.updated_income (Drop= capitalgain capitalloss fnlwgt);
SET PROJECT.income;
RUN;

Title 'Checking numeric variables after dropping variables';
PROC MEANS Data=project.updated_income n nmiss min mode mean max maxdec=3;
VAR _numeric_;
RUN;

*Part 3.3  Detect Outliers ;

******* AGE Variable*******;

Title ' Histogram of Age Variable';
PROC SGPLOT DATA=PROJECT.updated_income;
HISTOGRAM Age;
density Age;
run;

title "Box plot of Age Variable";
proc sgplot data=PROJECT.updated_income;
   vbox Age;
run;

title "Listing Outliers Age Based on 2 Standard Deviations";

proc means data=PROJECT.updated_income noprint;
   var Age;
   output out=Mean_Std(drop=_type_ _freq_)
          mean=
          std= / autoname;
run;

DATA _null_;
file print;
set PROJECT.updated_income (keep= obs_id Age);
if _n_=1 then set Mean_Std;
if Age lt Age_Mean-2*Age_stdDev
OR Age gt Age_Mean+2*Age_StdDev 
then put 'Possible Outlier for Age at observation number ' obs_id ' with value of ' Age;
Run;   

******* EducationNum Variable********;

Title ' Histogram of EducationNum Variable';
PROC SGPLOT DATA=PROJECT.updated_income;
HISTOGRAM EducationNum;
density EducationNum;
run;

title "Box plot of EducationNum Variable";
proc sgplot data=PROJECT.updated_income;
   vbox EducationNum;
run;

title "Listing Outliers Education Num Based on Interquartile Range";

PROC MEANS data=PROJECT.updated_income noprint;
VAR EducationNum;
output 	out=tmp
		Q1=
		Q3=
		QRANGE= / autoname;
RUN;

DATA _null_;
file print;
set PROJECT.updated_income (keep= obs_id EducationNum);
if _n_=1 then set tmp;
if 	EducationNum le EducationNum_Q1-1.5*EducationNum_QRange OR
	EducationNum ge EducationNum_Q3+1.5*EducationNum_QRange then
	put 'Possible Outlier for EducationNum at observation number ' obs_id ' with value of ' EducationNum;
RUN;

******* HoursPerWeek Variable********;

Title ' Histogram of HoursPerWeek Variable';
PROC SGPLOT DATA=PROJECT.updated_income;
HISTOGRAM HoursPerWeek;
density HoursPerWeek;
run;

title "Box plot of HoursPerWeek Variable";
proc sgplot data=PROJECT.updated_income;
   vbox HoursPerWeek;
run;

title "Listing Outliers HoursPerWeek Based on 2 Standard Deviations";

proc means data=PROJECT.updated_income noprint;
   var HoursPerWeek;
   output out=MeanStd(drop=_type_ _freq_)
          mean=
          std= / autoname;
run;

DATA _null_;
file print;
set PROJECT.updated_income (keep= obs_id HoursPerWeek);
if _n_=1 then set MeanStd;
if HoursPerWeek lt HoursPerWeek_Mean-2*HoursPerWeek_stdDev
OR HoursPerWeek gt HoursPerWeek_Mean+2*HoursPerWeek_StdDev 
then put 'Possible Outlier for HoursPerWeek at observation number ' obs_id ' with value of ' HoursPerWeek;
Run;

*Part 5.4  Remove Outliers ;

******* AGE Variable********;

title "Removing Outliers Age Based on 2 Standard Deviations";

proc means data=PROJECT.updated_income noprint;
   var Age;
   output out=Mean_Std(drop=_type_ _freq_)
          mean=
          std= / autoname;
run;

DATA Age_OutliersRemoved;
set PROJECT.updated_income;
if _n_=1 then set Mean_Std;
if 	Age lt Age_Mean-2*Age_stdDev OR 
	Age gt Age_Mean+2*Age_StdDev then
	do;
		put 'Outlier removed for Age at observation number ' obs_id ' with value of ' Age;
		delete;
	end;
RUN;

Title ' Histogram of Age Variable  without outliers';
PROC SGPLOT DATA=Age_OutliersRemoved;
HISTOGRAM Age;
density Age;
run;

title "Box plot of Age Variable without outliers";
proc sgplot data=Age_OutliersRemoved;
   vbox Age;
run;

******* EducationNum Variable********;

title "Removing Outliers EducationNum Based on 2 Standard Deviations";

PROC MEANS data=PROJECT.updated_income noprint;
VAR EducationNum;
output 	out=tmp
		Q1=
		Q3=
		QRANGE= / autoname;
RUN;

DATA EducationNum_OutliersRemoved;
set PROJECT.updated_income;
if _n_=1 then set tmp;
if 	EducationNum le EducationNum_Q1-1.5*EducationNum_QRange OR
	EducationNum ge EducationNum_Q3+1.5*EducationNum_QRange then
	do;
		put 'Outlier removed for EducationNum at observation number ' obs_id ' with value of ' EducationNum;
		delete;
	end;
RUN;

Title ' Histogram of EducationNum Variable  without outliers';
PROC SGPLOT DATA=EducationNum_OutliersRemoved;
HISTOGRAM EducationNum;
density EducationNum;
run;

title "Box plot of EducationNum Variable without outliers";
proc sgplot data=EducationNum_OutliersRemoved;
   vbox EducationNum;
run;

******* HoursPerWeek Variable********;

title "Removing Outliers HoursPerWeek Based on 2 Standard Deviations";

proc means data=PROJECT.updated_income noprint;
   var HoursPerWeek;
   output out=MeanStd(drop=_type_ _freq_)
          mean=
          std= / autoname;
run;

DATA HoursPerWeek_OutliersRemoved;
set PROJECT.updated_income;
if _n_=1 then set MeanStd;
if 	HoursPerWeek lt HoursPerWeek_Mean-2*HoursPerWeek_stdDev OR 
	HoursPerWeek gt HoursPerWeek_Mean+2*HoursPerWeek_StdDev then
	do;
		put 'Outlier removed for HoursPerWeek at observation number ' obs_id ' with value of ' HoursPerWeek;
		delete;
	end;
RUN;

Title ' Histogram of HoursPerWeek Variable without outliers';
PROC SGPLOT DATA=HoursPerWeek_OutliersRemoved;
HISTOGRAM HoursPerWeek;
density HoursPerWeek;
run;

title "Box plot of HoursPerWeek Variable without outliers";
proc sgplot data=HoursPerWeek_OutliersRemoved;
   vbox HoursPerWeek;
run;

title "Tests for normality and histogram plots along with QQ plots";
ods select TestsForNormality Plots histogram;
proc univariate data= HoursPerWeek_OutliersRemoved Normal Plot;
histogram / normal;
run;


