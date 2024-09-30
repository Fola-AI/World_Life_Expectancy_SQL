/* This is World Life Expectancy Project */

SELECT *
FROM world_life_expectancy
;

					/*DATA CLEANING PHASE*/
                    
#Checking for Duplicates

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) >1
;

#Now we have identified the Duplicates lets make it a SQL table expession 
SELECT *
FROM 
	(SELECT Row_ID, CONCAT(Country, Year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS 		Row_Num
	FROM world_life_expectancy) AS Row_table
WHERE Row_Num > 1
;

DELETE FROM world_life_expectancy
WHERE
	Row_ID IN (
		SELECT Row_ID
        FROM(
			SELECT Row_ID, CONCAT(Country, Year),
			ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) 			AS Row_Num
		FROM world_life_expectancy
        ) AS Row_table
        WHERE Row_NUM > 1
    )
;
# Duplicates has been deleted

				/*DEALING WITH MISSING VALUES*/

# Status Column 

SELECT *
FROM world_life_expectancy
;

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status != ''
;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developed'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status != ''
AND t2.Status = 'Developing'
;

SELECT *
FROM world_life_expectancy
WHERE Country = 'United States of America'
;
#Update for Status = Developed

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status != ''
AND t2.Status = 'Developed'
;

#Confirm 
SELECT *
FROM world_life_expectancy
WHERE Status = ''
;
SELECT *
FROM world_life_expectancy
WHERE Status IS NULL 
;
#Empty spaces has now been updated

#Check Table 
SELECT *
FROM world_life_expectancy
;

# 'Life expectancy' column

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` IS NULL
;
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
;

#Lets use a Self join

SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
	t2.Country, t2.Year, t2.`Life expectancy`, 
	t3.Country, t3.Year, t3.`Life expectancy`,
    (ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)) 
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

#Update empty Life expectancy column with (ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)) 

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = (ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)) 
WHERE t1.`Life expectancy` = ''
;


#check table
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;


							/*EXPLORATORY DATA ANALYSIS*/

#Check Table

SELECT *
FROM world_life_expectancy
;

#Life expectancy

SELECT Country, MIN(`Life expectancy`), MAX(`Life expectancy`), 
	ROUND(MAX(`Life expectancy`)-MIN(`Life expectancy`), 1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) != 0
	AND MAX(`Life expectancy`) != 0
ORDER BY Life_Increase_15_Years DESC
;

#Year
SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` != 0 
AND `Life expectancy` != 0
GROUP BY YEAR
ORDER BY YEAR
;

#Check Table
SELECT *
FROM world_life_expectancy
;

		#Correlation Analysis

SELECT Country, ROUND(AVG(`Life expectancy`),2) AS Life_exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_exp > 0
	AND GDP > 0
ORDER BY GDP ASC
;

#Check how many countries have a GDP count higher than 1500
SELECT 
SUM(CASE 
	WHEN GDP >= 1500 THEN 1
    ELSE 0
END) High_GDP_Count
FROM world_life_expectancy
;
SELECT 
SUM(CASE 
	WHEN GDP >= 1500 THEN 1
    ELSE 0
END) High_GDP_Count, 
AVG(CASE 
	WHEN GDP >= 1500 THEN `Life expectancy`
    ELSE NULL
END) High_GDP_Life_Expectancy,
SUM(CASE 
	WHEN GDP <= 1500 THEN 1
    ELSE 0
END) Low_GDP_Count,
AVG(CASE 
	WHEN GDP <= 1500 THEN `Life expectancy`
    ELSE NULL
END) Low_GDP_Life_Expectancy

FROM world_life_expectancy
;


#Checking Life expectancy by Status and Country

SELECT Status, ROUND(AVG(`Life expectancy`),1), COUNT(DISTINCT(Country))
FROM world_life_expectancy
GROUP BY Status
;

#Checking Average Life Expectancy with BMI rating

SELECT Country, ROUND(AVG(`Life expectancy`), 1) AS Avg_LE, ROUND(AVG(BMI), 1) AS Avg_BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Avg_LE > 0 AND Avg_BMI > 0
ORDER BY Avg_BMI ASC
;

SELECT Country, Year, `Life expectancy`, `Adult Mortality`,
	SUM(`Adult Mortality`) OVER(PARTITION BY COUNTRY ORDER BY YEAR) AS Rolling_Total
FROM world_life_expectancy
;
	










