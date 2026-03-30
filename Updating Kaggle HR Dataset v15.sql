select * 
from Kaggle_HRDataset_v14
limit 10;

-- how many rows do we have in the data file?? 
SELECT COUNT(*) 
FROM Kaggle_HRDataset_v14;

-- how many workers, hire dates (checking if any missing) & leavers
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DateofHire) AS has_hire_date,
    COUNT(DateofTermination) AS has_term_date
FROM Kaggle_HRDataset_v14;


SELECT 
    EmpID,
    DateofHire,
    DateofTermination,
    EmploymentStatus,
    Sex,
    Department
FROM Kaggle_HRDataset_v14
LIMIT 20;


-- are my dates set as text? 
SELECT 
    DateofHire,
    DateofTermination,
    typeof(DateofHire)
FROM Kaggle_HRDataset_v14
LIMIT 5;
-- yes


-- creating a clean TABLE
DROP TABLE IF EXISTS Kaggle_HRDataset_v14_clean;

CREATE TABLE Kaggle_HRDataset_v14_clean AS
SELECT
    EmpID,
    Employee_Name,
    EmpStatusID,
    DeptID,
    PerfScoreID,
    Salary,
    Termd,
    PositionID,
    Position,
    State,
    DOB,
    Sex,
    CitizenDesc,
    RaceDesc,
    ManagerName,
    ManagerID,
    RecruitmentSource,
    PerformanceScore,
    EngagementSurvey,
    EmpSatisfaction,
    LastPerformanceReview_Date,
    Absences,
    Department,
    EmploymentStatus,
    TermReason,
	-- date fields as text
    DateofHire AS DateofHire_raw,
    DateofTermination AS DateofTermination_raw,
    -- converted into date fields
	-- subtracting from the text-date fields, [month - start at position 1, take 2 characters// day - start at position 4, take 2 characters// year - start at position 7, take 4 characters]
	-- will be YYYY-MM-DD
    DATE(SUBSTR(DateofHire,7,4) || '-' || SUBSTR(DateofHire,1,2) || '-' || SUBSTR(DateofHire,4,2)) AS hire_date,
    
    CASE 
        WHEN DateofTermination IS NULL OR DateofTermination = '' THEN NULL
        ELSE DATE(SUBSTR(DateofTermination,7,4) || '-' || SUBSTR(DateofTermination,1,2) || '-' || SUBSTR(DateofTermination,4,2))
    END AS term_date,

    -- month-year fields - formatting date as a string
	-- %b → abbreviated month name (Jan, Feb, Mar...) // could also do %m = month as number 
	-- %Y → 4 digit year (2011, 2012...) 
	-- %d = day, %y = 2 digit year.
    STRFTIME('%b-%Y', DATE(SUBSTR(DateofHire,7,4) || '-' || SUBSTR(DateofHire,1,2) || '-' || SUBSTR(DateofHire,4,2))) AS join_month,
    
    CASE 
        WHEN DateofTermination IS NULL OR DateofTermination = '' THEN NULL
        ELSE STRFTIME('%b-%Y', DATE(SUBSTR(DateofTermination,7,4) || '-' || SUBSTR(DateofTermination,1,2) || '-' || SUBSTR(DateofTermination,4,2)))
    END AS leave_month

FROM Kaggle_HRDataset_v14;
-- above errored because it doesn't pick up the dates where it had one digit rather than 2. 


-- check if all worked?
SELECT 
    EmpID,
    Employee_Name,
    DateofHire_raw,
    hire_date,
    DateofTermination_raw,
    term_date,
    join_month,
    leave_month,
    EmploymentStatus
FROM Kaggle_HRDataset_v14_clean
LIMIT 20;

SELECT 
    COUNT(*) AS total,
    COUNT(hire_date) AS has_hire_date,
    COUNT(term_date) AS has_term_date,
    COUNT(join_month) AS has_join_month
FROM Kaggle_HRDataset_v14_clean;

SELECT 
    COUNT(*) AS total,
    COUNT(hire_date) AS has_hire_date,
    COUNT(term_date) AS has_term_date,
    COUNT(join_month) AS has_join_month
FROM Kaggle_HRDataset_v14_clean;



SELECT DateofHire_raw, hire_date
FROM Kaggle_HRDataset_v14_clean
WHERE hire_date IS NULL;

SELECT 
    hire_date,
    STRFTIME('%b-%Y', hire_date) AS join_month_test
FROM Kaggle_HRDataset_v14_clean
LIMIT 5;


-- creating a clean TABLE
DROP TABLE IF EXISTS Kaggle_HRDataset_v14_clean;
CREATE TABLE Kaggle_HRDataset_v14_clean AS
SELECT
    EmpID,
    Employee_Name,
    EmpStatusID,
    DeptID,
    PerfScoreID,
    Salary,
    Termd,
    PositionID,
    Position,
    State,
    DOB,
    Sex,
    CitizenDesc,
    RaceDesc,
    ManagerName,
    ManagerID,
    RecruitmentSource,
    PerformanceScore,
    EngagementSurvey,
    EmpSatisfaction,
    LastPerformanceReview_Date,
    Absences,
    Department,
    EmploymentStatus,
    TermReason,

    -- date fields as text
    DateofHire AS DateofHire_raw,
    DateofTermination AS DateofTermination_raw,

    -- converted into date fields
    -- using INSTR to find '/' positions, handles both M/D/YYYY and MM/DD/YYYY
    -- SUBSTR(date, -4) grabs last 4 characters for year (always 4 digits at end)
    -- will be YYYY-MM-DD
    DATE(
        SUBSTR(DateofHire, -4) || '-' ||
        PRINTF('%02d', CAST(SUBSTR(DateofHire, 1, INSTR(DateofHire, '/') - 1) AS INT)) || '-' ||
        PRINTF('%02d', CAST(SUBSTR(DateofHire, INSTR(DateofHire, '/') + 1, INSTR(SUBSTR(DateofHire, INSTR(DateofHire, '/') + 1), '/') - 1) AS INT))
    ) AS hire_date,

    CASE
        WHEN DateofTermination IS NULL OR DateofTermination = '' THEN NULL
        ELSE DATE(
            SUBSTR(DateofTermination, -4) || '-' ||
            PRINTF('%02d', CAST(SUBSTR(DateofTermination, 1, INSTR(DateofTermination, '/') - 1) AS INT)) || '-' ||
            PRINTF('%02d', CAST(SUBSTR(DateofTermination, INSTR(DateofTermination, '/') + 1, INSTR(SUBSTR(DateofTermination, INSTR(DateofTermination, '/') + 1), '/') - 1) AS INT))
        )
    END AS term_date,

    -- month-year fields - built manually from hire_date/term_date
    -- STRFTIME unreliable in SQLite so using CASE on month number instead
    -- %b → abbreviated month name (Jan, Feb, Mar...) // could also do %m = month as number
    -- %Y → 4 digit year (2011, 2012...)
    -- %d = day, %y = 2 digit year
    CASE SUBSTR(DATE(
        SUBSTR(DateofHire, -4) || '-' ||
        PRINTF('%02d', CAST(SUBSTR(DateofHire, 1, INSTR(DateofHire, '/') - 1) AS INT)) || '-' ||
        PRINTF('%02d', CAST(SUBSTR(DateofHire, INSTR(DateofHire, '/') + 1, INSTR(SUBSTR(DateofHire, INSTR(DateofHire, '/') + 1), '/') - 1) AS INT))
    ), 6, 2)
        WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb' WHEN '03' THEN 'Mar'
        WHEN '04' THEN 'Apr' WHEN '05' THEN 'May' WHEN '06' THEN 'Jun'
        WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug' WHEN '09' THEN 'Sep'
        WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec'
    END || '-' || SUBSTR(DateofHire, -4) AS join_month,

    CASE
        WHEN DateofTermination IS NULL OR DateofTermination = '' THEN NULL
        ELSE CASE SUBSTR(DATE(
            SUBSTR(DateofTermination, -4) || '-' ||
            PRINTF('%02d', CAST(SUBSTR(DateofTermination, 1, INSTR(DateofTermination, '/') - 1) AS INT)) || '-' ||
            PRINTF('%02d', CAST(SUBSTR(DateofTermination, INSTR(DateofTermination, '/') + 1, INSTR(SUBSTR(DateofTermination, INSTR(DateofTermination, '/') + 1), '/') - 1) AS INT))
        ), 6, 2)
            WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb' WHEN '03' THEN 'Mar'
            WHEN '04' THEN 'Apr' WHEN '05' THEN 'May' WHEN '06' THEN 'Jun'
            WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug' WHEN '09' THEN 'Sep'
            WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec'
        END || '-' || SUBSTR(DateofTermination, -4)
    END AS leave_month

FROM Kaggle_HRDataset_v14;



-- V1: row and date counts
SELECT 
    COUNT(*) AS total,
    COUNT(hire_date) AS has_hire_date,
    COUNT(term_date) AS has_term_date,
    COUNT(join_month) AS has_join_month,
    COUNT(leave_month) AS has_leave_month
FROM Kaggle_HRDataset_v14_clean;

-- V2: spot check dates and months
SELECT 
    EmpID,
    Employee_Name,
    DateofHire_raw,
    hire_date,
    DateofTermination_raw,
    term_date,
    join_month,
    leave_month,
    EmploymentStatus
FROM Kaggle_HRDataset_v14_clean
LIMIT 20;

-- when did we hire the first person? 
select hire_date 
from Kaggle_HRDataset_v14_clean
order by hire_date asc;


-- V3: check actual date range in dataset
SELECT 
    MIN(hire_date) AS earliest_hire,
    MAX(hire_date) AS latest_hire,
    MAX(term_date) AS latest_termination
FROM Kaggle_HRDataset_v14_clean;




-- as the data is 'full workforce who has ever worked', we need a monthly snapshot to be able to produce monthly view

-- creating monthly snapshot table
-- one row per employee per month they were active
-- spine covers Nov-2017 to Nov-2018 (13 months)
DROP TABLE IF EXISTS hr_monthly_snapshot;
CREATE TABLE hr_monthly_snapshot AS

-- first we generate all 13 months as a calendar
WITH calendar AS (
    SELECT '2017-11-01' AS month_start UNION ALL
    SELECT '2017-12-01' UNION ALL
    SELECT '2018-01-01' UNION ALL
    SELECT '2018-02-01' UNION ALL
    SELECT '2018-03-01' UNION ALL
    SELECT '2018-04-01' UNION ALL
    SELECT '2018-05-01' UNION ALL
    SELECT '2018-06-01' UNION ALL
    SELECT '2018-07-01' UNION ALL
    SELECT '2018-08-01' UNION ALL
    SELECT '2018-09-01' UNION ALL
    SELECT '2018-10-01' UNION ALL
    SELECT '2018-11-01'
),

-- label each month in Mon-YYYY format
calendar_named AS (
    SELECT 
        month_start,
        CASE SUBSTR(month_start, 6, 2)
            WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb' WHEN '03' THEN 'Mar'
            WHEN '04' THEN 'Apr' WHEN '05' THEN 'May' WHEN '06' THEN 'Jun'
            WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug' WHEN '09' THEN 'Sep'
            WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec'
        END || '-' || SUBSTR(month_start, 1, 4) AS snapshot_month
    FROM calendar
)

-- cross join every employee with every month, then filter to only months they were active
SELECT
    e.EmpID,
    e.Employee_Name,
    e.Sex,
    e.Department,
    e.Position,
    e.EmploymentStatus,
    e.hire_date,
    e.term_date,
    e.join_month,
    e.leave_month,
    e.RecruitmentSource,
    e.PerformanceScore,
    e.EngagementSurvey,
    e.EmpSatisfaction,
    e.Absences,
    e.ManagerName,
    e.RaceDesc,
    c.month_start AS snapshot_month_start,
    c.snapshot_month,

    -- is this employee active in this month?
    -- hired before end of month AND (no term date OR term date is after start of month)
	--
	-- DATE(c.month_start, '+1 month', '-1 day') - SQLite date arithmetic. 
	-- Starting from the 1st of the month, go forward 1 month then back 1 day = last day of that month. 
	-- So 2018-01-01 +1 month -1 day = 2018-01-31. This means "hired any time before or on the last day of this month".
	--
    CASE 
        WHEN e.hire_date <= DATE(c.month_start, '+1 month', '-1 day')
        AND (e.term_date IS NULL OR e.term_date >= c.month_start)
        THEN 1 ELSE 0 
    END AS is_active,

    -- did they join in this month?
    CASE 
        WHEN e.hire_date >= c.month_start 
        AND e.hire_date <= DATE(c.month_start, '+1 month', '-1 day')
        THEN 1 ELSE 0 
    END AS is_new_joiner,

    -- did they leave in this month?
    CASE 
        WHEN e.term_date >= c.month_start 
        AND e.term_date <= DATE(c.month_start, '+1 month', '-1 day')
        THEN 1 ELSE 0 
    END AS is_leaver

FROM Kaggle_HRDataset_v14_clean e
CROSS JOIN calendar_named c
-- only keep rows where employee was active that month
WHERE e.hire_date <= DATE(c.month_start, '+1 month', '-1 day')
AND (e.term_date IS NULL OR e.term_date >= c.month_start);




-- V4: snapshot row counts per month
SELECT 
    snapshot_month,
    month_start,
    SUM(is_active) AS headcount,
    SUM(is_new_joiner) AS new_joiners,
    SUM(is_leaver) AS leavers
FROM hr_monthly_snapshot
GROUP BY snapshot_month, snapshot_month_start
ORDER BY month_start;

-- V5: check November active employees
SELECT EmpID, Employee_Name, hire_date, term_date
FROM hr_monthly_snapshot
WHERE snapshot_month = 'Nov-2018'
AND is_active = 1
ORDER BY term_date;


-- V6: spot check active employee across all months - all fields
SELECT *
FROM hr_monthly_snapshot
WHERE EmpID = 10026
ORDER BY snapshot_month_start;

-- V7: check snapshot month ordering issue
SELECT DISTINCT snapshot_month, snapshot_month_start
FROM hr_monthly_snapshot
ORDER BY snapshot_month_start;

-- realised the dataset is missing the check for the end of month headcount that's required for attrition calculation 
--
--
--
--
-- creating monthly snapshot table
-- one row per employee per month they were active
-- spine covers Nov-2017 to Nov-2018 (13 months)
DROP TABLE IF EXISTS hr_monthly_snapshot;
CREATE TABLE hr_monthly_snapshot AS

-- first we generate all 13 months as a calendar
WITH calendar AS (
    SELECT '2017-11-01' AS month_start, '2017-12-01' AS next_month_start UNION ALL
    SELECT '2017-12-01', '2018-01-01' UNION ALL
    SELECT '2018-01-01', '2018-02-01' UNION ALL
    SELECT '2018-02-01', '2018-03-01' UNION ALL
    SELECT '2018-03-01', '2018-04-01' UNION ALL
    SELECT '2018-04-01', '2018-05-01' UNION ALL
    SELECT '2018-05-01', '2018-06-01' UNION ALL
    SELECT '2018-06-01', '2018-07-01' UNION ALL
    SELECT '2018-07-01', '2018-08-01' UNION ALL
    SELECT '2018-08-01', '2018-09-01' UNION ALL
    SELECT '2018-09-01', '2018-10-01' UNION ALL
    SELECT '2018-10-01', '2018-11-01' UNION ALL
    SELECT '2018-11-01', '2018-12-01'
),

-- label each month in Mon-YYYY format
calendar_named AS (
    SELECT 
        month_start,
        next_month_start,
        CASE SUBSTR(month_start, 6, 2)
            WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb' WHEN '03' THEN 'Mar'
            WHEN '04' THEN 'Apr' WHEN '05' THEN 'May' WHEN '06' THEN 'Jun'
            WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug' WHEN '09' THEN 'Sep'
            WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec'
        END || '-' || SUBSTR(month_start, 1, 4) AS snapshot_month
    FROM calendar
)

-- cross join every employee with every month, then filter to only months they were active
SELECT
    e.EmpID,
    e.Employee_Name,
    e.Sex,
    e.Department,
    e.Position,
    e.EmploymentStatus,
    e.hire_date,
    e.term_date,
    e.join_month,
    e.leave_month,
    e.RecruitmentSource,
    e.PerformanceScore,
    e.EngagementSurvey,
    e.EmpSatisfaction,
    e.Absences,
    e.ManagerName,
    e.RaceDesc,
    c.month_start,
    c.snapshot_month,

    -- is this employee active at any point in this month?
    -- hired before end of month AND (no term date OR term date is after start of month)
    CASE 
        WHEN e.hire_date <= DATE(c.month_start, '+1 month', '-1 day')
        AND (e.term_date IS NULL OR e.term_date >= c.month_start)
        THEN 1 ELSE 0 
    END AS is_active,

    -- is this employee active at end of month?
    -- checks if still employed on 1st day of next month
    CASE 
        WHEN e.hire_date < c.next_month_start
        AND (e.term_date IS NULL OR e.term_date >= c.next_month_start)
        THEN 1 ELSE 0 
    END AS is_active_end_month,

    -- did they join in this month?
    CASE 
        WHEN e.hire_date >= c.month_start 
        AND e.hire_date <= DATE(c.month_start, '+1 month', '-1 day')
        THEN 1 ELSE 0 
    END AS is_new_joiner,

    -- did they leave in this month?
    CASE 
        WHEN e.term_date >= c.month_start 
        AND e.term_date <= DATE(c.month_start, '+1 month', '-1 day')
        THEN 1 ELSE 0 
    END AS is_leaver

FROM Kaggle_HRDataset_v14_clean e
CROSS JOIN calendar_named c

-- only keep rows where employee was active that month
WHERE e.hire_date <= DATE(c.month_start, '+1 month', '-1 day')
AND (e.term_date IS NULL OR e.term_date >= c.month_start);




-- V8: snapshot row counts per month
SELECT 
    snapshot_month,
    month_start,\
    SUM(is_active) AS headcount,
    SUM(is_active_end_month) AS headcount_end_month,
    SUM(is_new_joiner) AS new_joiners,
    SUM(is_leaver) AS leavers
FROM hr_monthly_snapshot
GROUP BY snapshot_month, month_start
ORDER BY month_start;

select * 
from hr_monthly_snapshot; 

SELECT snapshot_month, month_start, COUNT(*)
FROM hr_monthly_snapshot
WHERE month_start IS NULL
GROUP BY snapshot_month, month_start;