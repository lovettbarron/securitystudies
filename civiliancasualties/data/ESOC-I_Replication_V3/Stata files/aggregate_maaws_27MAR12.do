********************************************************************************* This file generates variables used in "Can Hearts and Minds Be Bought?" at
** various levels of geographic or temporal aggregation. Set your path and it
** should run fine.
**** Tiffany Chou, Jacob N. Shapiro, and Choon Wang** March 2012*******************************************************************************clearset mem 1g* cd "your/path" 
********************************************************************************************** This .do file cleans the data, identifies projects to drop based on suspicious spending and* coding errors, and then provides a roll-up at the district/month level by category.***********************************************************************************************use maaws_20091002_07feb08districts_public.dta, clear
* Generate duration variablesgen float duration = Actual_Finish - Actual_Start + 1replace duration = Forecast_Finish - Actual_Start + 1 if Actual_Finish == .label var duration "# of project days"* Drop miscoded projects and those not yet starteddrop if duration<0drop if Construction_Cost<=0 | Construction_Cost==.drop if Actual_Start==.drop if Forecast_Finish==. & Actual_Finish==.* Need to make duration at least 1 for all projects where it's zeroreplace duration=1 if duration==0* Generate run_rategen float run_rate = Construction_Cost/durationlabel var run_rate "Spending per day"*** Now generate indicators for different kinds of projects ****************** Generate CERPgen cerp = (Program == "CERP")label var cerp "CERP project"** Generate conditional indicatorgen conditional = (Program == "CERP" | Program == "CHRRP" | Program == "OHDACA")label var conditional "CERP,CHRRP,OHDACA"** Generate unconditional indicatorgen unconditional=(conditional==0)
label var unconditional "Projects other than CERP-like programs"** Generate indicator for CAPgen cap = (Sub_Sector=="Community Action Program (CAP)")label var cap "CAP project"** Generate indicator for CSPgen csp = (Sub_Sector=="Community Stabilization Program (CSP) in Strategic Cities.")label var csp "CSP project"** Generate indicator for democracy buildinggen democracy = (Sub_Sector=="Democracy Building Activities (06000)" | Sub_Sector=="Law & Governance")label var democracy "democracy project"** Generate indicator for educationgen education = (Sub_Sector=="Education" | Sub_Sector=="Education (06300)")label var education "education project"** Generate indicator for electricitygen electricity = (Sub_Sector=="Electricity")label var electricity "elec. project"** Generate indicator for healthcaregen healthcare = (Sub_Sector=="Healthcare" | Sub_Sector=="Nationwide Hospital & Clinic Improvements (90000)")label var healthcare "healthcare project"** Generate indicator for large projectsgen large = (Construction_Cost > 100000 & conditional == 0 & soi == 0 & run_rate > 5000)label var large "non-CERP projects over 100000"** Generate indicator for public building projectsgen pubbuild = (Sub_Sector=="Public Buildings - Construction & Repair (81000)" )label var pubbuild "public building project"** Generate indicator for transportationgen transport = (Sub_Sector=="Transportation" | Sub_Sector=="Roads & Bridges (82000)" )label var transport "transportation project"** Generate indicator for USAID projectsgen usaid= (Executing_Agency =="USAID")label var usaid "USAID project"** Generate indicator for water and sanitationgen watersan = (Sub_Sector=="Water & Sanitation" | Sub_Sector=="Potable Water (60000)" | Sub_Sector=="Sewerage (62000)")label var watersan "water/sanitation project"** Generate indicator for DFI funds gen dfi = (Fund_Type=="Development Fund for Iraq")label var dfi "DFI project"** Generate indicator for IRRF funds 
gen irrf = (Program=="IRRF" | Program=="IRRF1")label var irrf "IRRF project"** Generate indicator for CERP that excludes non-SOI CERPgen cerp_nonsoi = (cerp==1 & soi==0)label var cerp_nonsoi "CERP excluding SOI"** Generate indicator for large and small CERP gen cerp_large = (cerp==1 & Construction_Cost >50000)label var cerp_large "Large CERP Projects (>$50k)"gen cerp_small = (cerp==1 & Construction_Cost <=50000)label var cerp_small "Small CERP Projects (<$50k)"* Tag reconstruction projects gen recon = (Worktype=="Reconstruction")label var recon "reconstruction project"* Tag projects that are small-scale and conditional by reconstruction or non-constructiongen recon_c = (recon & conditional)label var recon_c "CERP reconstruction"gen notrec_c = (recon & conditional==0)label var notrec_c "CERP non-construction"* Note: month_spent = ms_c + ms_u* The other spending categories do not necessarily exclude CERP.** Generate non-cerp versions of variableslocal wh1 "cap csp democracy education electricity healthcare large pubbuild recon soi transport usaid watersan dfi irrf"foreach x of local wh1 {	gen `x'_noncerp = (`x'==1 & cerp==0)	label var `x'_noncerp "`x' excluding CERP projects"	}** Generate terminated program indicatorgen byte terminated = (Status == "Terminated Contractor Default" | Status == "Terminated Gov. Convenience")label var terminated "terminated project"** Generate an indicator for suspicious projects, not including SOI payments in thosegen byte sus = (duration<30 & Construction_Cost>900000 & soi == 0)label var sus "suspicious projects"** Generate indicator for dropped projects because termination, and suspiciousgen byte obsdrop = (conditional == 1 & sus ==1) | (terminated == 1) ** Drop outlier observationsdrop if obsdrop==1 & soi == 0** Drop long-lived projects that seem uncredible. drop if duration > 1845** Save it.
compresssave maaws_using.dta, replace** Collapse it
use maaws_using.dta, clearkeep uri District Governorate Construction_Cost Actual_Start soi duration run_rate cerp-irrf_noncerp 

