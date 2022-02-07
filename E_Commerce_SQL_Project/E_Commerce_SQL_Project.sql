
/*
An e-commerce organization demands some analysis of sales and delivery processes.
Thus, the organization hopes to be able to predict more easily the opportunities and
threats for the future.
The following analyzes are made for this scenario by following the instructions given:

DATA ANALYSIS:

1. Join all the tables and create a new table with all of the columns, called
combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen,
shipping_dimen)

2. Find the top 3 customers who have the maximum count of orders.

3. Create a new column at combined_table as DaysTakenForDelivery that
contains the date difference of Order_Date and Ship_Date.

4. Find the customer whose order took the maximum time to get delivered.

5. Count the total number of unique customers in January and how many of them
came back every month over the entire year in 2011

6. Write a query to return for each user the time elapsed between the first
purchasing and the third purchasing, in ascending order by Customer ID.

7. Write a query that returns customers who purchased both product 11 and
product 14 as well as the ratio of these products to the total number of products
purchased by the customer

CUSTOMER RETENTION ANALYSIS

1. Create a view that keeps visit logs of customers on a monthly basis. 

2. Create a view that keeps the number of monthly visits by users. (Separately for
all months from the business beginning)

3. For each visit of customers, create the next month of the visit as a separate
column.

4. Calculate the monthly time gap between two consecutive visits by each
customer.

5. Categorise customers using average time gaps. Choose the most fitted labeling
model for you.
For example:
	o Labeled as churn if the customer hasn't made another purchase in the
	months since they made their first purchase.
	o Labeled as regular if the customer has made a purchase every month.


MONTH-WISE RETENTION RATE

1. Find the number of customers retained month-wise.

2. Calculate the month-wise retention rate.
	o Month-Wise Retention Rate = 1.0 * Total Number of Customers in 
	The Previous Month / Number of Customers Retained in The Next Nonth

*/

--DATA ANALYSIS:

--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)


		--First we have to check any NULL values on ID columns that will be used for joinning
		SELECT *
		FROM shipping_dimen
		WHERE Order_ID IS NULL

		SELECT *
		FROM prod_dimen
		WHERE Prod_id IS NULL

		SELECT *
		FROM orders_dimen
		WHERE Ord_id IS NULL

		SELECT *
		FROM cust_dimen
		WHERE Cust_id IS NULL

		-- We found no NULL values on ID columns so we can merge conveniently
		-- We should use FULL OUTER JOIN to get all rows of tables for making compiled table

SELECT mf.*,
		od.Order_Date,od.Order_Priority,
		cd.Customer_Name,cd.Customer_Segment,cd.Province,cd.Region,
		pd.Product_Category,pd.Product_Sub_Category,
		sd.Ship_Date,sd.Ship_Mode
		INTO combined_table
FROM market_fact mf
FULL JOIN orders_dimen od	ON mf.Ord_id = od.Ord_id
FULL JOIN cust_dimen cd		ON mf.Cust_id = cd.Cust_id
FULL JOIN prod_dimen pd		ON mf.Prod_id = pd.Prod_id
FULL JOIN shipping_dimen sd ON mf.Ship_id = sd.Ship_id

--////////////////////////////////////////////


--2. Find the top 3 customers who have the maximum count of orders.

SELECT TOP 3 ct.Cust_id, ct.Customer_Name, COUNT(*)
FROM combined_table ct
GROUP BY ct.Cust_id, ct.Customer_Name
ORDER BY COUNT(*) DESC


--////////////////////////////////////////////


--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.


ALTER TABLE combined_table
ADD DaysTakenForDelivery INT;

UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(DAY,Order_Date,Ship_Date)

		--Check for any NULL values at DaysTakenForDelivery
		SELECT *
		FROM combined_table
		WHERE DaysTakenForDelivery IS NULL

--////////////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.


SELECT TOP 1 Cust_id, Customer_Name, Order_Date, Ship_Date, DaysTakenForDelivery
FROM combined_table
ORDER BY DaysTakenForDelivery DESC


--////////////////////////////////////////////



--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

SELECT DATEPART(MONTH,Order_Date), COUNT(DISTINCT Cust_id)
FROM combined_table
WHERE DATEPART(YEAR,Order_Date) = 2011 AND Cust_id IN (SELECT DISTINCT Cust_id as January_customers
														FROM combined_table
														WHERE DATEPART(MONTH,Order_Date) = 01 AND DATEPART(YEAR,Order_Date) = 2011)
