/*********************************************************************************************************/
/* Project:                     Analysis_Latino_Barometro & CPI                                          */
/* File name:                   ANALYSIS.DO                                         					 */
/* Description:                 - Produces some descriptive statistics of the number of qualified        */ 
/*                                providers per year.                                                    */ 
/*							    - Produces graphs of the sales of providers in other years to government */
/*								  institutions															 */
/* Log file name:               ANALYSIS_LATINO                                                  		 */
/* First logged:                2015 December 7 Updated:			                                     */
/* Programmed by:               Milenko Fadic                                                            */
/* Input  files :               CPI, LAPOP, LATINBAROMETRO												 */
/* Temp   files:                NONE                                                                     */ 
/* Output files :               None																	 */
/*                                                                                                       */
/*********************************************************************************************************/

*Initial commands
		clear
		clear matrix
		clear mata
		set more off
		macro drop  _all
		local macro drop  _all		
		global macro drop  _all
		matrix drop  _all
		capture log close

*SET WD		
	cd "ADD YOUR WD"
*DATA AVAILABLE @YEAR 2013 http://www.latinobarometro.org/latContents.jsp	

 log using "..\descriptive_statistics", replace
	 use "in_data/Latinobarometro2013Eng.dta", clear

*Number of Countries
	 distinct(idenpa)

*Dropping Spain
	 label list idenpa
	 drop if idenpa==724


/*Keep Variables of Interest */
	keep numentre numinves idenpa reg ciudad tamciud P12STGBS P13TGB_A P13TGB_B P18STGBS P26TGB_A P26TGB_B P26TGB_C  P82STNC P26TGB_D ///
	 P26TGB_E P26TGB_F P26TGB_G P36TGB_A P36TGB_B P36TGB_C P36TGB_D P36TGB_E P36TGB_F P36TGB_G P84NCA P84NCB P84NCC ///
	 P84NCD P84NCE P84NCF P84NCG P84NCH P84NCI P84NCJ P84NCK P84NCL P84NCM P84NCN P84NCO P84NCP P84NCQ P84NCR P84NCS ///
	 P84NCT P84NCU P84NCV P84NCW P84NCX P84NCY P84NCZ P85NCA P85NCB P85NCC P85NCD P85NCE P85NCF P85NCG P85NCH P85NC_B_2 ///
	 P86NC P83TNCA P83TNCB P83TNCC P83TNCD P83TNCE P83TNCF P83TNCG REEDUC_1 REEDUC_2 reedad wt


/*QUESTIONS PERTAINING TO SOCIAL MEDIA & INTERNET USAGE*/
	label list REEDAD
	label list TAMCIUD
	label list REEDUC_1

	ta P82STNC 
	ta P83TNCA
	ta P84NCW
	ta P82STNC [aw=wt] if reedad==1 & tamciud>7 /* FOR AGES 16 to 25 */
	ta P84NCW  [aw=wt] if reedad==1 & tamciud>7 
	ta P83TNCA [aw=wt] if reedad==1 & tamciud>7 
	ta P83TNCC [aw=wt] if reedad==1 & tamciud>7 /
	ta P84NCW  [aw=wt] if reedad==2 & tamciud>7  /*FOR AGES  25 to 40 */
	ta P82STNC [aw=wt] if REEDUC_1>6  /*EDUCATION-Some high school*/
	ta P82STNC [aw=wt] if REEDUC_1>6  /*EDUCATION- Some high school*/
		/*Penetration is 85%--mostly among educated and around 50 general*/

*SUMMARY 
	sum reedad [aw=wt]
	save "temp_data/barometro.dta"
	 
************************************LAPOP********************************************************	
 
*Dataset from America Barometer from 2004-2014 Obtained from *http://datasets.americasbarometer.org/database-login/index.html

*DATASET
use "in_data/AmericasBarometer.dta", clear

*VARIABLES OF INTEREST
keep pais year y1 y2 y4 www1 x_or_y np1 np1a np1b np1c np1d np2 np2a nicrefcon2 nicmuni8 nicmuni9 newsint info4 ///
info3 info2 info1 elsvb55d elsvb55e elsvb55f wt www1 weight1500 estratopri upm q2

/*CALCULATING WEIGHTS*/
	svyset upm [pw=weight1500], strata (estratopri) 
	
*TABULATE FOR EACH YEAR
	local var www1
	local var info3
	svy: ta `var' if year==2008
	svy: ta `var' if year==2010
	svy: ta `var' if year==2012		
	svy: ta `var' if year==2014

/*Used for cross within country comparison */
	svyset upm [pw=wt], strata (estratopri) 
	egen id=group(www1)
	
	
/*Data from Odd years dropped due to small numbers of observations from a subset of countries. Some questions were not asked pre 2008 */* 
	drop if year==2009 | year==2007 | year<2008
	label list pais_esp
	bysort pais year: ta www1

/*SUMMARY OF INTERNET USAGE By Country, YEAR */
*NOTE THAT USING WEIGHTS AND MY MANUAL COMMAND  PROVIDE SAME RESULT
	collapse (count) www1  , by(upm id wt pais  year)	
	gen weighted=wt*www1 
	bysort pais year: egen total= total(weighted)
	drop if id!=1
	collapse (sum) weighted (mean) total, by( id pais  year)	
	gen percent= weighted/total
	
/*Dropping observations where question was not asked*/
	drop if pais==25 | pais==24 | pais==10 | pais==24 | pais==13 | pais==28 | pais==29 

*Graph 	
	xtset pais year
	xtline percent

	
log close 

/*END OF FILE*/