* Generate duration within units
gen finishdate = Actual_Start + duration - 1format finishdate %td* Run collapse to desired unit
local unit "District"
local time "h"
foreach z of local time {
	foreach i of local unit {
		
		* First need to expand to the number of t units
		gen dur_`z' = `z'ofd(finishdate) - `z'ofd(Actual_Start) + 1		label var dur_`z' "# proj `z's"
		expand dur_`z'
		bysort uri: gen timeunit = `z'ofd(Actual_Start) + _n - 1		bysort uri: gen startdate = dof`z'(timeunit)		bysort uri: gen enddate = dof`z'(timeunit + 1) - 1		label var startdate "proj start date, this `z'"		label var enddate "proj end date, this `z'"		* fix start/end dates to match actual start/end dates		bysort uri: replace startdate = Actual_Start if _n==1		bysort uri: replace enddate = finishdate if _n==_N		* Add in number of days for period
		gen numdays = enddate - startdate + 1		label var numdays "# of proj days this `z'"		* Generate month_spent		gen spent = run_rate*numdays		label var spent "spending in `z'"

		* Generate spending variables
		foreach x of varlist soi cerp-irrf_noncerp {			gen spent_`x' = run_rate * `x'			label var spent_`x' "Spending on `x'"			}
		* Now generate variable to count projects		egen tag_p = tag(uri)		label var tag_p "tag: project"
		foreach x of varlist soi cerp-irrf_noncerp {
			replace `x' = `x'*tag_p			ren `x' np_`x'			}
		
		* Prep for collapse
		compress
		gen year = year(dof`z'(timeunit))
		gen `z' = timeunit
		drop if year<2003 | year > 2009
		save "maws_precollapse_`i'_`z'.dta", replace		*Collapse data and clean up, including making rectangular, this may take awhile....		collapse (sum) spent* ///			(sum) np_* tag_p, ///			by(`i' `z') 
		ren tag_p np
		fillin `i' `z'
		qui foreach k of varlist spent* np* {
			replace `k' = 0 if _fillin==1
			}
			
		* Add in time variables
		if "`z'" == "y" {
			gen year = `z'
			}
		else if "`z'" == "h" {
			gen half = `z'
			gen year = yofd(dofh(`z'))
			}
		else if "`z'" == "q" {
			gen quarter = `z'
			gen half = hofd(dofq(`z'))
			gen year = yofd(dofq(`z'))
			}
		else if "`z'" == "m" {
			gen month = `z'
			gen quarter = qofd(dofm(`z'))
			gen half = hofd(dofm(`z'))
			gen year = yofd(dofm(`z'))
			}
		else if "`z'" == "w" {
			gen week = `z'
			gen month = mofd(dofw(`z'))
			gen quarter = qofd(dofw(`z'))
			gen half = hofd(dofw(`z'))
			gen year = yofd(dofw(`z'))
			}
		else {
			display "whoops!"
			}

		* Save the data
		compress
		label data "Spending by `i' `z'"		save esoc-iraq-v3_recon_spending_`i'_`z'.dta, replace
	}
}