GROUP BY DATEPART(MONTH,Order_Date)	


--////////////////////////////////////////////


--6. For each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID

WITH T1 AS(
			SELECT Cust_id,Order_Date, 
			DENSE_RANK() OVER (PARTITION BY Cust_id ORDER BY Order_Date ) as dense_number, 
			MIN(Order_Date) OVER (PARTITION BY Cust_id ORDER BY Order_Date ) as FIRST_ORDER_DATE
			FROM combined_table
			)

SELECT DISTINCT ct.Cust_id, T1.Order_Date, T1.dense_number, T1.FIRST_ORDER_DATE, DATEDIFF(DAY,T1.FIRST_ORDER_DATE,ct.Order_Date) DAYS_ELAPSED
FROM combined_table ct JOIN T1 ON ct.Cust_id = T1.Cust_id
WHERE T1.dense_number = 3 and ct.Order_Date=T1.Order_Date
ORDER BY ct.Cust_id ASC



--////////////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer.



WITH T1 AS
(SELECT ct.Cust_id, 
		SUM (CASE WHEN ct.Prod_id = 'Prod_11' THEN CONVERT(INT, ct.Order_Quantity) ELSE 0 END) AS P11,
		SUM (CASE WHEN ct.Prod_id = 'Prod_14' THEN CONVERT(INT, ct.Order_Quantity) ELSE 0 END) AS P14,
		SUM(CONVERT(INT, ct.Order_Quantity)) AS TOTAL_PRODUCT
FROM combined_table ct
WHERE ct.Cust_id IN (SELECT DISTINCT Cust_id
					 FROM combined_table
					 WHERE Cust_id IN (	SELECT Cust_id FROM combined_table WHERE Prod_id = 'Prod_14'
										INTERSECT
										SELECT Cust_id FROM combined_table WHERE Prod_id = 'Prod_11')
										)
GROUP BY ct.Cust_id
)

SELECT *, 	
	CONVERT(NUMERIC(5,2)  , 1.0 * P11 / TOTAL_PRODUCT) AS RATIO_P11,
	CONVERT(NUMERIC(5,2)  , 1.0 * P14 / TOTAL_PRODUCT) AS RATIO_P14
FROM T1;

--////////////////////////////////////////////
--////////////////////////////////////////////



--CUSTOMER RETENTION ANALYSIS


--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)

CREATE VIEW logs AS
  (SELECT Cust_id, DATEPART(YEAR, Order_Date) [Year], DATEPART(MONTH, Order_Date) [Month]
  FROM combined_table  
  )


--////////////////////////////////////////////


--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)


CREATE VIEW NUM_OF_LOGS AS
  (SELECT	Cust_id, 
			DATEPART(YEAR, Order_Date) [Year], 
			DATEPART(MONTH, Order_Date) [Month], 
			COUNT(*) NUM_OF_LOG
  FROM combined_table  
  GROUP BY Cust_id, DATEPART(YEAR, Order_Date), DATEPART(MONTH, Order_Date)
  )
   

--////////////////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
-- A new column for each month showing the next month using

WITH T1 AS(
SELECT DISTINCT  Cust_id, 
	 DATEPART(YEAR, Order_Date) [Year], 
	DATEPART(MONTH, Order_Date)  [Month], 
	COUNT(*) OVER (PARTITION BY Cust_id,DATEPART(YEAR, Order_Date), DATEPART(MONTH, Order_Date) ORDER BY Order_Date ) NUM_OF_LOG,
	DENSE_RANK() OVER (ORDER BY DATEPART(YEAR, Order_Date),DATEPART(MONTH, Order_Date)) CURRENT_MONTH
FROM combined_table
)
SELECT *,
LEAD(CURRENT_MONTH,1) OVER (PARTITION BY Cust_id ORDER BY [Year], [Month] ) NEXT_MONTH
FROM T1


--////////////////////////////////////////////

--4. Calculate the monthly time gap between two consecutive visits by each customer.

WITH T1 AS(
SELECT DISTINCT  Cust_id, 
	 DATEPART(YEAR, Order_Date) [Year], 
	DATEPART(MONTH, Order_Date)  [Month], 
	COUNT(*) OVER (PARTITION BY Cust_id,DATEPART(YEAR, Order_Date), DATEPART(MONTH, Order_Date) ORDER BY Order_Date ) NUM_OF_LOG,
	DENSE_RANK() OVER (ORDER BY DATEPART(YEAR, Order_Date),DATEPART(MONTH, Order_Date)) CURRENT_MONTH
FROM combined_table
),

