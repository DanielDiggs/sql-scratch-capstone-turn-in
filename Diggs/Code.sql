--Segment checks and month analysis
SELECT COUNT(DISTINCT id) AS users,
segment
FROM subscriptions
GROUP BY segment;
SELECT min(subscription_end) AS earliest_end, min(subscription_start) AS earliest_start,
max(subscription_end) AS latest_end,
max(subscription_start) AS latest_start
FROM subscriptions;

--Final Analysis
WITH months AS 
(
SELECT 
	'2017-01-01' AS first_day,
  '2017-01-31' AS last_day
UNION
  SELECT
	'2017-02-01' AS first_day,
  '2017-02-28' AS last_day
UNION
  SELECT
	'2017-03-01' AS first_day,
  '2017-03-31' AS last_day
),
cross_join AS (
  SELECT *
FROM subscriptions
cross JOIN months
),
status AS (
SELECT id,
  segment,
  first_day as month,
  CASE
      WHEN (subscription_start < first_day) 
      AND
      (subscription_end > first_day OR subscription_end IS NULL)
      THEN 1
      ELSE 0
      END AS is_active,
  CASE
      WHEN (subscription_end BETWEEN first_day AND last_day)
      THEN 1
      ELSE 0
      END AS is_canceled
  FROM 
  cross_join
)
SELECT segment,
month,
ROUND(100.0*SUM(is_canceled)/SUM(is_active),4) AS churn_rate,
SUM(is_active) AS active_users
FROM status
GROUP BY segment, month