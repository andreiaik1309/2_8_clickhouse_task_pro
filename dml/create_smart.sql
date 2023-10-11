-- Вычислите общую сумму продаж по каждой категории товаров за последний месяц
select category_id, sum(revenue) as revenue_last_month from sales 
where order_date >= now() - INTERVAL 1 MONTH
group by category_id;

-- Определите средний чек покупателей за последний год
select round(avg(revenue), 2) as avg_cheque_last_year from sales 
where order_date >= now() - INTERVAL 1 YEAR;

-- Сначала вычислите средние продажи для каждой категории товаров в течение квартала с
-- использованием -State комбинатора и функции avgState
DROP TABLE mv_avg_sales;
CREATE MATERIALIZED VIEW mv_avg_sales
ENGINE = AggregatingMergeTree() ORDER BY (category_id)
AS SELECT
    category_id,
    avgState(revenue) AS avg_revenue
FROM sales
GROUP BY category_id;

-- Вставляем данные в таблицу sales
INSERT INTO sales (product_id, category_id, order_date, revenue)
SELECT
    product_id,
    CASE
        WHEN product_id BETWEEN 1 AND 4 THEN 1
        WHEN product_id BETWEEN 5 AND 7 THEN 2
        WHEN product_id BETWEEN 8 AND 10 THEN 3
    END AS category_id,
    toDate('2023-09-01') + rand() % (toDate('2023-10-11') - toDate('2023-08-01')) AS order_date,
    rand() % 1000 + 500 AS revenue
FROM 
(select rand() % 10 + 1 AS product_id from numbers(1000)) as p
;

-- Затем объедините промежуточные результаты с использованием -Merge комбинатора, 
-- чтобы вычислить общую среднюю продажу за квартал
SELECT
    category_id,
    avgMerge(avg_revenue) AS avg_revenue
FROM mv_avg_sales
GROUP BY category_id
ORDER BY category_id;

-- Определите топ-5 товаров с наибольшей выручкой за последние 7 дней.
with total_sales as (select product_id, sum(revenue) as revenue_7_days from sales 
			where order_date >= now() - INTERVAL 7 DAY
			group by product_id),
table_row_number as (select product_id, 
			row_number() over(order by revenue_7_days desc) as n_row from total_sales) 
select product_id from table_row_number
where n_row <=5
order by n_row
;

--Найдите кумулятивную сумму продаж для каждой категории товаров за последние 3 месяца
select distinct category_id, order_date,
		sum(revenue) over(partition by category_id order by order_date) as cum_sum_revenue
from sales 
where order_date >= now() - INTERVAL 7 MONTH;


-- Создайте отчет о продажах за последний год и сохраните его в отдельной таблице
-- с использованием оператора INSERT
-- Создаем отчетную таблицу
CREATE TABLE last_year_sales
(
    order_date Date,
    revenue Float64
) ENGINE = MergeTree()
ORDER BY order_date;

-- Заполняем отчетную таблицу данными за последний год
INSERT INTO last_year_sales
SELECT order_date, sum(revenue) as revenue
FROM sales
WHERE order_date >= now() - INTERVAL 1 YEAR 
GROUP BY order_date;

-- Выполняем запрос для подсчета общей суммы продаж за последний год
SELECT SUM(revenue) AS total_last_year_sales
FROM last_year_sales;


