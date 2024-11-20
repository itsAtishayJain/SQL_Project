/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

## Answer 1.

SELECT 
  customer_id,
  CONCAT(CASE 
			WHEN Customer_gender = 'M' THEN 'Mr' ELSE 'Ms' END, ' ', UPPER(customer_FName), ' ', UPPER(customer_LName)) AS customer_full_name,
			customer_email,
			EXTRACT(YEAR FROM customer_creation_date) AS customer_creation_year,
  CASE 
    WHEN EXTRACT(YEAR FROM customer_creation_date) < 2005 THEN 'A'
    WHEN EXTRACT(YEAR FROM customer_creation_date) >= 2005 AND EXTRACT(YEAR FROM customer_creation_date) < 2011 THEN 'B'
    ELSE 'C'
  END AS category
FROM 
  online_customer;
  
  
/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
## Answer 2.

SELECT p.product_id, p.product_desc, p.product_quantity_avail, p.product_price,
       (p.product_quantity_avail * p.product_price) AS inventory_value,
       CASE
           WHEN p.product_price > 20000 THEN (p.product_price * 0.8)
           WHEN p.product_price > 10000 THEN (p.product_price * 0.85)
           ELSE (p.product_price * 0.9)
       END AS new_price
FROM product p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
ORDER BY inventory_value DESC;

/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.

SELECT pc.product_class_code, pc.product_class_desc,
       COUNT(p.product_id) AS product_type_count,
       SUM(p.product_quantity_avail * p.product_price) AS inventory_value
FROM product_class pc
JOIN product p ON pc.product_class_code = p.product_class_code
GROUP BY pc.product_class_code, pc.product_class_desc
HAVING inventory_value > 100000
ORDER BY inventory_value DESC;

/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.

SELECT
    OC.customer_id, CONCAT(OC.customer_FName, ' ', OC.Customer_LName) AS full_name, OC.customer_email, OC.customer_phone,
    A.country
FROM
    ONLINE_CUSTOMER OC
INNER JOIN
    ADDRESS A ON OC.address_id = A.address_id
WHERE
    OC.customer_id IN (
        SELECT
            OH.customer_id
        FROM
            ORDER_HEADER OH
        WHERE
            OH.order_status = 'Cancelled'
        GROUP BY
            OH.customer_id
        HAVING
            COUNT(*) = (
                SELECT
                    COUNT(*)
                FROM
                    ORDER_HEADER
                WHERE
                    customer_id = OH.customer_id
            )
    );


/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  

SELECT
  S.Shipper_Name, A.City,
  COUNT(DISTINCT OC.Customer_ID) AS Num_Customers,
  COUNT(OH.Order_ID) AS Num_Consignments
FROM
  SHIPPER AS S
  JOIN ORDER_HEADER AS OH ON OH.Shipper_ID = S.Shipper_ID
  JOIN ONLINE_CUSTOMER AS OC ON OC.Customer_ID = OH.Customer_ID
  JOIN ADDRESS AS A ON A.Address_ID = OC.Address_ID
WHERE
  S.Shipper_Name = 'DHL'
GROUP BY
  S.Shipper_Name, A.City;

/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.

SELECT p.product_id, p.product_desc, p.product_quantity_avail, oi.quantity_sold,
    CASE
        WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') THEN
            CASE
                WHEN oi.quantity_sold = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < 0.1 * oi.quantity_sold THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < 0.5 * oi.quantity_sold THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        WHEN pc.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
            CASE
                WHEN oi.quantity_sold = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < 0.2 * oi.quantity_sold THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < 0.6 * oi.quantity_sold THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        ELSE
            CASE
                WHEN oi.quantity_sold = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < 0.3 * oi.quantity_sold THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < 0.7 * oi.quantity_sold THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
    END AS inventory_status
FROM PRODUCT p
INNER JOIN PRODUCT_CLASS pc ON p.product_class_code = pc.product_class_code
INNER JOIN (
    SELECT product_id, SUM(PRODUCT_QUANTITY) AS quantity_sold
    FROM ORDER_ITEMS
    GROUP BY product_id
) oi ON p.product_id = oi.product_id;

/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.

SELECT
  OI.order_id,
  SUM(P.PRODUCT_QUANTITY_AVAIL) AS order_volume
FROM
  CARTON C
  JOIN ORDER_ITEMS OI ON C.carton_id = OI.PRODUCT_QUANTITY
  JOIN PRODUCT P ON OI.product_id = P.product_id
WHERE
  C.carton_id = 10
GROUP BY
  OI.order_id
HAVING
  SUM(P.PRODUCT_QUANTITY_AVAIL) <= (SELECT carton_id FROM CARTON WHERE carton_id = 10)
ORDER BY
  order_volume DESC
LIMIT
  1;

/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.

SELECT 
    oc.customer_id,
    CONCAT(oc.Customer_Fname, ' ', oc.Customer_LName) AS customer_full_name,
    SUM(oi.PRODUCT_QUANTITY) AS total_quantity,
    SUM(oi.PRODUCT_QUANTITY * p.PRODUCT_PRICE) AS total_value_shipped
FROM 
    ONLINE_CUSTOMER oc
    JOIN ORDER_HEADER oh ON oc.customer_id = oh.customer_id
    JOIN ORDER_ITEMS oi ON oh.order_id = oi.order_id
    JOIN PRODUCT p ON oi.product_id = p.product_id
WHERE 
    oh.PAYMENT_MODE = 'Cash'
    AND oc.CUSTOMER_LNAME LIKE 'G%'
GROUP BY 
    oc.customer_id, oc.Customer_Fname, oc.Customer_LName

/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.

SELECT
  p.product_id, p.product_desc,
  SUM(oi.product_quantity) AS total_quantity
FROM
  ORDER_ITEMS oi
JOIN PRODUCT p ON oi.product_id = p.product_id
JOIN ORDER_HEADER oh ON oi.order_id = oh.order_id
JOIN ONLINE_CUSTOMER oc ON oh.customer_id = oc.customer_id
JOIN ADDRESS a ON oc.address_id = a.address_id
WHERE
  oi.order_id IN (
    SELECT
      oi2.order_id
    FROM
      ORDER_ITEMS oi2
    WHERE
      oi2.product_id = 201
  )
  AND a.city NOT IN ('Bangalore', 'New Delhi')
GROUP BY
  p.product_id, p.product_desc
ORDER BY
  total_quantity DESC;

/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */
 
## Answer 10.

SELECT OH.order_id, OH.customer_id,
       CONCAT(oc.Customer_Fname, ' ', oc.Customer_LName) AS customer_full_name,
       SUM(OI.PRODUCT_QUANTITY) AS total_quantity
FROM ORDER_HEADER OH
JOIN ONLINE_CUSTOMER OC ON OH.customer_id = OC.customer_id
JOIN ORDER_ITEMS OI ON OH.order_id = OI.order_id
JOIN ADDRESS A ON OH.SHIPPER_ID = A.address_id
WHERE OH.order_id % 2 = 0
  AND A.pincode LIKE '5%'
GROUP BY OH.order_id, OH.customer_id, customer_full_name
HAVING total_quantity > 0
LIMIT 15;
