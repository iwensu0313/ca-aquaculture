FDA SHRIMP IMPORT REFUSAL README

Food and Drug Administration Database

Source: Received raw and tidied data in Excel format from WWF aquaculture lead Madeleine Craig
Downloaded: 
Timeseries: 2014-2018
Format: XLSX
Metadata:
Notes: Separated .xlsx file tabs into separate .csv files in the raw data folder. Made slight modifications to column names to make appropriate for CSV wrangling.


* FDA_Import_Refusals_MASTER.xlsx - master copy received from WWF
Master copy including all refusals and shrimp refusals as provided by WWF

* FDA_Import_Refusals_Code.csv - "ACT Section Charges" tab in master version
Code descriptions for import refusals

* Shrimp_Import_Refusals.csv - "SHRIMP Refusals-Original" tab in master version
The original subset of import refusals pertaining to shrimp aquaculture

* Shrimp_Import_Refusals_ext.csv - "Shrimp w Address & Ref Charges" tab in master version
Madeleine's tidied version of the Shrimp Import Refusals data, adding in descriptions for refusal codes, full addresses, and country names. I changed date column from "7-Oct-14" to "10/7/2014" before saving so R can recognize it as a date.