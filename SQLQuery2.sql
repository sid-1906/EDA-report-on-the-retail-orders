




--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    a.order_month,
    a.sales AS sales_2022,
    b.sales AS sales_2023,
    CASE 
        WHEN a.sales = 0 THEN NULL
        ELSE ROUND(((b.sales - a.sales) / a.sales) * 100, 2)
    END AS month_over_month_growth_percentage
FROM 
    cte a
LEFT JOIN 
    cte b
ON 
    a.order_month = b.order_month AND a.order_year = 2022 AND b.order_year = 2023
WHERE 
    a.order_year = 2022
ORDER BY 
    a.order_month;





--for each category which month had highest sales 
WITH cte AS (
    SELECT 
        category,
        FORMAT(order_date, 'yyyyMM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, FORMAT(order_date, 'yyyyMM')
),
ranked_sales AS (
    SELECT 
        category,
        order_year_month,
        sales,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
)
SELECT 
    category,
    order_year_month,
    sales
FROM ranked_sales
WHERE rn = 1;




--which sub category had highest growth by profit in 2023 compare 

WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
growth AS (
    SELECT 
        a.sub_category,
        a.sales AS sales_2022,
        b.sales AS sales_2023,
        CASE 
            WHEN a.sales = 0 THEN NULL
            ELSE ROUND(((b.sales - a.sales) / a.sales) * 100, 2)
        END AS growth_percentage
    FROM 
        cte a
    LEFT JOIN 
        cte b ON a.sub_category = b.sub_category AND a.order_year = 2022 AND b.order_year = 2023
)
SELECT 
    sub_category,
    sales_2022,
    sales_2023,
    growth_percentage
FROM growth
ORDER BY growth_percentage DESC











