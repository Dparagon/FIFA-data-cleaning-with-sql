						--# DATA CLEANING PROCESS (FIFA21 Dataset) #--

-- Overview of Dataset
SELECT * FROM FIFAData

SELECT COUNT(*) FROM FIFAData

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FIFAData'

-- Checking for Duplicates
SELECT  LongName, Nationality, Age, Club, COUNT(*)
FROM FIFAData
GROUP BY LongName, Nationality, Age, Club
HAVING COUNT(*) > 1

SELECT * FROM FIFAData WHERE LongName = 'Peng Wang' 

-- Checking for null values
 SELECT COUNT(*) FROM FIFAData
 WHERE Name IS NULL OR
       LongName IS NULL OR
	   Nationality IS NULL OR
	   Club IS NULL

--- The CLUB column ---
SELECT DISTINCT Club FROM FIFAData ORDER BY Club

   -- Replacing invalid characters from club names 
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

--- The WEIGHT column ---
SELECT DISTINCT Weight FROM FIFAData
   -- Changing WEIGHT column from 'lbs' to 'kg'
UPDATE FIFAData SET Weight = CASE WHEN RIGHT(Weight,2) = 'lbs' 
                                  THEN CAST(SUBSTRING (Weight,1,LEN(Weight)-3) AS FLOAT) / 2.20462
				                  ELSE CAST(SUBSTRING (Weight,1,LEN(Weight)-2) AS FLOAT) 
				                  END 
    -- Changing datatype
ALTER TABLE FIFAData ALTER COLUMN Weight INT

--- The HEIGHT column ---
SELECT DISTINCT Height FROM FIFAData
   -- Changing HEIGHT column from 'ft' to 'cm'
UPDATE FIFAData SET Height = CASE WHEN height LIKE '%''%"' 
                                  THEN TRY_CONVERT(DECIMAL(10,2), SUBSTRING(Height, 1, CHARINDEX('''', Height)-1)) * 30.48 + 
							      TRY_CONVERT(DECIMAL(10,2), SUBSTRING(Height, CHARINDEX('''', Height)+1, LEN(Height)- CHARINDEX('''', Height)-1)) * 2.54 
							      WHEN height LIKE '%"' THEN TRY_CONVERT(DECIMAL(10,2), SUBSTRING(height, 1, LEN(height) - 2)) * 2.54 
							      ELSE TRY_CONVERT(DECIMAL(10,2), SUBSTRING(Height, 1, LEN(Height) - 2)) 
							      END
   -- Changing datatype
ALTER TABLE FIFAData ALTER COLUMN Height FLOAT
							
--- The CONTRACT column ---
SELECT DISTINCT Contract FROM FIFAData
   -- Replacing special characters 
UPDATE FIFAData SET Contract = REPLACE(Contract,'~','-') 
UPDATE FIFAData SET Contract = SUBSTRING(Contract,9,4) WHERE Contract LIKE '%on%'
   -- Creating two new columns (Contract_start and Contract_end)
ALTER TABLE FIFAData ADD Contract_start NVARCHAR(20)

ALTER TABLE FIFAData ADD Contract_end NVARCHAR(20)
   -- Updating new columns (Contract_start and Contract_end)
UPDATE FIFAData SET Contract_start = SUBSTRING(Contract,1,4)

UPDATE FIFAData SET Contract_end = RIGHT(Contract,4) 
   -- Creating new column (Agreement_type) 
ALTER TABLE FIFAData ADD Agreement_type NVARCHAR(50)

UPDATE FIFAData SET Agreement_type = CASE WHEN 'contract' LIKE '%loan%' THEN 'Loan'
								          WHEN 'contract' LIKE '%free%' THEN 'Free' ELSE 'Contract' 
								          END

--- The VALUE column ----
SELECT DISTINCT Value FROM FIFAData
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
   -- Changing datatype
ALTER TABLE FIFAData ALTER COLUMN Value INT

--- The WAGE column ---
SELECT DISTINCT Wage FROM FIFAData
   -- Removing the currency
UPDATE FIFAData SET Wage = REPLACE(Wage, '€', '')
   -- Removing the decimal point
UPDATE FIFAData SET Wage = REPLACE(Wage, '.', ' ')
   -- Replacing 'K' with digits
UPDATE FIFAData SET Wage = CASE WHEN wage LIKE '%K' THEN REPLACE(wage, 'K', '000')
					            ELSE wage END
   -- Changing datatype
ALTER TABLE FIFAData ALTER COLUMN Wage INT

--- The RELEASE_CLAUSE column ----
SELECT Release_Clause FROM FIFAData
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
   -- Changing datatype
ALTER TABLE FIFAData ALTER COLUMN Release_Clause INT

--- The W_F/ SM/ IR column ---
SELECT W_F, SM, IR FROM FIFAData
   -- Removing characters 
UPDATE FIFAData SET W_F = SUBSTRING(W_F,1,1)

UPDATE FIFAData SET SM = SUBSTRING(SM,1,1)

UPDATE FIFAData SET IR = SUBSTRING(IR,1,1)
   -- Changing datatype
ALTER TABLE FIFAData ALTER COLUMN W_F INT

ALTER TABLE FIFAData ALTER COLUMN SM INT

ALTER TABLE FIFAData ALTER COLUMN IR INT

--- Deleting Unnecessary Columns ---
SELECT * FROM FIFAData

ALTER TABLE FIFAData DROP COLUMN photoUrl, playerUrl

--- Renaming Columns ---

SP_RENAME 'FIFAData.LongName', 'Full_name', 'COLUMN'
SP_RENAME 'FIFAData.OVA', 'Overall_rating', 'COLUMN'
SP_RENAME 'FIFAData.POT', 'Potential_rating', 'COLUMN'
SP_RENAME 'FIFAData.Weight', 'Weight_lbs', 'COLUMN'
SP_RENAME 'FIFAData.Height', 'Height_cm', 'COLUMN'




