USE foodapp;

#################################### Queries Analysis #######################################

#1
-- Orders and their information made per User between 2021-01-01 and 2021-12-31
#Interpretation of the Explain Command:
 # We have 5 rows due to the 5 tables used
 # For joined tables "supermarket", "users", "order_items" and "contact" we only have to query through one row, since we used an index to join them
 # We were not able to use a index for the filtering but since the order dates have a high cardinality we decided that it doesn't make sense to add an extra index for that field
 # All the queries but the first one use an index (see key column). For the first one it was not possible due to the date filter.
 # Timing (as measured at client side): 0:00:0.0000000
 # Timing (as measured by the server):
 # Execution 0:00:0.00146560
 # Table lock wait time: 0:00:0.00005800

#What did we do to optimize the query?
 # We made sure to join using foreign keys (user_id, supermarket_id, contact_id, order_id), so that we don't have to query through many rows
 # We defined the indexes as datatype "int" which makes sure that they get found fast
 
SELECT
	CONCAT(c.First_Name, ' ', c.Last_Name) AS 'Name',
	COUNT(o.user_id) AS 'Number of Orders',
	GROUP_CONCAT(DISTINCT(s.supermarket_name)) AS 'Supermarkets', 
	GROUP_CONCAT(oi.Super_Item_ID) AS 'All items per Client',
	GROUP_CONCAT(' ', DATE(o.order_date), ' ') AS 'Date of Orders'
FROM
	orders o,
    users u,
    contact c, 
    order_items oi,
    supermarkets s
WHERE o.user_id = u.user_id
AND s.supermarket_id = o.supermarket_id
AND u.contact_id = c.contact_id
AND oi.order_id = o.order_id
AND DATE(o.Order_Date) > DATE('2021-01-01')
AND DATE(o.Order_Date) < DATE('2021-12-31')
GROUP BY o.user_id;

#2

-- Top Clients by Monetary 
-- Which clients are the 'best' when analysing the total spent on the app

#Interpretation of the Explain Command:
 # We have 4 rows due to the 4 tables used
 # For joined tables "contact", "users" and "payments" we only have to query through one row, since we used an index to join them
 # For the orders table we had to query trough all the rows, as we used the o.user_id in order to group the results of the query
 # All of the queries have an index signified by the key column
 # Timing (as measured at client side): 0:00:0.01600000
 # Timing (as measured by the server): 
 # Execution 0:00:0.01067890
 # Table lock wait time: 0:00:0.00017900

#What did we do to optimize the query?
 # We made sure to join using foreign keys (user_id, contact_id, order_id), so that we don't have to query through many rows
 # We defined the indexes as datatype "int" which makes sure that they get found fast
 # We didn't have to use a filter-command so there was no optimization possibility
 
SELECT
	o.User_ID,
    concat(c.First_Name, ' ', Last_Name) Name,
    SUM(p.Total+p.Fee) TotalSpent
FROM
	orders o,
    payments p,
    users u,
    contact c
WHERE p.Order_ID = o.Order_ID
AND u.User_ID = o.User_ID
AND c.Contact_ID = u.Contact_ID
GROUP BY User_ID
ORDER BY TotalSpent DESC
LIMIT 3;

-- Top Clients by Frequency
-- Which clients are the 'best' when analysing how often do they order
SELECT
	o.User_ID,
	CONCAT(c.First_Name, ' ', c.Last_Name) 'Name',
	COUNT(o.User_ID) 'Number of Orders'
FROM
	orders o,
	users u,
    contact c
WHERE o.User_ID = u.User_ID
AND c.Contact_ID = u.Contact_ID
GROUP BY o.User_ID
ORDER BY COUNT(o.User_ID) DESC
LIMIT 3;

-- Top Items by Frequency
-- Which items are the 'best' when analysing how often are they ordered
SELECT
    i.item_id,
    i.item_name,
    sum(oi.quantity) 'Total_Amount'
FROM order_items oi
JOIN supermarket_items si ON si.super_item_id = oi.super_item_id
JOIN items i ON i.item_id = si.item_id
GROUP BY i.item_id
ORDER BY Total_Amount DESC
LIMIT 3;

