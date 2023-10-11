CREATE TABLE IF NOT EXISTS sales (
    product_id    Int64,
    category_id   Int64,
    order_date    Date,
    revenue       Float32
) ENGINE = MergeTree()
ORDER BY (product_id, category_id, order_date)

; 