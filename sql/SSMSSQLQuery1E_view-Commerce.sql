USE [Database of kaggle datasets];
GO

CREATE VIEW dbo.Question1_TopUKCustomers_vw AS
SELECT TOP 5
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    SUM(Quantity * UnitPrice) AS total_revenue,
    ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2) AS average_order_value
FROM [Database of kaggle datasets].[dbo].[E-CommerceData]
WHERE Country = 'United Kingdom'
  AND CustomerID IS NOT NULL
  AND Quantity > 0
GROUP BY CustomerID
ORDER BY total_revenue DESC;

GO