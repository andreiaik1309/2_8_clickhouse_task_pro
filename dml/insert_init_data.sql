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


