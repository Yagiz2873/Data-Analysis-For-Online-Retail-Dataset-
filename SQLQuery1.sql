-- RFM SEGMENTATION IN SQL 

SELECT * FROM ['Final $']

SELECT ID FROM ['Final $']
WHERE ID IS NULL

SELECT ID, InvoiceNo FROM ['Final $'] 
WHERE InvoiceNo IS NULL

SELECT ID, StockCode FROM ['Final $']
WHERE StockCode IS NULL

SELECT ID, [Description] FROM ['Final $']
WHERE [Description] IS NULL

SELECT ID, Quantity FROM ['Final $']
WHERE Quantity IS NULL 

SELECT ID, Quantity FROM ['Final $']
WHERE Quantity > 27
-- This is handled dataset then

SELECT ID, UnitPrice FROM ['Final $']
WHERE UnitPrice IS NULL 

SELECT ID, InvoiceDate FROM ['Final $']
WHERE InvoiceDate IS NULL 

SELECT ID, [Time] FROM ['Final $']
WHERE [Time] IS NULL

SELECT ID, CustomerID FROM ['Final $']
WHERE CustomerID IS NULL

SELECT ID, Country FROM ['Final $']
WHERE Country IS NULL

SELECT ID, Country FROM ['Final $']
WHERE Country = 'U'
--Okay it's sure handled dataset :) 

--It seems that there are some type problems in InvoiceNo ,StockCode and InvoiceDate (They had NULL values before). I have to transform their types in Excel
-- Notes to myself: to install SQL completely, you must install both SQL server and SSMS You need a server too :) . Also check out the firewall

SELECT CustomerID, AVG(Quantity) AS Quantity, AVG(UnitPrice) AS UnitPrice, COUNT(DISTINCT InvoiceDate) as Frequency FROM ['Final $']
GROUP BY CustomerID
ORDER BY CustomerID   

-- I've changed InvoiceNo, StockCode and Time's types by using format cells in Excel. Also I've changed US dates to UK dates by using text to column's MYD formats in Excel too.
SELECT * FROM ['Final $']

--Rule Based RFM Segmentation
SELECT * FROM ['Final $']
ORDER BY InvoiceDate DESC

SELECT MAX(InvoiceDate) AS MAX_DATE FROM ['Final $'] 

-- Let's suppose that our final date is 2011-12-11 
ALTER TABLE  ['Final $'] DROP COLUMN DayDiff

ALTER TABLE ['Final $'] ADD DayDiff int
UPDATE ['Final $'] SET DayDiff = DATEDIFF(DAY,InvoiceDate,'2011-12-11') -- int = string - datetime



--Preparing RFM values
SELECT * INTO Final2 FROM
(SELECT CustomerID, ROUND(AVG(Quantity),2) as AvgQuantity, ROUND(AVG(UnitPrice),2) as AvgUnitPrice, MIN(DayDiff) as Recency, COUNT(DISTINCT InvoiceNo) as Frequency ,MAX(DayDiff) as Tenure FROM ['Final $']
GROUP BY CustomerID) T1

SELECT * FROM Final2

--ALTER TABLE ['Final $'] DROP COLUMN R_Score
--ALTER TABLE ['Final $'] DROP COLUMN F_Score
--ALTER TABLE ['Final $'] DROP COLUMN M_Score
--ALTER TABLE ['Final $'] DROP COLUMN AvgQuantity


--Preparing R,F and M scores
ALTER TABLE Final2 ADD R_Score int
ALTER TABLE Final2 ADD F_Score int
ALTER TABLE Final2 ADD Monetary float
UPDATE Final2 SET Monetary = ROUND((AvgQuantity * AvgUnitPrice),2)
ALTER TABLE Final2 ADD M_Score int

--updating score columns
UPDATE Final2 SET R_Score = 
(
 SELECT SCORE FROM
 (
    SELECT hw.* , NTILE(5) OVER(ORDER BY Recency DESC) AS SCORE
    FROM Final2 AS hw
 ) T
    WHERE T.CustomerID = Final2.CustomerID
)



UPDATE Final2 SET F_Score = 
(
 SELECT SCORE FROM
 (
    SELECT hw.* , NTILE(5) OVER(ORDER BY Frequency) AS SCORE
    FROM Final2 AS hw
 ) T
    WHERE T.CustomerID = Final2.CustomerID
)


UPDATE Final2 SET M_Score = 
(
 SELECT SCORE FROM
 (
    SELECT hw.* , NTILE(5) OVER(ORDER BY Monetary) AS SCORE
    FROM Final2 AS hw
 ) T
    WHERE T.CustomerID = Final2.CustomerID
)

SELECT * FROM Final2

--Creating Segments according to the Regexes
ALTER TABLE Final2 ADD RF_Score AS (CONVERT(VARCHAR,R_Score) + CONVERT(VARCHAR,F_Score) ) 


ALTER TABLE Final2 ADD Segment Varchar(50)

UPDATE Final2 SET Segment = 'Hibernating'
WHERE R_Score LIKE '[1-2]%' AND F_Score LIKE '[1-2]%'

UPDATE Final2 SET Segment = 'At Risk'
WHERE R_Score LIKE '[1-2]%' AND F_Score LIKE '[3-4]%'

UPDATE Final2 SET Segment = 'Can Not Lose'
WHERE R_Score LIKE '[1-2]%' AND F_Score LIKE '[5]%'

UPDATE Final2 SET Segment = 'About To Sleep'
WHERE R_Score LIKE '[3]%' AND F_Score LIKE '[1-2]%'

UPDATE Final2 SET Segment = 'Need Attention'
WHERE R_Score LIKE '[3]%' AND F_Score LIKE '[3]%'

UPDATE Final2 SET Segment = 'Loyal Customers'
WHERE R_Score LIKE '[3-4]%' AND F_Score LIKE '[4-5]%'   

UPDATE Final2 SET Segment = 'Promising'
WHERE R_Score LIKE '[4]%' AND F_Score LIKE '[1]%'

UPDATE Final2 SET Segment = 'New Customers'
WHERE R_Score LIKE '[5]%' AND F_Score LIKE '[1]%'

UPDATE Final2 SET Segment = 'Potential Loyalists'
WHERE R_Score LIKE '[4-5]%' AND F_Score LIKE '[2-3]%'

UPDATE Final2 SET Segment = 'Champions'
WHERE R_Score LIKE '[5]%' AND F_Score LIKE '[4-5]%' 

-- RFM Segmentation Table for Customers
SELECT * FROM Final2 

-- First Table 
SELECT * FROM ['Final $']  
