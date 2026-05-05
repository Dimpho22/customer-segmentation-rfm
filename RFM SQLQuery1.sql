USE SalesAnalysisDB
GO
SELECT TOP 5 * FROM [sales_data ];
SELECT MAX(Order_Date) AS MaxDate FROM [sales_data ];

SELECT 
    [Customer_Name],
    DATEDIFF(DAY, MAX([Order_Date]), (SELECT MAX([Order_Date]) FROM [sales_data ])) AS Recency,
    COUNT([Order_ID]) AS Frequency,
    SUM(Sales) AS Monetary
FROM [sales_data ]
GROUP BY [Customer_Name];

WITH rfm AS (
    SELECT 
        [Customer_Name],
        DATEDIFF(DAY, MAX([Order_Date]), (SELECT MAX([Order_Date]) FROM [sales_data ])) AS Recency,
        COUNT([Order_ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM [sales_data ]
    GROUP BY [Customer_Name]
)
SELECT * FROM rfm;

WITH rfm AS (
    SELECT 
        [Customer_Name],
        DATEDIFF(DAY, MAX([Order_Date]), (SELECT MAX([Order_Date]) FROM [sales_data ])) AS Recency,
        COUNT([Order_ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM [sales_data ]
    GROUP BY [Customer_Name]
)
SELECT 
    *,
    NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
    NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
    NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
FROM rfm;

WITH rfm AS (
    SELECT 
        [Customer_Name],
        DATEDIFF(DAY, MAX([Order_Date]), (SELECT MAX([Order_Date]) FROM [sales_data ])) AS Recency,
        COUNT([Order_ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM [sales_data ]
    GROUP BY [Customer_Name]
),
scored AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM rfm
)
SELECT 
    *,
    CASE 
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'High Value'
        WHEN F_Score >= 4 THEN 'Loyal'
        WHEN R_Score <= 2 THEN 'At Risk'
        ELSE 'Average'
    END AS Segment
FROM scored;