-- Top Items by Total Monetary Value spent on them 
-- Which items are the 'best' when analysing the total
SELECT
    sum(oi.quantity) 'Quantity',
    concat(i.item_name, '-', i.item_brand) AS 'Item',
    round(sum(oi.quantity) * si.item_price, 2) 'Total_per_Item_€'
FROM supermarket_items si
JOIN items i ON i.item_id = si.item_id
JOIN order_items oi ON oi.super_item_id = si.super_item_id
GROUP BY i.item_id
ORDER BY Total_per_Item_€ DESC
LIMIT 3;




#3.  the average amount of sales/bookings/rents/deliveries for a period that involves 2 or more
#years, as in the following example
-- Average amount of sales per period

#Interpretation of the Explain Command:
 # We have 2 rows due to the 2 tables used
 # For the joined table "payments" we only have to query through one row, since we used an index to join
 # For the orders table we had to query trough all the rows, as we used the o.user_id as we needed to filter by the date field

#What did we do to optimize the query?
 # We made sure to join using foreign keys (order_id), so that we don't have to query through many rows
 # We defined the indexes as datatype "int" which makes sure that they get found fast
 # We didn't have to used the date to filter, which has a high cardinality
 # Timing (as measured at client side): 0:00:0.000000000
 # Timing (as measured by the server): 
 # Execution 0:00:0.000095640
 # Table lock wait time: 0:00:0.00000600

SELECT
	('2020-10-15 - 2022-10-15') AS 'PeriodsOfSales', 
	SUM(p.total+p.fee) AS 'Total Sales',
	SUM(p.total+p.fee)/TIMESTAMPDIFF(year,'2020-10-15', '2022-10-15') AS 'Yearly Average',
	SUM(p.total+p.fee)/TIMESTAMPDIFF(month,'2020-10-15', '2022-10-15') AS 'Monthly Average'
FROM 
	payments p,
	orders o
WHERE p.order_id = o.order_id
AND o.order_date > DATE('2020-10-15')
AND o.order_date < DATE('2022-10-15');

#4
-- Totals Orders and Total Spent by Location
-- Based on the First 4 Digit of the Postal Code as our app is only available in 
-- one city and one country 

#Interpretation of the Explain Command:
 # We have 6 rows due to the 6 tables used
 # For joined tables "contact", "Location" "postal_codes", "users" and "payments" we only have to query through one row, since we used an index to join them
 # For the orders table we had to query trough all the rows, since we grouped the results of the query
 # All of the queries have an index signified by the key column

#What did we do to optimize the query?
 # We made sure to join using foreign keys (user_id, contact_id, order_id, location_id, postal_codes_id), so that we don't have to query through many rows
 # We defined the indexes as datatype "int" which makes sure that they get found fast
 # We didn't have to use a filter-command so there was no optimization possibility on the filter side
 
  # Timing (as measured at client side): 0:00:0.000000000
 # Timing (as measured by the server): 
 # Execution 0:00:0.00182450
 # Table lock wait time: 0:00:0.00008100
 
SELECT 
	(SUBSTRING(pc.Postal_Code,1,4)) AS '4-digit', 
	count(o.Order_ID) AS 'Total Orders',
	SUM(p.Total+p.fee) AS 'Total_Spent',
	SUM(p.fee) AS 'Total Fee'
FROM
	Location l,
    Contact c, 
    users u, 
    orders o, 
    payments p, 
    postal_codes pc
WHERE c.Location_ID = l.Location_ID
AND p.order_id = o.order_id
AND c.contact_id = u.contact_id
AND o.user_id = u.user_id
AND l.postal_code_id = pc.postal_code_id
GROUP BY (SUBSTRING(pc.Postal_Code,1,4))
ORDER BY Total_Spent DESC
LIMIT 5;

#5
#Interpretation of the Explain Command:
 # We have 7 rows in the result grid due to the 7 tables used
 # For joined tables "postal_codes", "Location",  "contact", "users" and "orders" we only have to query through one row, since we used an index to join them
 # For the reviews table we had to query trough all the rows, since we grouped the results of the location to take the average review
 # For the "city" we had to query through two rows, to get to the right value.
 # All of the queries have an index signified by the key column

