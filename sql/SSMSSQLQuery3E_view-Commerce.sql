USE [Database of kaggle datasets];
GO

CREATE VIEW dbo.Question3_GatewayProducts_vw AS
WITH RankedOrders AS (
    -- Step 1: Identify each customer's first order by ranking unique InvoiceNos by earliest date
    SELECT 
        CustomerID,
        InvoiceNo,
        DENSE_RANK() OVER (
            PARTITION BY CustomerID 
            ORDER BY MIN(InvoiceDate) ASC, InvoiceNo ASC
        ) AS order_rank
    FROM [Database of kaggle datasets].[dbo].[E-CommerceData]
    WHERE CustomerID IS NOT NULL 
      AND Quantity > 0
    GROUP BY CustomerID, InvoiceNo
),
FirstOrders AS (
    -- Step 2: Keep only the first order (order_rank = 1) for each customer
    SELECT CustomerID, InvoiceNo
    FROM RankedOrders
    WHERE order_rank = 1
)
-- Step 3: Count distinct new customers who purchased each product in their first order
SELECT TOP 5
    e.Description,
    COUNT(DISTINCT e.CustomerID) AS new_customers_bought
FROM [Database of kaggle datasets].[dbo].[E-CommerceData] e
JOIN FirstOrders f 
  ON e.CustomerID = f.CustomerID 
 AND e.InvoiceNo = f.InvoiceNo
WHERE e.Description IS NOT NULL
GROUP BY e.Description
ORDER BY new_customers_bought DESC;
GO