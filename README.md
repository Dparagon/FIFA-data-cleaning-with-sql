### BACKGROUND

Cleaning a FIFA dataset that contains football players profile all around the world. A total of 18979 football players in the dataset and 78 columns that entails each player information. Each column information are as follows:

ID,Name, LongName, photoUrl, playerUrl, Nationality, Age, ↓OVA, POT ,Club, Contract, Positions, Height, Weight, Preferred Foot, BOV,
Best Position, Joined, Loan Date End, Value, Wage, Release Clause, Attacking, Crossing, Finishing, Heading Accuracy, Short Passing, 
Volleys, Skill, Dribbling, Curve, FK Accuracy, Long Passing, Ball Control, Movement,A cceleration, Sprint Speed, Agility, Reactions, 
Balance, Power, Shot Power, Jumping, Stamina, Strength, Long Shots, Mentality, Aggression, Interceptions, Positioning, Vision, Penalties, 
Composure ,Defending, Marking, Standing Tackle, Sliding Tackle, Goalkeeping, GK Diving, GK Handling, GK Kicking, GK Positioning, GK Reflexes, 
Total Stats, Base Stats, W/F, SM, A/W, D/W, IR, PAC, SHO, PAS, DRI, DEF, PHY, Hits.

### DATA PROCESS

Dataset was gotten from [kaggle](https://www.kaggle.com/datasets/yagunnersya/fifa-21-messy-raw-dataset-for-cleaning-exploring) in a ZIP file format. Errors, wrong datatypes, invalid inputs and inconsistencies were identified and were corrected.
SQL Server was used for the data cleaning process.
Firstly, the whole dataset was checked by looking for duplicates and nulls. Two duplicates were found but no nulls values. Checking each of the columns, these were discovered:

Firstly, the whole dataset was checked by looking for duplicates and nulls. Two duplicates were found but no nulls values.

Checking each of the columns, these were discovered:

CLUB column - The names of some clubs have invalid characters and incorrect spellings. These characters were replaced with valid alphabet using the REPLACE().

WEIGHT column - Players weight were entered as two different unit i.e. ‘kg’ and ‘lbs’. Having these two will produce inconsistency for analysis. So, very players weight was converted to ‘kg’ value using CASE statement with CAST(), LEN() and SUBSTRING().

To convert ‘lbs’ into ‘kg’, one lbs equals 2.20462kg. First step done was to remove the measurement indicator of ‘lbs’ from all players with lbs unit using the RIGHT(),then convert their datatype to numeric datatype using CAST(). The LEN() is used to indicate the length of characters that will be removed from the column in other to get the numeric value of the weights. After been corrected, the numbers were divided with a value of 2.2046 to have the values in kg unit.

HEIGHT column - Players height was also measured in ‘ft’ and ‘cm’, problem of data inconsistency as well. Every players height were changed to ‘cm’ using the CASE statement with TRY_CONVERT(), CHARINDEX(), LEN()and SUBSTRING().

In converting ‘ft’ to ‘cm’, one foot equals 30.48cm and an inch equals 2.54cm. The CHARINDEX() was used to find the positIons of the marks while SUBSTRING() was used to extract the feet and inches values, then TRY_CONVERT() to convert the extracted values into cm by multiplying the feet by 30.48 and inches by 2.54.

CONTRACT column - The players contract starting year and its ending year were both in the same column which should be separated into different columns. Only the ending year of on loan players were known but entered as a string. Players with no contract under any club are indicated as ‘Free’ as it should.
Two new columns were created for the contract starting year and ending year as ‘Contract_start’ and ‘Contract_end’ respectively. Contract_start was created using the SUBSTRING() to extract the first 4 values of year date from the contract column and the RIGHT() to extract the last 4 values of the year date from the right hand side of the contract column for the Contract_end column. On loan players loan date was also corrected by changing the string contract format into year date by using SUBSTRING() to extract the last 4 values of the year date in their contract column.
Additional column was created as ‘Agreement_type’ to know the players that are under contract or free agent.

VALUE column - Value of each player are in euro currency but it is identified as string due to alphabet indicator of the total values (K for thousand and M for millions), this were changed for the values to be numeric and maintain data accuracy.
The euro sign were removed, decimal point were replaced, alphabet indicators were also replaced with numeric values. After the correction, the column datatype was changed to INT to perform numerical calculations.

WAGE column - The wage column relatively had same data issues of value column. These issues were corrected with same measures although only ‘K’ indicator are in this column for it is the weekly wages of each players.

RELEASE_CLAUSE column – Release clause had the data issues of numeric value entered as string. Alphabet characters were replaced with numeric values, decimal point replaced, currency sign removed and datatype changed to INT after necessary corrections.

W-F, SM, IR column – These three columns are ratings of the players from 1 to 5. Invalid character as rating symbol had to be removed for these columns to perform calculations and be recognised as a number. The symbol was removed with the SUBSTRING() by extracting the number rating only from the column. Then, datatype of each column were changed to INT.

After complete data cleaning of these columns while other columns are in the right format, some columns that are unnecessary or not needed for analysis were removed from the dataset. Also, some columns names that are not in the right format were renamed.

N.B – () means ‘function’.




