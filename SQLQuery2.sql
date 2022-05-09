-- FIRST AT A QUICK GLANCE WE CAN SEE THAT ID IS A COMMON COLUMN NAME ACROSS TABLES. LET'S CONFIRM THIS.
SELECT 
	TABLE_NAME, COLUMN_NAME
FROM 
	INFORMATION_SCHEMA.COLUMNS
WHERE 
	TABLE_CATALOG = 'Portfolio Project'
	AND COLUMN_NAME LIKE 'Id'

-- BEING THAT THERE IS A LOT OF MISSING INFORMATION, WE WENT WITH USERS WITH THE MOST CONSISTENT INFORMATION AND USED THAT TO ANALYZE TRENDS.

-- COUNTING NUMBER OF USERS IN DIFFERENT WORKBOOKS
CREATE TABLE #DailyActivityWorkbookUsers
(
Users numeric
)
INSERT INTO #DailyActivityWorkbookUsers
SELECT
    COUNT(DISTINCT Id) AS NumberOfUsers_DailyActivityWorkbook
FROM
	dailyActivity_merged$

CREATE TABLE #HeartRateWorkbookUsers
(
Users numeric
)
INSERT INTO #HeartRateWorkbookUsers
SELECT
    COUNT(DISTINCT Id) AS NumberOfUsers_HeartRate
FROM
	heartrate_seconds_merged$

CREATE TABLE #WeightLogWorkbookUsers
(
Users numeric
)
INSERT INTO #WeightLogWorkbookUsers
SELECT
    COUNT(DISTINCT Id) AS NumberOfUsers_WeightLog
FROM
	weightLogInfo_merged$

CREATE TABLE #SleepTrackingWorkbookUsers
(
Users numeric
)
INSERT INTO #SleepTrackingWorkbookUsers
SELECT
    COUNT(DISTINCT Id) AS NumberOfUsers_SleepTracking
FROM
	sleepDay_merged$

-- COUNTING NUMBER OF TIMES USERS APPEAR IN THE DIFFERENT WORKBOOKS
SELECT
    Id,
    COUNT(*) AS TimesUsersAppeared
FROM
    dailyActivity_merged$
GROUP BY
    Id

SELECT
    Id,
    COUNT(*) AS TimesUsersAppeared
FROM
    heartrate_seconds_merged$
GROUP BY
    Id

SELECT
    Id,
    COUNT(*) AS TimesUsersAppeared
FROM
    weightLogInfo_merged$
GROUP BY
    Id

SELECT
    Id,
    COUNT(*) AS TimesUsersAppeared
FROM
    sleepDay_merged$
GROUP BY
    Id

-- VERIFYING THE TWO SPREADHSEETS USED FOR CALORIC ANALYSIS WERE MERGED WITH CORRECT INFORMATION IN THE CELLS OF EACH SELECTED USER.
SELECT dailySteps_merged$.Id, StepTotal, TotalSteps
FROM dailySteps_merged$
RIGHT JOIN dailyActivity_merged$
ON dailySteps_merged$.StepTotal = dailyActivity_merged$.TotalSteps
WHERE dailySteps_merged$.Id = 2022484408 OR dailySteps_merged$.Id = 1624580081 OR dailySteps_merged$.Id = 1503960366
GROUP BY dailySteps_merged$.Id, StepTotal, TotalSteps

-- VERIFYING THE NUMBER OF DAYS RECORDS GO UP TO FOR EACH SELECTED USER
SELECT
     dailyActivity_merged$.Id, 
     COUNT(dailyActivity_merged$.Id) AS counted_days
FROM
     dailyActivity_merged$
WHERE 
	dailyActivity_merged$.Id = 1624580081 OR dailyActivity_merged$.Id = 1503960366 OR dailyActivity_merged$.Id = 2022484408
GROUP BY
     dailyActivity_merged$.Id

-- COMPARING STEPS AND DISTANCE OF USERS VS CALORIES BURNED (31 DAYS)
CREATE TABLE #DistanceVsCaloriesMonthly
(
Id numeric,
Steps numeric,
DistanceInKm numeric,
Calories numeric
)


INSERT INTO #DistanceVsCaloriesMonthly
SELECT DISTINCT
	Id, 
	SUM(TotalSteps) AS StepsMonthly, 
	SUM(ROUND(TotalDistance, 2)) AS 'DistanceMonthly(Km)',
	SUM(Calories) AS 'CaloriesBurnedMonthly(KCal'
FROM 
	dailyActivity_merged$
WHERE 
	Id = 8877689391
 OR Id = 1624580081 OR Id = 1644430081
GROUP BY 
	Id

-- COMPARING VERY, FAIRLY AND LIGHTLY ACTIVITIES TO CALORIES BURNED. CREATE TABLE
CREATE TABLE #ActivityVsCaloriesMonthly
(
Id numeric,
VeryActiveMins numeric,
FairlyActiveMins numeric,
LightActivity numeric,
TotalActiveMins numeric,
CaloriesBurned numeric
)
Insert into #ActivityVsCaloriesMonthly
SELECT DISTINCT
	Id,
	SUM(VeryActiveMinutes) AS VeryActiveMinsMonthly,
	SUM(FairlyActiveMinutes) AS FairActiveMinsMonthly,
	SUM(LightlyActiveMinutes) AS LightActivityMinsMonthly,
	SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS TotalActiveMinsMonthly,
	SUM(Calories) AS 'CaloriesBurnedMonthly(KCal)'
FROM 
	dailyActivity_merged$
