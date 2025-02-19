-- Total Count of Recorded Incidents and Sum of Fatalities
SELECT 
	COUNT(*) AS RECORDED_INCIDENTS, 
	SUM(FATALS) AS FATALITIES 
FROM 
	FARS;

-- Fatalities by Harmful Events and Manner of Collision
SELECT 
    HARM_EV_NAME,
	MAN_COLL_NAME,
    SUM(FATALS) AS FATALITIES,
    CAST(SUM(FATALS) AS DECIMAL(10,2)) / 42514 AS PC_FATALS
FROM
    FARS
GROUP BY
    1,
	2
ORDER BY
    3 DESC;
	
-- Fatality rates by Harmful Event when Manner of Collision is not a collision with a Motor Vehicle
SELECT 
	HARM_EV_NAME,
    COUNT(*) AS INCIDENT_COUNT,
    SUM(PEDS) + SUM(PERSONS) AS PERSONS_INVOLVED,
    SUM(FATALS) AS FATALITIES,
    ROUND(CAST(SUM(FATALS) AS DECIMAL(10,2)) / (SUM(PEDS) + SUM(PERSONS)), 2) AS FATALITY_RATE
FROM 
	FARS
WHERE 
	MAN_COLL_NAME='The First Harmful Event was Not a Collision with a Motor Vehicle in Transport'
GROUP BY 
	1
ORDER BY 
	2 DESC
LIMIT 
	10;

-- When do most Pedestrian Incidents occur
SELECT 
    HOUR_NAME,
	COUNT(*) AS INCIDENT_COUNT
FROM 
	FARS
WHERE 
	HARM_EV_NAME = 'Pedestrian'
GROUP BY 
	1
ORDER BY 
	2 DESC;
	
-- Total Fatalities by State
SELECT 
	STATE_NAME,
	SUM(FATALS) AS FATALITIES 
FROM 
	FARS
GROUP BY 
	1
ORDER BY 
	2 DESC;
	
-- Fatality Rate over involved persons by State 
SELECT 
	STATE_NAME,
	SUM(PEDS) + SUM(PERSONS) AS PERSONS_INVOLVED,
	SUM(FATALS) AS FATALITIES,
	ROUND(CAST(SUM(FATALS) AS DECIMAL(10,2)) / (SUM(PEDS) + SUM(PERSONS)),2) AS FATALITY_RATE
FROM 
	FARS
GROUP BY 
	1
ORDER BY 
	4 DESC;
	
-- Average Fatalities in Montana by Location/Road Type 
SELECT 
	FUNC_SYS_NAME,
	TYPEINT_NAME,
	AVG(FATALS) AS AVERAGE_FATALITIES
FROM 
	FARS
WHERE
	STATE_NAME='Montana'
GROUP BY 
	1,
	2
ORDER BY 
	3 DESC;
	
-- Average Fatalities in Montana by Hour 
SELECT 
	HOUR_NAME,
	AVG(FATALS) AS AVERAGE_FATALITIES
FROM 
	FARS
WHERE
	STATE_NAME='Montana'
GROUP BY 
	1
ORDER BY 
	2 DESC;
	
-- Average Fatalities by Notification and Arrival Times
WITH TIME_DIFF AS (
    SELECT 
        ST_CASE,
		FUNC_SYS_NAME,
        (ARR_HOUR * 60 + ARR_MIN) - (NOT_HOUR * 60 + NOT_MIN) AS time_to_notification_minutes,
        FATALS
    FROM 
		FARS
    WHERE NOT_HOUR NOT IN (99, 88) 
        AND NOT_HOUR IS NOT NULL 
        AND NOT_MIN IS NOT NULL
        AND NOT_HOUR NOT IN (99, 88) 
        AND ARR_HOUR IS NOT NULL 
        AND ARR_MIN IS NOT NULL
),
GROUPED_DATA AS (
    SELECT 
        CASE 
            WHEN TIME_TO_NOTIFICATION_MINUTES <= 15 THEN '0-15 min'
            WHEN TIME_TO_NOTIFICATION_MINUTES <= 30 THEN '16-30 min'
            WHEN TIME_TO_NOTIFICATION_MINUTES <= 60 THEN '31-60 min'
            WHEN TIME_TO_NOTIFICATION_MINUTES <= 90 THEN '61-90 min'
            ELSE '90+ min'
        END AS TIME_RANGE,
        AVG(FATALS) AS AVG_FATALITIES,
        COUNT(*) AS INCIDENT_COUNT
    FROM 
		TIME_DIFF
    GROUP BY 
		1
)
SELECT 
	TIME_RANGE,
	AVG_FATALITIES
FROM 
	GROUPED_DATA
ORDER BY 
    CASE TIME_RANGE
        WHEN '0-15 min' THEN 1
        WHEN '16-30 min' THEN 2
        WHEN '31-60 min' THEN 3
        WHEN '61-90 min' THEN 4
        ELSE 5
    END;