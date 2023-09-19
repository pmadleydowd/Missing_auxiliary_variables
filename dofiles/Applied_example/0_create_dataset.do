*** Syntax template for direct users preparing datasets using child and parent based datasets.

* Created 29th October 2014 - always create a datafile using the most up to date template.
* Updated 24th May 2018 - mothers questionnaire and clinic data now dealt with separately in order to take into account separate withdrawal of consent requests.
* Updated 1st October 2018 - adding partners withdrawal of control
* Updated 12th October 2018 - cohort profile dataset has been updated and so version number updated to reflect
* Updated 9th November 2018 - ends of file paths for A, B and C files
* Updated 13th February 2019 - added checks in each section for correct withdrawal of consent frequencies
* Updated 21st February 2019 - updated withdrawal of consent frequencies
* Updated 5th March 2019 - updated withdrawal of consent frequencies
* Updated 11th March 2019 - updated withdrawal of consent frequencies
* Updated 9th May 2019 - updated withdrawal of consent frequencies
* Updated 17th March 2019 - updated withdrawal of consent frequencies
* Updated 9th August 2019 - updated withdrawal of consent frequencies
* Updated 4th Sept 2019 - updated withdrawal of consent frequencies
* Updated 24th March 2020 - updated withdrawal of consent frequencies
* Updated 5th August 2020 - updated withdrawal of consent frequencies
* Updated 9th September 2020 - updated withdrawal of consent frequencies
* Updated 25th May 2021 - updated withdrawal of consent frequencies
* Updated 27th May 2021 - updated withdrawal of consent frequencies
* Updated 3rd June 2021 - added clarification of where to inlcude variable lists
* Updated 6th Sept 2021 - updated withdrawal of consent frequencies
* Updated 21st Sept 2021 - updated withdrawal of consent frequencies (child-complete)
* Updated 2nd February 2022- information added re WOCs for longitudinal datasets
* Updated 16th February 2022 - updated withdrawal of consent frequencies (partner, child-complete)
* Updated 25th February 2022 - updated withdrawal of consent frequencies (mother q, mother c, child b), ethnicity variables removed from template to be add if needed and covered by proposal
* Updated 10th March 2022 - updated withdrawal of consent frequencies (partner)
* Updated 1st April 2022 - updated withdrawal of consent frequencies (mother q, mother c, child b)
* Updated 28th April 2022 - updated withdrawal of consent frequencies (mother q, mother c, child b)
* Updated 18th August 2022 - updated following combination of CP and KZ files
* Updated 8th September 2022 - updated withdrawal of consent frequencies (mother q, mother c, child b)
* Updated 16th September 2022 - updated withdrawal of consent frequencies (mother q, mother c, child b)
* Updated 4th November 2022 - updated MZ file changes (absorbing bestgest variable and renaming basic enrolment variables) and combining mother q and mother clinic WOCs and therefore combining those two sections into one
*    						- also adding in pz file to define partner files.
* Updates 8th December 2022 - correction to figures for baseline mother cases (from 15,445 to 15,447) and child-based/complete woc figures.
* Updated 21st December 2022 - added instruction in mother section to keep section even if mother data isn't used. 
* Updated 13th January 2023 - updated withdrawal of consent frequencies (child c)




****************************************************************************************************************************************************************************************************************************
* This template is based on that used by the data buddy team and they include a number of variables by default.
* To ensure the file works we suggest you keep those in and just add any relevant variables that you need for your project.
* To add data other than that included by default you will need to add the relvant files and pathnames in each of the match commands below.
* There is a separate command for mothers questionnaires, mothers clinics, partner, mothers providing data on the child and data provided by the child themselves.
* Each has different withdrawal of consent issues so they must be considered separately.
* You will need to replace '$Datadir\Applied_example' in each section with your working directory pathname.

*****************************************************************************************************************************************************************************************************************************.

* G0 Mother (pregnancy) based files - include here all files related to the pregnancy and/or mother

* If no mother variables are required, KEEP this section and remove the instruction below to run it..

clear
set maxvar 32767	
use "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Other\Cohort Profile\mz_6a.dta", clear
sort aln
gen in_mz=1
merge 1:1 aln using "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Quest\Mother\a_3e.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Quest\Mother\b_4f.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Quest\Mother\c_8a.dta", nogen
keep aln mz010a preg_in_alsp preg_in_core preg_enrol_status mz005l mz005m mz013 mz014 mz028b ///
a006 a525 ///
b032 b650 b663 - b667 b659 b670 b671 ///
c645a c755 c765 ///
bestgest


*keep only those pregnancies enrolled in ALSPAC
keep if preg_enrol_status < 3

* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before bestgest, so replace the *** line above with additional variables. 
* If none are required remember to delete the *** line.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that mother based WoCs are set to .a

order aln mz010a, first
order bestgest, last

do "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\mother_WoC.do"

* Check withdrawal of consent frequencies=29 and baseline number is 15447
tab1 mz010a, mis

save "$Datadir\Applied_example\mother.dta", replace



*****************************************************************************************************************************************************************************************************************************.
/* G0 PARTNER - ***UNBLOCK SECTION WHEN REQUIRED***
* G0 Partner files - include here all files related to the G0 partner/father


use "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Other\Cohort Profile\pz_1a.dta", clear
sort aln
/*merge in any additional datasets if required*/

keep aln partner_in_alspac partner_data partner_enrolled partner_in_core pz_mult pz_multid partner_changed partner_changed_when ///
/* add your variable list here; remove this line if you are not adding any extra*/
partner_age second_partner_age


*keep in just those enrolled partners
keep if partner_in_alspac >= 1


* Removing withdrawl of consent cases *** FOR LARGE DATASETS THIS CAN TAKE A FEW MINUTES
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that partner based WoCs are set to .c

order aln partner_in_alspac, first
order partner_age second_partner_age, last

do "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\partner_WoC.do"

* Check there is a total of n=12113 G0 partners.
* Check withdrawal of consent frequencies partner=5  - currently none of these are in the formal cohort
tab1 partner_in_alspac, mis

save "$Datadir\Applied_example\partner.dta", replace 
*/





*****************************************************************************************************************************************************************************************************************************.
* G1 Child BASED files - in this section the following file types need to be placed:
* Mother completed Qs about YP
* Obstetrics file OA

* ALWAYS KEEP THIS SECTION EVEN IF ONLY CHILD COMPLETED REQUESTED, although you will need to remove the *****

use "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Other\Cohort Profile\cp_3a.dta", clear
sort aln qlet
gen in_kz=1


keep aln qlet kz011b kz021 kz030 ///
in_core in_alsp in_phase2 in_phase3 in_phase4 tripquad


* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before in_core, so replace the ***** line with additional variables.
* If none are required remember to delete the ***** line.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that child based WoCs are set to .b


order aln qlet kz021, first
order in_alsp tripquad, last

do "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\child_based_WoC.do"

* Check withdrawal of consent frequencies child based=31 (two mums of twins have withdrawn consent)
tab1 kz021, mis

save "$Datadir\Applied_example\childB.dta", replace

*****************************************************************************************************************************************************************************************************************************.
* G1 Child COMPLETED files - in this section the following file types need to be placed:
* YP completed Qs
* Puberty Qs
* Child clinic data
* Child biosamples data
* School Qs
* Obstetrics file OC
* G1 IMD for years goes in this section e.g. jan1999imd2010_crimeq5_YP
* Child longitudinal data

* If there are no child completed files, this section can be starred out.
* NOTE: having to keep kz021 tripquad just to make the withdrawal of consent work - these are dropped for this file as the ones in the child BASED file are the important ones and should take priority

use "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Other\Cohort Profile\cp_3a.dta", clear
sort aln qlet
gen in_kz=1
merge 1:1 aln qlet using "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Clinic\Child\f08_4d.dta", nogen   
merge 1:1 aln qlet using "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Clinic\Child\tf3_4c.dta", nogen   

keep aln qlet kz021 ///
f8ws112 fh6280 ///
tripquad

* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before tripquad, so replace the ***** line with additional variables.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file.  Note that mother based WoCs are set to .b

order aln qlet kz021, first
order tripquad, last

do "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\child_completed_WoC.do"

* Check withdrawal of consent frequencies child completed=30
tab1 kz021, mis

drop kz021 tripquad
save "$Datadir\Applied_example\childC.dta", replace

*****************************************************************************************************************************************************************************************************************************.
** Matching all data together and saving out the final file*.
* NOTE: any linkage data should be added here*.

use "$Datadir\Applied_example\childB.dta", clear
merge 1:1 aln qlet using "$Datadir\Applied_example\childC.dta", nogen
merge m:1 aln using "$Datadir\Applied_example\mother.dta", nogen
* IF partner data is required please unstar the following line
/* merge m:1 aln using "$Datadir\Applied_example\partner.dta", nogen */


* Remove non-alspac children.
drop if in_alsp!=1.

* Remove trips and quads.
drop if tripquad==1

drop in_alsp tripquad
save "$Datadir\Applied_example\RAW_ALSP_B4170.dta", replace

*****************************************************************************************************************************************************************************************************************************.
* QC checks*
use "$Datadir\Applied_example\RAW_ALSP_B4170.dta", clear

* Check that there are 15645 records.
count
