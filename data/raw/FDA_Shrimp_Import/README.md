FDA SHRIMP IMPORT REFUSAL README

Food and Drug Administration Import Refusal Database https://www.accessdata.fda.gov/scripts/ImportRefusals/index.cfm

Source: Received two sets of tidied data in Excel format from WWF aquaculture lead Madeleine Craig (January 2018). In WWF folder.
Timeseries: 2002-2018
Format: XLSX
Metadata: See link above.
Notes: Converted REFUSAL DATE to date format MM/DD/YYYY in both .xlsx files. Copied first tab in the 2014-2018 .xlsx and first three tabs in the 2002-2013 .xlsx files into a single CSV. Sorted dataset by date from oldest to newest. Made slight modifications to column names to make appropriate for CSV wrangling.


* FDA_Import_Refusals_2002-2013.xlsx - WWF master copy 
Master copy including all refusals and shrimp refusals from 2002-2013 as provided by WWF. May have different data collection method from the newer years.

* FDA_Import_Refusals_2014-2018.xlsx - WWF master copy
Master copy including all refusals and shrimp refusals from 2014-2018 as provided by WWF. May have different data collection method from the older years.

* FDA_Import_Refusals_Code.csv - "ACT Section Charges" tab in master version
Code descriptions for import refusals

* Shrimp_Import_Refusals.csv - "Shrimp w Address & Ref Charges" tab in master version
Madeleine's tidied version of the Shrimp Import Refusals data, adding in descriptions for refusal codes, full addresses, and country names. I changed date column from "7-Oct-14" to "10/7/2014" before saving so R can recognize it as a date.