USE [Database of kaggle datasets];
GO

CREATE VIEW dbo.Question5_CancellationAnalysis_vw AS
SELECT 
    Country,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CASE WHEN Quantity <= 0 OR InvoiceNo LIKE 'C%' THEN InvoiceNo END) AS cancelled_orders,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN Quantity <= 0 OR InvoiceNo LIKE 'C%' THEN InvoiceNo END) / 
        NULLIF(COUNT(DISTINCT InvoiceNo), 0), 
    2) AS cancellation_rate_pct
FROM [Database of kaggle datasets].[dbo].[E-CommerceData]
GROUP BY Country
HAVING COUNT(DISTINCT InvoiceNo) >= 100;
GO