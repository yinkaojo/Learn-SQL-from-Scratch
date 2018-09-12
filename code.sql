/* View the data provided, limiting results to first 100 entries*/
SELECT *
FROM subscriptions
LIMIT 100;

/*Determine range of months of data provided*/
SELECT MIN(subscription_start) AS first_month,
    MAX(subscription_start) AS last_month
FROM subscriptions;
 
/*Calculate churn rate for each segment, create temporary table called months*/
WITH months AS
(SELECT
  '2017-01-01' AS first_day,
  '2017-01-31' AS last_day
UNION
SELECT
  '2017-02-01' AS first_day,
  '2017-02-28' AS last_day
UNION
SELECT
  '2017-03-01' AS first_day,
  '2017-03-31' AS last_day),

/*cross join the subscription and months tables*/
cross_join AS
(SELECT *
FROM subscriptions 
CROSS JOIN months),

/*create a status table to determine which subscribers are active or canceled per segment*/
status AS
(SELECT id, 
 	first_day AS month,
CASE
  WHEN segment = 87 AND
  (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END AS is_active_87,
CASE
  WHEN segment = 87 AND
  subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
END AS is_canceled_87,
CASE
  WHEN segment = 30 AND
  (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END AS is_active_30,
CASE
  WHEN segment = 30 AND
  subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
END AS is_canceled_30
FROM cross_join),

/*Calculate the total number of active and canceled subscribers, grouping by month*/
status_aggregate AS
(SELECT month,
  SUM(is_active_87) AS active_87,
  SUM(is_canceled_87) AS canceled_87,
  SUM(is_active_30) AS active_30,
  SUM(is_canceled_30) AS canceled_30
FROM status
GROUP BY month)

/*Calculate churn rate*/
SELECT month,
  1.0 * canceled_87/active_87 AS churn_rate_87,
  1.0 * canceled_30/active_30 AS churn_rate_30
FROM status_aggregate;

