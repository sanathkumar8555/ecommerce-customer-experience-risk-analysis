-- E-Commerce Customer Experience & Risk Analysis
-- Recovered from MySQL Workbench SQL history.
-- Curated analytical queries only; data import and destructive setup statements excluded.
-- Validate results against your current database before publishing.

USE ecommerce_cx_analysis;

-- Duplicate order detection
select order_id, count(order_id) as duplicate_count from orders
group by order_id having count(order_id) > 1 order by duplicate_count desc;

-- Missing delivery and approval timestamps
SELECT
    COUNT(*) AS total_orders,
    SUM(order_approved_at IS NULL OR TRIM(order_approved_at) = '') AS missing_approved,
    SUM(order_delivered_carrier_date IS NULL OR TRIM(order_delivered_carrier_date) = '') AS missing_carrier,
    SUM(order_delivered_customer_date IS NULL OR TRIM(order_delivered_customer_date) = '') AS missing_delivered
FROM orders;

-- Order status distribution
select order_status, count(*) as total_orders from orders group by order_status order by total_orders desc;

-- Review data validation
SELECT
    COUNT(*) AS total_reviews,
    COUNT(review_id) AS non_null_review_ids,
    COUNT(order_id) AS non_null_order_ids,
    MIN(review_score) AS min_score,
    MAX(review_score) AS max_score
FROM reviews;

-- Missing review comments
select count(*) as total_orders, sum(review_comment_title is null or trim(review_comment_title) = '') as comment_title,
sum(review_comment_message is null or trim(review_comment_message) = '') as comment_message from reviews;

-- Multiple reviews per order
select order_id, count(order_id) as review_count from reviews group by order_id having review_count > 1;

-- Order ID uniqueness
select count(*) as total_orders, count(distinct order_id) as unique_orders from orders;

-- Review coverage by order
select count(*) as total_reviews, count(distinct order_id) as unique_reviews from reviews;

-- Order status percentages
select order_status, count(order_id) as total_orders, round(count(order_id)*100.0/(select count(*) from orders),2) as percentage 
from orders group by order_status order by total_orders desc;