T2 AS (
SELECT *,
LEAD(CURRENT_MONTH,1) OVER (PARTITION BY Cust_id ORDER BY [Year], [Month] ) NEXT_MONTH
FROM T1
)
SELECT DISTINCT Cust_id,  
		AVG(NEXT_MONTH - CURRENT_MONTH)  OVER (PARTITION BY Cust_id ) AVG_TIME_GAP
FROM T2
ORDER BY Cust_id


--////////////////////////////////////////////


--5.Categorise customers using time gaps. 
--	Label as churn if the customer hasn't made another purchase in the next months since they made their first purchase.

WITH T1 AS(
SELECT DISTINCT  Cust_id, 
	 DATEPART(YEAR, Order_Date) [Year], 
	DATEPART(MONTH, Order_Date)  [Month], 
	COUNT(*) OVER (PARTITION BY Cust_id,DATEPART(YEAR, Order_Date), DATEPART(MONTH, Order_Date) ORDER BY Order_Date ) NUM_OF_LOG,
	DENSE_RANK() OVER (ORDER BY DATEPART(YEAR, Order_Date),DATEPART(MONTH, Order_Date)) CURRENT_MONTH
FROM combined_table
),

T2 AS (
SELECT *,
LEAD(CURRENT_MONTH,1) OVER (PARTITION BY Cust_id ORDER BY [Year], [Month] ) NEXT_MONTH
FROM T1
),
T3 AS (
SELECT DISTINCT Cust_id,  
		AVG(NEXT_MONTH - CURRENT_MONTH)  OVER (PARTITION BY Cust_id ) AVG_TIME_GAP
FROM T2

)

SELECT *,
CASE WHEN AVG_TIME_GAP IS NULL THEN 'Churn' ELSE 'Irregular' END  CUST_LABELS
FROM T3
ORDER BY Cust_id


--////////////////////////////////////////////
--////////////////////////////////////////////


--MONTH-WISE RETENTION RATE

--Find month-by-month customer retention rate  since the start of the business.


--1. Find the number of customers retained month-wise.


CREATE VIEW RET_CUST AS 

SELECT DISTINCT Cust_id,  [Year], [Month],CURRENT_MONTH, NEXT_MONTH, (NEXT_MONTH - CURRENT_MONTH) TIME_GAP
	,COUNT(Cust_id)	OVER (PARTITION BY  [Year], [Month]   ) CUST_CNT

FROM (
			SELECT *,
			LEAD(CURRENT_MONTH,1) OVER (PARTITION BY Cust_id ORDER BY [Year], [Month] ) NEXT_MONTH
			FROM (SELECT DISTINCT  Cust_id, 
					 DATEPART(YEAR, Order_Date) [Year], 
					DATEPART(MONTH, Order_Date)  [Month], 
					COUNT(*) OVER (PARTITION BY Cust_id,DATEPART(YEAR, Order_Date), DATEPART(MONTH, Order_Date) ORDER BY Order_Date ) NUM_OF_LOG,
					DENSE_RANK() OVER (ORDER BY DATEPART(YEAR, Order_Date),DATEPART(MONTH, Order_Date)) CURRENT_MONTH
					FROM combined_table) T1
			) T2

SELECT Cust_id,  [Year], [Month],CURRENT_MONTH, NEXT_MONTH,TIME_GAP
	,COUNT(*) OVER (PARTITION BY [Year], [Month]) RETENTION_MONTH_WISE
FROM RET_CUST
WHERE TIME_GAP=1
ORDER BY Cust_id


--////////////////////////////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Total Number of Customers in The Previous Month / Number of Customers Retained in The Next Nonth

WITH T3 AS (
		SELECT *,
		COUNT(*) OVER (PARTITION BY [Year], [Month]) RETENTION_MONTH_WISE
		FROM RET_CUST
		WHERE TIME_GAP=1)
SELECT DISTINCT [Year], [Month], CONVERT(NUMERIC(3,2)  ,1.0 * RETENTION_MONTH_WISE / CUST_CNT) RETENTION_RATE
FROM T3



--////////////////////////////////////////////
--////////////////////////////////////////////
--////////////////////////////////////////////