#What did we do to optimize the query?
 # We made sure to join using foreign keys (user_id, contact_id, order_id, location_id, postal_codes_id, city_id), so that we don't have to query through many rows
 # We defined the indexes as datatype "int" which makes sure that they get found fast
 # We didn't have to use a filter-command so there was no optimization possibility on the filter side
 
# Timing (as measured at client side): 0:00:0.000000000
 # Timing (as measured by the server): 
 # Execution 0:00:0.00149920
 # Table lock wait time: 0:00:0.0000800

-- User-locations with order rating
SELECT
	l.Location_ID, 
    l.Street_Name, 
    l.House_NR, 
    pc.Postal_Code, 
    ci.city_name,
    avg(r.rating) 'Average Rating'
FROM
	orders o, 
    reviews r, 
    users u, 
    contact c, 
    location l, 
    city ci,
    postal_codes pc
WHERE o.User_ID = u.User_ID
AND o.Order_ID = r.Order_ID
AND u.Contact_ID = c.Contact_ID
AND c.Location_ID = l.Location_ID
AND l.Postal_Code_ID = pc.Postal_Code_ID
AND ci.City_ID = pc.City_ID
GROUP BY l.Location_ID;

-- Restaurant-locations with order rating
SELECT
	l.Location_ID, 
    l.Street_Name, 
    l.House_NR, 
    pc.Postal_Code, 
    ci.city_name,
    s.supermarket_id,
    s.supermarket_name,
    avg(r.rating) 'Average Rating'
FROM
	orders o, 
    reviews r, 
    supermarkets s, 
    location l, 
    city ci,
    postal_codes pc
WHERE o.Supermarket_ID = s.Supermarket_ID
AND o.Order_ID = r.Order_ID
AND s.Location_ID = l.Location_ID
AND l.Postal_Code_ID = pc.Postal_Code_ID
AND ci.City_ID = pc.City_ID
GROUP BY l.Location_ID;

#################################### Views #######################################

-- View (invoice header & total)
CREATE OR REPLACE VIEW InvoiceHeader AS
SELECT 
    o.Order_ID Invoice_Number,
    o.Order_Date Date_of_Issue,
    CONCAT(c.First_Name,' ',c.last_name) Client_Name,
    l.Street_Name,
    pc.Postal_Code,
    ci.City_Name,
    co.Country_Name,
    'Market Inc.' Company_Name,
    'Rua Mesquita 99' Company_Street,
    '1070238' Company_Postalcode,
    'market@mail.com' Company_Email,
    '123-456-789' Company_Phone,
    round(p.Total/(1-pro.Discount), 2) TotalBeforeDiscount,
    CONCAT(round(pro.Discount*100), '%') DiscountGranted,
    round((p.Total/(1-pro.Discount))-p.total, 2) Discount,
    p.Total Total
FROM orders o
JOIN users u ON u.User_ID = o.User_ID
JOIN contact c ON c.Contact_ID = u.Contact_ID
JOIN location l ON l.Location_ID = c.Location_ID
JOIN postal_codes pc ON pc.Postal_Code_ID = l.Postal_Code_ID
JOIN city ci ON ci.City_ID = pc.City_ID
JOIN country co ON co.Country_ID = ci.Country_ID
JOIN payments p ON p.Order_ID = o.Order_ID
LEFT JOIN promotions pro ON pro.Promo_Code = o.Promo_Code;

-- View (details)
CREATE OR REPLACE VIEW InvoiceDetails AS
SELECT oi.Order_ID, i.Item_Name, CONCAT(si.Item_Price,' €') Item_Price, oi.Quantity, CONCAT(ROUND((si.Item_Price * oi.Quantity),2),' €') Amount
FROM supermarket_items si, items i, order_items oi
WHERE oi.Super_Item_ID = si.Super_Item_ID
AND si.Item_ID = i.Item_ID
ORDER BY oi.Order_ID;


###########################
#Example for Invoice Header (Order 2)
select * from invoiceheader where invoice_number = 2;

#Example for Invoice Details (Order 2) 
select * from invoicedetails where Order_ID = 2;