-- Delivery status distribution
WITH delivery_data AS (
    SELECT
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    CASE
        WHEN order_delivered_customer_date IS NULL
             OR TRIM(order_delivered_customer_date) = ''
        THEN 'Not Delivered'

        WHEN DATE(STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'))
           < DATE(STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s'))
        THEN 'Early'

        WHEN DATE(STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'))
           = DATE(STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s'))
        THEN 'On Time'

        WHEN DATE(STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'))
           > DATE(STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s'))
        THEN 'Late'

        ELSE 'Unknown'
    END AS delivery_status

FROM orders
)
SELECT
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage
FROM delivery_data
GROUP BY delivery_status;

-- Order delivery duration and delay
SELECT
    order_id,

    DATEDIFF(
       order_delivered_customer_date,
       order_purchase_timestamp
    ) AS delivery_days,

    DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date
    ) AS delay_days

FROM orders
WHERE order_status = 'delivered';

-- Average delivery duration
SELECT
    ROUND(
        AVG(DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )),
        2
    ) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered';

-- Average late delivery days
SELECT
    ROUND(
        AVG(DATEDIFF(
            order_delivered_customer_date,
           order_estimated_delivery_date
        )),
        2
    ) AS avg_late_days
FROM orders
WHERE order_status = 'delivered'
AND DATEDIFF(
    order_delivered_customer_date,
    order_estimated_delivery_date
) > 0;

-- Monthly late delivery percentage
SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(*) AS total_orders,

    ROUND(
        SUM(
            CASE
                WHEN DATEDIFF(
                    order_delivered_customer_date,
                    order_estimated_delivery_date
                ) > 0
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_percentage

FROM orders
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY order_year, order_month;

-- Review score summary
SELECT
    COUNT(*) AS total_reviews,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    MIN(review_score) AS lowest_review_score,
    MAX(review_score) AS highest_review_score
FROM reviews;

-- Review rating distribution
SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM reviews
GROUP BY review_score
ORDER BY review_score;

-- Low rating percentage
SELECT
    SUM(
        CASE
            WHEN review_score IN (1, 2) THEN 1
            ELSE 0
        END
    ) AS low_rating_reviews,

    COUNT(*) AS total_reviews,

    ROUND(
        SUM(
            CASE
                WHEN review_score IN (1, 2) THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS low_rating_percentage

FROM reviews;

-- Order-review join
SELECT
    o.order_id,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    r.review_score
FROM orders o
INNER JOIN reviews r
    ON o.order_id = r.order_id;

-- Delivery performance versus reviews
WITH review_summary AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM reviews
    GROUP BY order_id
),

delivery_analysis AS (
    SELECT
        o.order_id,
        r.avg_review_score,

        CASE
            WHEN DATEDIFF(
                o.order_delivered_customer_date,
                o.order_estimated_delivery_date
            ) < 0 THEN 'Early'

            WHEN DATEDIFF(
                o.order_delivered_customer_date,
                o.order_estimated_delivery_date
            ) = 0 THEN 'On Time'

            WHEN DATEDIFF(
                o.order_delivered_customer_date,
                o.order_estimated_delivery_date
            ) > 0 THEN 'Late'

            ELSE 'Unknown'
        END AS delivery_status

    FROM orders o
    INNER JOIN review_summary r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND TRIM(o.order_delivered_customer_date) <> ''
)

SELECT
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,

    ROUND(
        SUM(
            CASE
                WHEN avg_review_score <= 2 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS low_rating_percentage

FROM delivery_analysis
WHERE delivery_status <> 'Unknown'
GROUP BY delivery_status
ORDER BY
    CASE delivery_status
        WHEN 'Early' THEN 1
        WHEN 'On Time' THEN 2
        WHEN 'Late' THEN 3
    END;

-- Delay severity versus reviews
WITH review_summary AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM reviews
    GROUP BY order_id
),
late_orders AS (
    SELECT
        o.order_id,
        r.avg_review_score,
        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date
        ) AS delay_days
    FROM orders o
    INNER JOIN review_summary r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND NULLIF(TRIM(o.order_delivered_customer_date), '') IS NOT NULL
),
delay_categories AS (
    SELECT
        order_id,
        avg_review_score,
        CASE
            WHEN delay_days BETWEEN 1 AND 3 THEN 'Short Delay'
            WHEN delay_days BETWEEN 4 AND 7 THEN 'Medium Delay'
            WHEN delay_days >= 8 THEN 'Long Delay'
        END AS delay_category
    FROM late_orders
    WHERE delay_days > 0
)
SELECT
    delay_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    ROUND(
        SUM(CASE WHEN avg_review_score <= 2 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS low_rating_percentage
FROM delay_categories
GROUP BY delay_category
ORDER BY
    CASE delay_category
        WHEN 'Short Delay' THEN 1
        WHEN 'Medium Delay' THEN 2
        WHEN 'Long Delay' THEN 3
    END;

-- Monthly delivery risk ranking using window function
WITH review_summary AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM reviews
    GROUP BY order_id
),
monthly_data AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS order_year,
        MONTH(o.order_purchase_timestamp) AS order_month,
        COUNT(*) AS total_orders,
        SUM(
            CASE
                WHEN DATEDIFF(
                    o.order_delivered_customer_date,
                    o.order_estimated_delivery_date
                ) > 0 THEN 1
                ELSE 0
            END
        ) AS late_orders,
        ROUND(
            SUM(
                CASE
                    WHEN r.avg_review_score <= 2 THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS low_rating_percentage
    FROM orders o
    INNER JOIN review_summary r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND NULLIF(TRIM(o.order_delivered_customer_date), '') IS NOT NULL
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
),
monthly_kpis AS (
    SELECT
        order_year,
        order_month,
        total_orders,
        late_orders,
        ROUND(
            late_orders * 100.0 / total_orders,
            2
        ) AS late_delivery_percentage,
        low_rating_percentage
    FROM monthly_data
)
SELECT
    order_year,
    order_month,
    total_orders,
    late_orders,
    late_delivery_percentage,
    low_rating_percentage,
    DENSE_RANK() OVER (
        ORDER BY late_delivery_percentage DESC
    ) AS late_delivery_rank
FROM monthly_kpis
WHERE total_orders >= 100
ORDER BY late_delivery_rank, order_year, order_month;

-- Overall business KPIs
WITH review_summary AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM reviews
    GROUP BY order_id
),
order_analysis AS (
    SELECT
        o.order_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        r.avg_review_score,

        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp
        ) AS delivery_days,

        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date
        ) AS delay_days

    FROM orders o
    LEFT JOIN review_summary r
        ON o.order_id = r.order_id
)
SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE WHEN order_status = 'delivered'
        THEN 1 ELSE 0 END
    ) AS delivered_orders,

    ROUND(
        SUM(
            CASE WHEN order_status = 'delivered'
            THEN 1 ELSE 0 END
        ) * 100.0 / COUNT(*),
        2
    ) AS delivery_rate_percentage,

    SUM(
        CASE WHEN delay_days > 0
        THEN 1 ELSE 0 END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE WHEN delay_days > 0
            THEN 1 ELSE 0 END
        ) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_percentage,

    ROUND(
        AVG(
            CASE WHEN order_status = 'delivered'
            THEN delivery_days END
        ),
        2
    ) AS avg_delivery_days,

    ROUND(
        AVG(
            CASE WHEN delay_days > 0
            THEN delay_days END
        ),
        2
    ) AS avg_late_days,

    COUNT(avg_review_score) AS reviewed_orders,

    ROUND(
        AVG(avg_review_score),
        2
    ) AS avg_review_score,

    ROUND(
        SUM(
            CASE WHEN avg_review_score <= 2
            THEN 1 ELSE 0 END
        ) * 100.0 / NULLIF(COUNT(avg_review_score), 0),
        2
    ) AS low_rating_percentage

FROM order_analysis;