WHERE 
	Id = 1624580081 OR Id = 8877689391
 OR Id = 1644430081
GROUP BY
	Id

SELECT
	heartrate_seconds_merged$.Id, 
	heartrate_seconds_merged$.Value AS HeartRate,
	[Date] = CONVERT(DATE, heartrate_seconds_merged$.Time),
    [Time] = FORMAT(CAST(heartrate_seconds_merged$.Time AS DATETIME), 'hh:mm tt')
FROM heartrate_seconds_merged$
WHERE heartrate_seconds_merged$.Value >= 120
GROUP BY heartrate_seconds_merged$.Id, heartrate_seconds_merged$.Time, heartrate_seconds_merged$.Value
ORDER BY heartrate_seconds_merged$.Value DESC

SELECT
	DISTINCT
	heartrate_seconds_merged$.Id, 
	heartrate_seconds_merged$.Time, 
	heartrate_seconds_merged$.Value as heart_rate
FROM 
	heartrate_seconds_merged$
WHERE Id = 4558609924 AND heartrate_seconds_merged$.Value >= 120
GROUP BY 
	heartrate_seconds_merged$.Time,
	heartrate_seconds_merged$.Value,
	heartrate_seconds_merged$.Id
ORDER BY 
	1, 2

SELECT *
FROM weightLogInfo_merged$


----------------------TABLE SECTION------------------------------------------------------------------------------------------------------

-- 1) FOR ACTIVITY VS CALORIES
SELECT *
FROM #ActivityVsCaloriesMonthly

-- 2) FOR DISTANCE VS CALORIES
SELECT *
FROM #DistanceVsCaloriesMonthly

-- 3) FOR USERS IN DAILY ACTIVITY WORKBOOK (Highest users)
SELECT *
FROM #DailyActivityWorkbookUsers

-- 4) FOR USERS IN HEARTRATE WORKBOOK (Fourth Highest)
SELECT *
FROM #HeartRateWorkbookUsers

-- 5) FOR USERS IN WEIGHT LOG WORKBOOK (Third highest)
SELECT *
FROM #WeightLogWorkbookUsers

-- 6) FOR USERS IN SLEEP TRACKING (Second highest)
SELECT *
FROM #SleepTrackingWorkbookUsers
--------------------------------------------------------------------------------------------------------------------------------------------
-----------------CREATING VIEWS FOR VISUALIZATION-------------------------------------------------------------------------------------------

-- 1) VIEW FOR ACTIVITY VS CALORIES
CREATE VIEW ActivityVsCaloriesMonthly AS
SELECT DISTINCT
	Id,
	SUM(VeryActiveMinutes) AS VeryActiveMinsMonthly,
	SUM(FairlyActiveMinutes) AS FairActiveMinsMonthly,
	SUM(LightlyActiveMinutes) AS LightActivityMinsMonthly,
	SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS TotalActiveMinsMonthly,
	SUM(Calories) AS 'CaloriesBurnedMonthly(KCal)'
FROM 
	dailyActivity_merged$
WHERE 
	Id = 1624580081 OR Id = 8877689391
 OR Id = 1644430081
GROUP BY
	Id

-- 2) VIEW FOR DISTANCE VS CALORIES
CREATE VIEW DistanceVsCaloriesMonthly AS
SELECT DISTINCT
	Id, 
	SUM(TotalSteps) AS StepsMonthly, 
	SUM(ROUND(TotalDistance, 2)) AS 'DistanceMonthly(Km)',
	SUM(Calories) AS 'CaloriesBurnedMonthly(KCal'
FROM 
	dailyActivity_merged$
WHERE 
	Id = 8877689391
 OR Id = 1624580081 OR Id = 1644430081
GROUP BY 
	Id

-- 3) VIEW FOR USERS IN DAILY ACTIVITY WORKBOOK (HIGHEST COUNT)
CREATE VIEW DailyActivityWorkbookUsers AS
SELECT
    COUNT(DISTINCT Id) AS NumberOfUsers_DailyActivityWorkbook
FROM
	dailyActivity_merged$

-- 4) VIEW FOR USERS IN SLEEP TRACKING WORKBOOK (SECOND HIGHEST COUNT)
CREATE VIEW SleepTrackingWorkbookUsers AS
SELECT
    COUNT(DISTINCT Id) AS NumberOfUsers_SleepTracking
FROM
	sleepDay_merged$

-- 5) VIEW FOR USERS IN WEIGHTLOG WORKBOOK (THIRD HIGHEST COUNT)
CREATE VIEW WeightLogWorkbookUsers AS
SELECT
    COUNT(DISTINCT Id) AS NumberOfUsers_WeightLog
FROM
	weightLogInfo_merged$

-- 6) VIEW FOR USERS IN HEARTRATE WORKBOOK (FOURTH HIGHEST COUNT)
CREATE VIEW HeartRateWorkbookUsers AS
SELECT
    COUNT(DISTINCT Id) AS NumberOfUsers_HeartRate
FROM
	heartrate_seconds_merged$

-----------------------------------------------------------------------------------------------------------------------------------------------------
---------------COMBINING USER VIEWS TOGETHER--------------------------------------------------------------------------------------------------------------

CREATE VIEW Count_AllUsers AS
SELECT NumberOfUsers_DailyActivityWorkbook AS AllUsers
FROM DailyActivityWorkbookUsers
UNION
SELECT *
FROM SleepTrackingWorkbookUsers
UNION
SELECT *
FROM WeightLogWorkbookUsers
UNION
SELECT *
FROM HeartRateWorkbookUsers