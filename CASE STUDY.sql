
SELECT *FROM SALES;
SELECT COUNT(*) FROM SALES;

SELECT *FROM SALES;
ALTER TABLE sales CHANGE `ORDER ID`  ORDER_ID TEXT(20);
ALTER TABLE sales CHANGE `ORDER DATE`  ORDER_DATE TEXT(20);
ALTER TABLE sales CHANGE `SHIP DATE`  SHIP_DATE TEXT(20);
ALTER TABLE sales CHANGE `SHIP MODE`  SHIP_MODE TEXT(20);
ALTER TABLE sales CHANGE `CUSTOMER ID`  CUSTOMER_ID TEXT(20);
ALTER TABLE sales CHANGE `CUSTOMER NAME`  CUSTOMER_NAME TEXT(20);
ALTER TABLE sales CHANGE `POSTAL CODE`  POSTAL_CODE TEXT(20);
ALTER TABLE sales CHANGE `PRODUCT ID`  PRODUCT_ID TEXT(20);
ALTER TABLE sales CHANGE `SUB-CATEGORY`  SUB_CATEGORY TEXT(20);
ALTER TABLE sales CHANGE `PRODUCT NAME`  PRODUCT_NAME TEXT(20);


DESC sales;

set sql_safe_updates=0;
update sales set order_date=replace(order_date,'-','/');#-----------1
UPDATE sales SET Order_Date = STR_TO_DATE(Order_Date, '%d/%m/%Y');#---------------2 
ALTER TABLE sales MODIFY Order_Date DATE;#------------------3

SELECT * FROM SALES;
# CHECK the blank values in each column
SELECT * FROM SALES WHERE ORDER_ID = " " OR  -- {TAKING KEY COLUMNS LIKE ORDER_DATE,ORDER_ID}
                          PRODUCT_ID = " " OR
                          CUSTOMER_ID = " ";
-- THERE ARE NO BLANK COLUMNS --

#CHECK the NULL values in each column
SELECT * FROM SALES WHERE ORDER_ID IS NULL OR
						  PRODUCT_ID IS NULL;
-- THERE IS NO NULL VALUES --

#FIND THE DUPLICATES
SELECT ORDER_ID,PRODUCT_ID,COUNT(*)
FROM SALES
GROUP BY ORDER_ID,PRODUCT_ID
HAVING COUNT(*)>1;

-- CHECKING --
-- COPY FIELD THEN
SELECT * FROM SALES WHERE ORDER_ID='CA-2016-129714';     -- HERE WE ARE GETTING 5 ORDER_ID INSTEAD OF 2, NOT DUPLICATE  --

#DISPLAY the unique number of orders, customers, cities, and states
SELECT COUNT(DISTINCT(ORDER_ID))AS ORDERS,
	   COUNT(DISTINCT(CUSTOMER_ID)) AS CUSTOMERS,
       COUNT(DISTINCT(CITY))AS CITIES,
       COUNT(DISTINCT(STATE))AS STATE
       FROM SALES
       ;

#Determine the number of products sold and the number of customers and top 10 profitable states & cities.
-- THE FIRST NUMBER OF PRODUCTS SOLD IS SUM | THE NUMBER OF CUSTOMERS IS COUNT |
SELECT STATE,CITY,SUM(QUANTITY)AS PRODUCTS_SOLD,COUNT(CUSTOMER_ID) AS CUSTOMERS,
       ROUND(SUM(PROFIT),2) AS PROFITS
       FROM SALES
       GROUP BY STATE,CITY
       ORDER BY PROFITS DESC
       LIMIT 10;
       
#Top 5 Customers with the most no. of orders
SELECT CUSTOMER_NAME,COUNT(ORDER_ID) AS TOTAL_ORDERS FROM SALES   
	   GROUP BY 1
       ORDER BY COUNT(ORDER_ID) DESC
       LIMIT 5;    
       
#Top 5 Cities with no. of orders
SELECT CITY,COUNT(ORDER_ID) AS TOTAL_ORDERS FROM SALES   
	   GROUP BY CITY
       ORDER BY COUNT(ORDER_ID) DESC
       LIMIT 5;  
       
#Top 5 States with the most no. of orders
SELECT STATE,COUNT(ORDER_ID) AS TOTAL_ORDERS FROM SALES    
	   GROUP BY STATE
       ORDER BY COUNT(ORDER_ID) DESC
       LIMIT 5;  
       
#Top 5 dates on which the highest SALES was generated
SELECT ORDER_DATE,ROUND(SUM(SALES),2) AS SALES FROM SALES
       GROUP BY ORDER_DATE
       ORDER BY SALES DESC
       LIMIT 5;
       
#Calculate Total Sales Per Month 
SELECT YEAR(ORDER_DATE) AS YEAR,
       MONTH(ORDER_DATE) AS MONTH_NO,
       MONTHNAME(ORDER_DATE) AS MONTH_NAME,
       ROUND(SUM(SALES),2) AS TOTAL_SALES FROM SALES
       GROUP BY 1,2,3
       ORDER BY YEAR(ORDER_DATE),MONTH_NO,TOTAL_SALES DESC;                  -- FOR BETTER UNDERSTANDING WE WILL ORDER BY YEAR,MONTH --
       
