### BACKGROUND

Cleaning a FIFA dataset that contains football players profile all around the world. A total of 18979 football players in the dataset and 78 columns that entails each player information. Each column information are as follows:

ID,Name, LongName, photoUrl, playerUrl, Nationality, Age, ↓OVA, POT ,Club, Contract, Positions, Height, Weight, Preferred Foot, BOV,
Best Position, Joined, Loan Date End, Value, Wage, Release Clause, Attacking, Crossing, Finishing, Heading Accuracy, Short Passing, 
Volleys, Skill, Dribbling, Curve, FK Accuracy, Long Passing, Ball Control, Movement,A cceleration, Sprint Speed, Agility, Reactions, 
Balance, Power, Shot Power, Jumping, Stamina, Strength, Long Shots, Mentality, Aggression, Interceptions, Positioning, Vision, Penalties, 
Composure ,Defending, Marking, Standing Tackle, Sliding Tackle, Goalkeeping, GK Diving, GK Handling, GK Kicking, GK Positioning, GK Reflexes, 
Total Stats, Base Stats, W/F, SM, A/W, D/W, IR, PAC, SHO, PAS, DRI, DEF, PHY, Hits.

### DATA PROCESS

Dataset was gotten from [kaggle](https://www.kaggle.com/datasets/yagunnersya/fifa-21-messy-raw-dataset-for-cleaning-exploring) in a ZIP file format.
Errors, wrong datatypes, invalid inputs and inconsistencies were identified and were corrected.

SQL Server was used for the data cleaning process.

Firstly, the whole dataset was checked by looking for duplicates and nulls. Two duplicates were found but no nulls values.

``` sql
SELECT  LongName, Nationality, Age, Club, COUNT(*)
FROM FIFAData
GROUP BY LongName, Nationality, Age, Club
HAVING COUNT(*) > 1

SELECT COUNT(*) FROM FIFAData
WHERE Name IS NULL OR
      LongName IS NULL OR
	    Nationality IS NULL OR
	    Club IS NULL
```

Checking each of the columns, these were discovered:

* CLUB column - The names of some clubs have invalid characters and incorrect spellings. These characters were replaced with valid alphabet using the REPLACE().

```sql
UPDATE FIFAData SET club = REPLACE(club,'1.','') FROM fifa WHERE CLUB LIKE '%1.%' 
UPDATE FIFAData SET club = REPLACE(club,'ö','o') WHERE club LIKE '%ö%' 
UPDATE FIFAData SET club = REPLACE(club,'ó','o') WHERE club LIKE '%ó%' 
UPDATE FIFAData SET club = REPLACE(club,'ş','s') WHERE club LIKE '%ş%' 
UPDATE FIFAData SET club = REPLACE(club,'ä','a') WHERE club LIKE '%ä%' 
UPDATE FIFAData SET club = REPLACE(club,'ø','o') WHERE club LIKE '%ø%' 
UPDATE FIFAData SET club = REPLACE(club,'Ç','c') WHERE club LIKE '%Ç%'
UPDATE FIFAData SET club = REPLACE(club,'ğ','g') WHERE club LIKE '%ğ%' 
UPDATE FIFAData SET club = REPLACE(club,'ê','e') WHERE club LIKE '%e%' 
UPDATE FIFAData SET club = REPLACE(club,'ñ','n') WHERE club LIKE '%ñ%' 
UPDATE FIFAData SET club = REPLACE(club,'ü','u') WHERE club LIKE '%ü%' 
UPDATE FIFAData SET club = REPLACE(club,'Inter','Inter Milan')
UPDATE FIFAData SET club = REPLACE(club,'é','e') WHERE club LIKE '%é%' 
UPDATE FIFAData SET club = REPLACE(club,'Bayern München II','Bayern Munich')
UPDATE FIFAData SET club = REPLACE(club,'ê','e') WHERE club LIKE '%ê%' 
```



* WEIGHT column - Players weight were entered as two different unit i.e. ‘kg’ and ‘lbs’. Having these two will produce inconsistency for analysis. So, very players weight was converted to ‘kg’ value using CASE statement with CAST(), LEN() and SUBSTRING().

``` sql
UPDATE FIFAData SET Weight = CASE WHEN RIGHT(Weight,2) = 'lbs' 
                                  THEN CAST(SUBSTRING (Weight,1,LEN(Weight)-3) AS FLOAT) / 2.20462
				                          ELSE CAST(SUBSTRING (Weight,1,LEN(Weight)-2) AS FLOAT) 
				                          END 
```

To convert ‘lbs’ into ‘kg’, one lbs equals 2.20462kg. First step done was to remove the measurement indicator of ‘lbs’ from all players with lbs unit using the RIGHT(),then convert their datatype to numeric datatype using CAST(). The LEN() is used to indicate the length of characters that will be removed from the column in other to get the numeric value of the weights. After been corrected, the numbers were divided with a value of 2.2046 to have the values in kg unit.



* HEIGHT column - Players height was also measured in ‘ft’ and ‘cm’, problem of data inconsistency as well. Every players height were changed to ‘cm’ using the CASE statement with TRY_CONVERT(), CHARINDEX(), LEN()and SUBSTRING().

```sql
UPDATE FIFAData SET Height = CASE WHEN height LIKE '%''%"' 
                                  THEN TRY_CONVERT(DECIMAL(10,2), SUBSTRING(Height, 1, CHARINDEX('''', Height)-1)) * 30.48 + 
							      TRY_CONVERT(DECIMAL(10,2), SUBSTRING(Height, CHARINDEX('''', Height)+1, LEN(Height)- CHARINDEX('''', Height)-1)) * 2.54 
							                    WHEN height LIKE '%"' THEN TRY_CONVERT(DECIMAL(10,2), SUBSTRING(height, 1, LEN(height) - 2)) * 2.54 
							                    ELSE TRY_CONVERT(DECIMAL(10,2), SUBSTRING(Height, 1, LEN(Height) - 2)) 
							                    END
```

In converting ‘ft’ to ‘cm’, one foot equals 30.48cm and an inch equals 2.54cm. The CHARINDEX() was used to find the positIons of the marks while SUBSTRING() was used to extract the feet and inches values, then TRY_CONVERT() to convert the extracted values into cm by multiplying the feet by 30.48 and inches by 2.54.



* CONTRACT column - The players contract starting year and its ending year were both in the same column which should be separated into different columns. Only the ending year of on loan players were known but entered as a string. Players with no contract under any club are indicated as ‘Free’ as it should.
```sql
UPDATE FIFAData SET Contract = REPLACE(Contract,'~','-') 
UPDATE FIFAData SET Contract = SUBSTRING(Contract,9,4) WHERE Contract LIKE '%on%'
```
Two new columns were created for the contract starting year and ending year as ‘Contract_start’ and ‘Contract_end’ respectively. Contract_start was created using the SUBSTRING() to extract the first 4 values of year date from the contract column and the RIGHT() to extract the last 4 values of the year date from the right hand side of the contract column for the Contract_end column. On loan players loan date was also corrected by changing the string contract format into year date by using SUBSTRING() to extract the last 4 values of the year date in their contract column.
```sql
ALTER TABLE FIFAData ADD Contract_start NVARCHAR(20)
ALTER TABLE FIFAData ADD Contract_end NVARCHAR(20)

UPDATE FIFAData SET Contract_start = SUBSTRING(Contract,1,4)
UPDATE FIFAData SET Contract_end = RIGHT(Contract,4) 
```
Additional column was created as ‘Agreement_type’ to know the players that are under contract or free agent.
```sql
ALTER TABLE FIFAData ADD Agreement_type NVARCHAR(50)

UPDATE FIFAData SET Agreement_type = CASE WHEN 'contract' LIKE '%loan%' THEN 'Loan'
								          WHEN 'contract' LIKE '%free%' THEN 'Free' ELSE 'Contract' 
								          END
```



* VALUE column - Value of each player are in euro currency but it is identified as string due to alphabet indicator of the total values (K for thousand and M for millions), this were changed for the values to be numeric and maintain data accuracy.
The euro sign were removed, decimal point were replaced, alphabet indicators were also replaced with numeric values. After the correction, the column datatype was changed to INT to perform numerical calculations.
```sql
   -- Removing the currency
UPDATE FIFAData SET Value = REPLACE(Value, '€', '')
   -- Removing the Decimal point
UPDATE FIFAData SET Value = REPLACE(Value, '.', ' ')
   -- Replacing 'K' and 'M' with digits
UPDATE FIFAData SET Value = CASE WHEN value LIKE '% %' THEN REPLACE(Value,'M','00000') 
						         WHEN value LIKE '%K' THEN REPLACE(Value, 'K', '000')
						         WHEN value LIKE '%M' THEN REPLACE(Value, 'M', '000000')
						         ELSE value END 
   -- Removing spaces
UPDATE FIFAData SET Value = REPLACE(Value, ' ', '')
```



* WAGE column - The wage column relatively had same data issues of value column. These issues were corrected with same measures although only ‘K’ indicator are in this column for it is the weekly wages of each players.
```sql
   -- Removing the currency
UPDATE FIFAData SET Wage = REPLACE(Wage, '€', '')
   -- Removing the decimal point
UPDATE FIFAData SET Wage = REPLACE(Wage, '.', ' ')
   -- Replacing 'K' with digits
UPDATE FIFAData SET Wage = CASE WHEN wage LIKE '%K' THEN REPLACE(wage, 'K', '000')
					            ELSE wage END
```



* RELEASE_CLAUSE column – Release clause had the data issues of numeric value entered as string. Alphabet characters were replaced with numeric values, decimal point replaced, currency sign removed and datatype changed to INT after necessary corrections.
```sql
   -- Removing the currency
UPDATE FIFAData SET Release_Clause = REPLACE(Release_Clause,'€', '')
   -- Removing the decimal point
UPDATE FIFAData SET Release_Clause = REPLACE(Release_Clause,'.', ' ')
   -- Replacing 'K' and 'M' with digits
UPDATE FIFAData SET Release_Clause = CASE WHEN Release_Clause LIKE '% %' THEN REPLACE(Release_clause,'M','00000') 
							              WHEN Release_Clause LIKE '%K' THEN REPLACE(Release_Clause, 'K', '000')
							              WHEN Release_Clause LIKE '%M' THEN REPLACE(Release_Clause, 'M', '000000')
       						              ELSE Release_Clause 
   -- Removing spaces
UPDATE FIFAData SET Release_Clause = REPLACE(Release_Clause,' ','')
```



* W_F, SM, IR column – These three columns are ratings of the players. W_F stands for 'Weak foot rating', SM for 'Skill move rating' and IR for 'International reputation rating'. Invalid character as rating symbol had to be removed for these columns to perform calculations and be recognised as a number. The symbol was removed with the SUBSTRING() by extracting the number rating only from the column. Then, datatype of each column were changed to INT.
```sql
UPDATE FIFAData SET W_F = SUBSTRING(W_F,1,1)
UPDATE FIFAData SET SM = SUBSTRING(SM,1,1)
UPDATE FIFAData SET IR = SUBSTRING(IR,1,1)
```


After complete data cleaning of these columns while other columns are in the right format, some columns that are unnecessary or not needed for analysis were removed from the dataset. Also, some columns names that are not in the right format were renamed.
```sql
ALTER TABLE FIFAData DROP COLUMN photoUrl, playerUrl
```
```sql
SP_RENAME 'FIFAData.LongName', 'Full_name', 'COLUMN'
SP_RENAME 'FIFAData.OVA', 'Overall_rating', 'COLUMN'
SP_RENAME 'FIFAData.POT', 'Potential_rating', 'COLUMN'
SP_RENAME 'FIFAData.Weight', 'Weight_lbs', 'COLUMN'
SP_RENAME 'FIFAData.Height', 'Height_cm', 'COLUMN'
```
N.B – () means ‘function’.




