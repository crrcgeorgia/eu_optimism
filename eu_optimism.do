clear

use "http://caucasusbarometer.org/downloads/EU_2019_09.04.19_public.dta" , clear

set more off


/// weights
 svyset psu [pweight=indwt], strata(substratum) fpc(npsuss) singleunit(certainty) || id, fpc(nhhpsu) || _n, fpc(nadhh)


/// recodes - sett type

recode substratum (10=1) (21=2) (22=2) (23=2) (24=2) (412=2) (422=2) (31=3) (32=3) (33=3) (34=3) (411=3) (421=3) (-1=.) (-2=.) (-3=.) (-7=.) (-9=.) , gen(settypeREC)
label var settypeREC "Settlement type"

label define settypeREC 1 "Capital", modify
label define settypeREC 2 "Other Urban", modify
label define settypeREC 3 "Rural", modify
label values settypeREC settypeREC



/// recodes - Ethnicity type

recode ETHNIC (3=1) (1=2) (2=2) (4=2) (5=2) (6=2) (7=2) (-1=.) (-2=.) (-3=.) (-7=.) (-9=.) , gen(ETHNICREC)
label var ETHNICREC "Ethnicity"

label define ETHNICREC 1 "Ethnic Georgians", modify
label define ETHNICREC 2 "Ethnic Minority", modify

label values ETHNICREC ETHNICREC


/// recodes - joining EU
recode GEEUMEMB (1=1) (2=2) (3=3) (4=4) (-1=98) (-2=98) (-3=.) (-7=.) (-9=.) , gen(GEEUMEMBrec)
label var GEEUMEMBrec "When will Georgia join the EU?"

label define GEEUMEMBrec 1 "In 5 years or less", modify
label define GEEUMEMBrec 2 "In 6-10 years ", modify
label define GEEUMEMBrec 3 "In more than 10 years", modify
label define GEEUMEMBrec 4 "Never", modify
label define GEEUMEMBrec 98 "DKRA", modify
label values GEEUMEMBrec GEEUMEMBrec

/// recodes - education
recode EDUDGR (1=1) (2=1) (3=1) (4=2) (5=3) (6=3) (7=3) (8=3)  (-1=.) (-2=.) (-3=.) (-7=.) (-9=.) , gen(EDUDGRrec)
label var EDUDGRrec "Respondent's education level"

label define EDUDGRrec 1 "Secondary or lower", modify
label define EDUDGRrec 2 "Secondary technical", modify
label define EDUDGRrec 3 "Higher than secondary", modify
label define EDUDGRrec 98 "DKRA", modify
label values EDUDGRrec EDUDGRrec


/// recodes - party support

recode PARTCLSEU (1=1) (2=2) (3=3) (5=5) (4=6) (6=6) (-5=95) (-1=98) (-2=98) (-3=.) (-7=.) (-9=.), gen(PARTCLSEUrec)
label var PARTCLSEUrec "Party closest to you"


label define PARTCLSEUrec 95 "No party", modify
label define PARTCLSEUrec 1 "GD", modify
label define PARTCLSEUrec 2 "UNM", modify
label define PARTCLSEUrec 3 "Movement for Liberty-European Georgia", modify
label define PARTCLSEUrec 5 "Alliance of Patriots of Georgia", modify
label define PARTCLSEUrec 6 "Other parties", modify
label define PARTCLSEUrec 98 "DKRA", modify
label values PARTCLSEUrec PARTCLSEUrec


/// recodes - age groups

recode age (18/35=1) (36/55=2) (56/130=3) (-3=.) (-7=.) (-9=.) , gen(AGEGROUP)
label var AGEGROUP "Age group of respondent"

label define AGEGROUP 1 "18-35", modify
label define AGEGROUP 2 "36-55", modify
label define AGEGROUP 3 "Older than 55", modify
label values AGEGROUP AGEGROUP


foreach var of varlist _all {
replace `var'=98 if `var'==-1
replace `var'=99 if `var'==-2
replace `var'=95 if `var'==-5
replace `var'=. if `var'==-9
replace `var'=. if `var'==-7
replace `var'=. if `var'==-3
}



//////// multinominal regression

/// mlogit

svy: mlogit GEEUMEMBrec i.sex i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.EDUDGRrec b01.PARTCLSEUrec , base (4)  
margins, dydx(*) predict(outcome(1)) post
estimates store In5yearsORless

svy: mlogit GEEUMEMBrec i.sex i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.EDUDGRrec b01.PARTCLSEUrec , base (4)  
margins, dydx(*) predict(outcome(2)) post
estimates store From6to10years

svy: mlogit GEEUMEMBrec i.sex i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.EDUDGRrec b01.PARTCLSEUrec , base (4)  
margins, dydx(*) predict(outcome(3)) post
estimates store InMOREthan10years

svy: mlogit GEEUMEMBrec i.sex i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.EDUDGRrec b01.PARTCLSEUrec , base (4)  
margins, dydx(*) predict(outcome(4)) post
estimates store Never


svy: mlogit GEEUMEMBrec i.sex i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.EDUDGRrec b01.PARTCLSEUrec , base (4)  
margins, dydx(*) predict(outcome(98)) post
estimates store DKRA

coefplot In5yearsORless || From6to10years || InMOREthan10years || Never || DKRA, drop(_cons) xline(0) byopts(xrescale) 

/// title("In your opinion, what is the top threat to Georgia’s national security?" "By demographic variables and party support", color(dknavy*.9) tstyle(size(medium)) span)
/// subtitle("Marginal effects, 95% CIs", color(navy*.8) tstyle(size(msmall)) span)
/// note("NDI/CRRC-Georgia, April 2019")