#What is the average sales in each of the region in 2017?
SELECT REGION,ROUND(AVG(SALES),2) AS AVG_SALES FROM SALES
       WHERE YEAR(ORDER_DATE)=2017
       GROUP BY REGION
       ORDER BY AVG_SALES DESC;

#Which states had the maximum and minimum sales in 2016?
(SELECT STATE,ROUND(SUM(SALES),2) AS SALES FROM SALES WHERE YEAR(ORDER_DATE)=2016  GROUP BY STATE ORDER BY SUM(SALES) DESC LIMIT 1)
UNION
(SELECT STATE,SUM(SALES) AS SALES FROM SALES WHERE YEAR(ORDER_DATE)=2016  GROUP BY STATE ORDER BY SUM(SALES) ASC LIMIT 1);


#What is the total sales and profit in each of the regions in 2015?
SELECT REGION,ROUND(SUM(SALES),2) AS TOTAL_SALES,ROUND(SUM(PROFIT),2) AS PROFIT FROM SALES 
       WHERE YEAR(ORDER_DATE)=2015
       GROUP BY REGION
       ORDER BY TOTAL_SALES,PROFIT DESC;

#DAILY REPORT
SELECT DATE(ORDER_DATE) AS DAY,    -- EXTRACTING DAY FROM DATE --
       SUM(SALES) FROM SALES
       GROUP BY DAY
       ORDER BY DAY;

#weekly
SELECT YEAR(ORDER_DATE) AS YEAR,          -- EXTRACTING DAY FROM DATE --
	   WEEK(ORDER_DATE,1) AS WEEKLY,
       FLOOR(SUM(SALES)) AS TOTAL_SALES FROM SALES 
       GROUP BY YEAR,WEEKLY
       ORDER BY YEAR,WEEKLY;
       
#Monthly
SELECT YEAR(ORDER_DATE) AS YEAR,          
	   MONTH(ORDER_DATE) AS MONTH,
       FLOOR(SUM(SALES)) AS TOTAL_SALES FROM SALES 
       GROUP BY YEAR,MONTH
       ORDER BY YEAR,MONTH;
       
#quarterly
SELECT YEAR(ORDER_DATE) AS YEAR,          
	   QUARTER(ORDER_DATE) AS QUARTER,
       FLOOR(SUM(SALES)) AS TOTAL_SALES FROM SALES 
       GROUP BY YEAR,QUARTER
       ORDER BY YEAR,QUARTER;
       
#yearly
SELECT YEAR(ORDER_DATE) AS YEAR,          
       FLOOR(SUM(SALES)) AS TOTAL_SALES FROM SALES 
       GROUP BY YEAR
       ORDER BY YEAR;
       
#yoy growth  
--    DOUBT   -- 
SELECT YEAR(ORDER_DATE),FLOOR(SUM(SALES)) AS TOTAL_SALES,
	   LAG(TOTAL_SALES,1) OVER (PARTITION BY YEAR(ORDER_DATE))
	   FROM SALES
       GROUP BY YEAR(ORDER_DATE);
SELECT 
    ORDER_DATE,
    SALES,
    YEAR(ORDER_DATE) AS SALES_YEAR,
    LAG(SALES, 1) OVER (PARTITION BY YEAR(ORDER_DATE) ORDER BY ORDER_DATE) AS PREV_SALE
FROM sales;
       
#-7 days report 
SELECT DATE(ORDER_DATE) AS YEAR,SUM(SALES) FROM SALES
       WHERE ORDER_DATE>=curdate()-INTERVAL 7 DAY       -- CURRENT DATE MINUS DATE OF 7 DAYS BEFORE --
       GROUP BY YEAR;
       
#Between dates
SELECT DATE(ORDER_DATE) AS YEAR,FLOOR(SUM(SALES)) AS TOTAL_SALES FROM SALES
       WHERE ORDER_DATE BETWEEN DATE('2014-01-14')AND DATE('2014-01-20')     
       GROUP BY YEAR;
       
       
#3 months sales 2016,3,4,5
SELECT YEAR(ORDER_DATE) AS YEAR,
       MONTH(ORDER_DATE) AS MONTH_NO,
       MONTHNAME(ORDER_DATE) AS MONTH_NAME,
       ROUND(SUM(SALES),2) AS TOTAL_SALES
       FROM SALES
       WHERE MONTH(ORDER_DATE) IN(3,4,5) AND YEAR(ORDER_DATE)=2016
       GROUP BY YEAR(ORDER_DATE),MONTH(ORDER_DATE),MONTHNAME(ORDER_DATE)
       ORDER BY TOTAL_SALES;

SELECT YEAR(ORDER_DATE) AS YEAR,
       MONTH(ORDER_DATE) AS MONTH_NO FROM SALES;
