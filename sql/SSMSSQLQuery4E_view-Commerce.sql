USE [Database of kaggle datasets];
GO

CREATE VIEW dbo.Question4_CohortRetention_vw AS
WITH CustomerCohorts AS (
    -- Step 1: Find each customer's first purchase month
    SELECT 
        CustomerID,
        DATEFROMPARTS(YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)), 1) AS cohort_month
    FROM [Database of kaggle datasets].[dbo].[E-CommerceData]
    WHERE CustomerID IS NOT NULL 
      AND Quantity > 0
    GROUP BY CustomerID
),
CustomerActivity AS (
    -- Step 2: Get all distinct transaction months per customer
    SELECT DISTINCT
        CustomerID,
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS activity_month
    FROM [Database of kaggle datasets].[dbo].[E-CommerceData]
    WHERE CustomerID IS NOT NULL 
      AND Quantity > 0
)
-- Step 3: Aggregate cohort sizes and retention for Month 0 and Month 1
SELECT 
    c.cohort_month,
    COUNT(DISTINCT c.CustomerID) AS cohort_size,
    COUNT(DISTINCT CASE 
        WHEN DATEDIFF(month, c.cohort_month, a.activity_month) = 0 THEN c.CustomerID 
    END) AS month_0_users,
    COUNT(DISTINCT CASE 
        WHEN DATEDIFF(month, c.cohort_month, a.activity_month) = 1 THEN c.CustomerID 
    END) AS month_1_users
FROM CustomerCohorts c
JOIN CustomerActivity a ON c.CustomerID = a.CustomerID
GROUP BY c.cohort_month;
GO