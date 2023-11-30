*Created by emmcavoy
*Last modified: 9/9/2023
*Written in Stata 18

*Takes yearly Physician Compare data zip files and creates a cleaned data file with all the years' data for 2020-2022
*Date downloaded from https://data.cms.gov/provider-data/archived-data/doctors-clinicians


*2022
unzipfile "doctors_and_clinicians_2022.zip"
forvalues month=1(1)12{
	if `month'<10 {
		unzipfile "doctors_and_clinicians_0`month'_2022.zip" 
		shell ren "DAC_NationalDownloadableFile.csv" "0`month'_2022.csv"
	}
	else {
		unzipfile "doctors_and_clinicians_`month'_2022.zip"
		shell ren "DAC_NationalDownloadableFile.csv" "`month'_2022.csv"
	}
}

*2021
unzipfile "doctors_and_clinicians_2021.zip"
forvalues month=1(1)12{
	if `month'<10 {
		unzipfile "doctors_and_clinicians_0`month'_2021.zip" 
		shell ren "DAC_NationalDownloadableFile.csv" "0`month'_2021.csv"
	}
	else {
		unzipfile "doctors_and_clinicians_`month'_2021.zip"
		shell ren "DAC_NationalDownloadableFile.csv" "`month'_2021.csv"
	}
}
shell ren "mj5m-pzi6.csv" "01_2021.csv"

*2020
unzipfile "doctors_and_clinicians_archive_2020.zip"
foreach month in 08 10 11 12{
	unzipfile "doctors_and_clinicians_archive_`month'_2020.zip"
	shell ren "mj5m-pzi6.csv" "`month'_2020.csv"
}
shell ren "pdc_s3_physician_data_mj5m_pzi6.csv" "08_2020.csv"



*Combinding all the csv files into 1 data file per year
*2022
clear
gen year=0
save "PhysicianCompare_2022",replace
clear
forvalues month=1(1)12{
	if `month'<10 {
		import delimited "0`month'_2022.csv", stringcols(_all)
	}
	else {
		import delimited "`month'_2022.csv", stringcols(_all)
	}
	keep npi gndr pri_spec zip
	gen year=2022
	rename zip zipcode
	append using "PhysicianCompare_2022", force
	save "PhysicianCompare_2022", replace
	clear
}

*2021
clear
gen year=0
save "PhysicianCompare_2021",replace
clear
forvalues month=1(1)12{
	if `month'<10 {
		import delimited "0`month'_2021.csv", stringcols(_all)
	}
	else {
		import delimited "`month'_2021.csv", stringcols(_all)
	}
	keep npi gndr pri_spec zip
	gen year=2021
	rename zip zipcode
	append using "PhysicianCompare_2021", force
	save "PhysicianCompare_2021", replace
	clear
}

*2020
clear
gen year=0
save "PhysicianCompare_2020",replace
clear
foreach month in 08 10 11 12{
	import delimited "`month'_2020.csv", stringcols(_all)
	keep npi gndr pri_spec zip
	gen year=2020
	rename zip zipcode
	append using "PhysicianCompare_2020", force
	save "PhysicianCompare_2020", replace
	clear
}


*Combine 2020-2022 into 1 file, drop duplicates, and create share %
gen year=0
save "PhysicianCompare_2020-2022",replace
clear
forvalues year=2020(1)2022{
	use "PhysicianCompare_`year'.dta", clear
	gen zip5=substr(zipcode,1,5)
	drop zipcode
	*Create original row id
	*If npi shows up in multiple months, it keeps the first zip code in the latest month's data, e.g., December if npi appears in every month's data for that year
	gen r= _n
	sort npi zip5 year r
	*Drop duplicates across multiple month files
	quietly by npi zip5 year:gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup
	*Keep first 5 zip codes per npi year
	sort npi year r
	quietly by npi year:gen dup = cond(_N==1,0,_n)
	drop if dup>5
	drop dup
	*Share assumes equal split among all the listed zip codes
	quietly by npi:gen share = (1/_N)
	append using "PhysicianCompare_2020-2022", force
	save "PhysicianCompare_2020-2022", replace
	clear
}
