-- Задание 1.a. Решение --

SELECT E.name AS employee_name, D.name AS department_name
FROM Employees AS E
LEFT JOIN Departments AS D ON E.Dep_id = D.id;

-- Задание 1.b. Решение --

SELECT D.name AS department_name, MAX(E.Salary) AS max_salary
FROM Departments AS D
LEFT JOIN Employees AS E ON D.id = E.Dep_id
GROUP BY D.name
ORDER BY max_salary DESC;

-- Задание 2.a. Решение --

SELECT SUM(price * items) AS female_revenue 
FROM Purchases
WHERE user_gender = 'f' OR user_gender = 'female';

-- Задание 2.b. Решение --
  
SELECT 
    CASE WHEN user_gender IN ('f', 'female') THEN 'Female'
         WHEN user_gender IN ('m', 'male') THEN 'Male'
         ELSE 'Unspecified'
    END AS gender,
    SUM(price * items) AS total_income
FROM Purchases
WHERE user_gender IN ('f', 'female', 'm', 'male')
GROUP BY gender;

-- Задание 2.c. Решение --

SELECT COUNT(DISTINCT user_id) AS count_male_users
FROM Purchases
WHERE (user_gender = 'm' OR user_gender = 'male')
GROUP BY user_id
HAVING SUM(items) > 3;

-- Задание 3.a. Решение --

SELECT user_id, first_item
FROM (
  SELECT 
    user_id,
    FIRST_VALUE(item) OVER (PARTITION BY user_id ORDER BY transaction_ts) AS first_item
  FROM Transactions  
) t
GROUP BY user_id, first_item;

-- Задание 3.b. Решение --

WITH first_transactions AS (
  SELECT user_id, MIN(transaction_ts) AS first_ts
  FROM Transactions
  GROUP BY user_id
)

SELECT 
  t.user_id,
  AVG(t.transaction_count) AS average_transactions
FROM 
(
  SELECT 
    user_id, 
    COUNT(*) AS transaction_count
  FROM Transactions t
  JOIN first_transactions f
    ON t.user_id = f.user_id
  WHERE t.transaction_ts BETWEEN f.first_ts AND DATE_ADD(f.first_ts, INTERVAL 72 HOUR)
  GROUP BY user_id
) t
GROUP BY t.user_id;

-- Задание 4.a. Решение --

SELECT
  date,
  COUNT(DISTINCT user_id) AS unique_users,
  COUNT(DISTINCT video_id) AS unique_videos,
  COUNT(*) AS total_views
FROM Video.csv
GROUP BY date
ORDER BY date;

-- Задание 4.b. Решение --

SELECT user_id
FROM Video.csv
WHERE date BETWEEN '2020-01-01' AND '2020-01-31'
GROUP BY user_id;

-- Задание 4.c. Решение --
-- Эту задачу можно решить двумя способами
-- Решение 1 с помощью подзапроса и HAVING clause
SELECT user_id
FROM Video.csv
WHERE video_id IN (1,3)
AND user_id NOT IN (
SELECT user_id
FROM Video.csv
WHERE video_id = 2
)
GROUP BY user_id
HAVING COUNT(DISTINCT video_id) = 2;

-- Решение 2 с помощью двух CTEs
WITH
video_views_1_3 AS (
SELECT user_id, video_id
FROM Video.csv
WHERE video_id IN (1,3)
),
video_view_2 AS (
SELECT user_id, video_id
FROM Video.csv
WHERE video_id = 2
)
SELECT user_id
FROM video_views_1_3
WHERE user_id NOT IN (
SELECT user_id
FROM video_view_2
)
GROUP BY user_id
HAVING COUNT(DISTINCT video_id) = 2;
