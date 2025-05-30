/* Task 1:

список клиентов с непрерывной историей за год, то есть каждый месяц на регулярной основе без пропусков за указанный годовой период, средний чек за период с 01.06.2015 по 01.06.2016, средняя сумма покупок за месяц, количество всех операций по клиенту за период; */

SELECT id_client, 
COUNT(DISTINCT DATE_TRUNC('month', date_new)) AS active_months,
COUNT(id_check) AS total_operations,
SUM(sum_payment) AS total_spent,
ROUND(SUM(sum_payment)/COUNT(id_check),2) AS avg_check,
ROUND(SUM(sum_payment)/12, 2) AS avg_monthly_spent
FROM transactions_info
WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
GROUP BY id_client
HAVING COUNT(DISTINCT DATE_TRUNC('month', date_new)) = 12;

/*Task 2: 

средняя сумма чека в месяц;
среднее количество операций в месяц;
среднее количество клиентов, которые совершали операции; */

SELECT DATE_TRUNC('month', date_new) AS month,
ROUND(SUM(sum_payment) / COUNT(id_check), 2) AS avg_check,
COUNT(id_check) AS operations_count,
COUNT(DISTINCT id_client) AS active_clients
FROM transactions_info
GROUP BY DATE_TRUNC('month', date_new)
ORDER BY month;

/* долю от общего количества операций за год и долю в месяц от общей суммы операций; */

WITH totals AS (
SELECT COUNT(id_check) AS total_operations, 
SUM(sum_payment) AS total_sum
FROM transactions_info)
	
SELECT DATE_TRUNC('month', date_new) AS month,
COUNT(id_check) AS operations_count,
SUM(sum_payment) AS sum_payment,
ROUND(COUNT(id_check) * 100.0 / totals.total_operations, 2) AS operations_percentage,
ROUND(SUM(sum_payment) * 100.0 / totals.total_sum, 2) AS sum_percentage
FROM transactions_info, totals
GROUP BY DATE_TRUNC('month', date_new), totals.total_operations, totals.total_sum
ORDER BY month;

/* вывести % соотношение M/F/NA в каждом месяце с их долей затрат; */

SELECT DATE_TRUNC('month', t.date_new) AS month, c.gender,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY DATE_TRUNC('month', t.date_new)), 2) AS percent_operations,
ROUND(SUM(t.sum_payment) * 100.0 / SUM(SUM(t.sum_payment)) OVER (PARTITION BY DATE_TRUNC('month', t.date_new)), 2) AS percent_sum
FROM transactions_info t
JOIN customer_info c ON t.id_client = c.id_client
GROUP BY DATE_TRUNC('month', t.date_new), c.gender
ORDER BY month, c.gender;

/* Task 3: */

WITH age_groups AS (
SELECT t.id_check, t.sum_payment, t.id_client, 
DATE_TRUNC('quarter', t.date_new) AS quarter,
CASE 
WHEN c.age IS NULL THEN 'Unknown'
WHEN c.age < 20 THEN '0-19'
WHEN c.age < 30 THEN '20-29'
WHEN c.age < 40 THEN '30-39'
WHEN c.age < 50 THEN '40-49'
WHEN c.age < 60 THEN '50-59'
WHEN c.age < 70 THEN '60-69'
WHEN c.age < 80 THEN '70-79'
ELSE '80+'
END AS age_group
FROM transactions_info t
JOIN customer_info c ON t.id_client = c.id_client )

SELECT quarter, age_group,
COUNT(id_check) AS operations_count,
COUNT(DISTINCT id_client) AS unique_clients,
SUM(sum_payment) AS total_spent,
ROUND(SUM(sum_payment) * 1.0 / COUNT(id_check), 2) AS avg_payment_per_operation,
ROUND(COUNT(id_check) * 1.0 / COUNT(DISTINCT id_client), 2) AS avg_operations_per_client,
ROUND(COUNT(id_check) * 100.0 / SUM(COUNT(id_check)) OVER (PARTITION BY quarter), 2) AS share_operations_percent,
ROUND(SUM(sum_payment) * 100.0 / SUM(SUM(sum_payment)) OVER (PARTITION BY quarter), 2) AS share_spent_percent
FROM age_groups
GROUP BY quarter, age_group
ORDER BY quarter, age_group;