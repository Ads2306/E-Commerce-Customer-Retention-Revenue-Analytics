USE [Database of kaggle datasets];
GO

CREATE VIEW dbo.Question2_RepeatPurchaseGap_vw AS
WITH DistinctOrders AS (
    -- 1: Collapse items down to 1 row per unique InvoiceNo
    SELECT 
        CustomerID,
        InvoiceNo,
        MIN(CAST(InvoiceDate AS DATE)) AS order_date,
        MIN(InvoiceDate) AS exact_timestamp
    FROM [Database of kaggle datasets].[dbo].[E-CommerceData]
    WHERE CustomerID IS NOT NULL 
      AND Quantity > 0
    GROUP BY CustomerID, InvoiceNo
),
RankedOrders AS (
    -- 2: Rank the distinct orders sequentially
    SELECT 
        CustomerID,
        InvoiceNo,
        order_date,
        DENSE_RANK() OVER (
            PARTITION BY CustomerID 
            ORDER BY exact_timestamp ASC, InvoiceNo ASC
        ) AS order_rank
    FROM DistinctOrders
),
FirstTwoOrders AS (
    -- 3: Pivot the 1st and 2nd order dates
    SELECT 
        CustomerID,
        MAX(CASE WHEN order_rank = 1 THEN order_date END) AS first_order_date,
        MAX(CASE WHEN order_rank = 2 THEN order_date END) AS second_order_date
    FROM RankedOrders
    WHERE order_rank IN (1, 2)
    GROUP BY CustomerID
)
-- 4: Calculate the average gap in days
SELECT 
    ROUND(AVG(CAST(DATEDIFF(day, first_order_date, second_order_date) AS FLOAT)), 1) AS avg_days_to_second_order
FROM FirstTwoOrders
WHERE second_order_date IS NOT NULL;
GO