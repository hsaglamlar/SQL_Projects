An e-commerce organization demands some analysis of sales and delivery processes. Thus, the organization hopes to be able to predict more easily the opportunities and
threats for the future. 
In this project the following analyzes are made for this scenario by following the instructions given:

## DATA ANALYSIS:
1. Join all the tables and create a new table with all of the columns, called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
2. Find the top 3 customers who have the maximum count of orders.
3. Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
4. Find the customer whose order took the maximum time to get delivered.
5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
6. Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID.
7. Write a query that returns customers who purchased both product 11 and product 14 as well as the ratio of these products to the total number of products purchased by the customer

## CUSTOMER RETENTION ANALYSIS
1. Create a view that keeps visit logs of customers on a monthly basis. 
2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
3. For each visit of customers, create the next month of the visit as a separate column.
4. Calculate the monthly time gap between two consecutive visits by each customer.
5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
  For example:
    - Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
    - Labeled as regular if the customer has made a purchase every month.
    
## MONTH-WISE RETENTION RATE
1. Find the number of customers retained month-wise.
2. Calculate the month-wise retention rate.
	- Month-Wise Retention Rate = 1.0 * Total Number of Customers in The Previous Month / Number of Customers Retained in The Next Nonth
