-- Create star schema (Jessie)
-- Drop tables
DROP TABLE bid_sales_fact;
DROP TABLE time_dim;
DROP TABLE itemcategory_dim;
DROP TABLE category_dim;
DROP TABLE promotion_dim;
DROP TABLE item_dim;
DROP TABLE seller_dim;
DROP TABLE buyer_dim;

-- Create tables
CREATE TABLE buyer_dim 
(   buyer_userID 		NUMBER, 
    max_bid_amount 	    NUMBER, 
    email 		        VARCHAR2(50),
    lname 		        VARCHAR2(20),
    fname 	        	VARCHAR2(25),
    street 	        	VARCHAR2(50),
    city  	        	VARCHAR2(25),
    state 	        	VARCHAR2(2),
    zip 	        	VARCHAR2(10),
    status 	        	CHAR(1),		-- 'G' or 'B'
CONSTRAINT pk_buyer_dim PRIMARY KEY (buyer_userID)
);

CREATE TABLE seller_dim 
(   seller_userID		NUMBER, 
    credit_card_type 	VARCHAR2(10),             
	credit_card_number  VARCHAR2(16),
	expiration 	        VARCHAR2(6),
	bank 	 	        VARCHAR2(20),
	accountNo 	        VARCHAR2(25),
    email 		        VARCHAR2(50),
    lname 		        VARCHAR2(20),
    fname 	        	VARCHAR2(25),
    street 	        	VARCHAR2(50),
    city  	        	VARCHAR2(25),
    state 	        	VARCHAR2(2),
    zip 	        	VARCHAR2(10),
    status 	        	CHAR(1),		-- 'G' or 'B'
CONSTRAINT pk_seller_dim PRIMARY KEY (seller_userID) 
);

CREATE TABLE item_dim 
(	item_id 		    NUMBER, 
    item_name           VARCHAR2(50),
    item_description 	VARCHAR2(64),
    opening_price 	    NUMBER(9,2),
    increase 	        NUMBER(9,2),
    starting_time    	DATE,
    ending_time 	    DATE,
    featured 	        CHAR(1),	-- 'Y' or 'N'
CONSTRAINT pk_item_dim PRIMARY KEY (item_id) 
);

CREATE TABLE promotion_dim 
(	item_id 		            NUMBER,                  
	promotion_starting_time 	DATE,
	promotion_endingTime     	DATE,
	promotion_price	            NUMBER(9,2),
CONSTRAINT pk_promotion_dim PRIMARY KEY (item_id, promotion_starting_time),
CONSTRAINT fk_promotion_dim FOREIGN KEY (item_id) REFERENCES item_dim(item_id) ON DELETE CASCADE
);

CREATE TABLE category_dim 
(	cID 	    	NUMBER, 
	c_name    	    VARCHAR2(20),
	c_description 	VARCHAR2(128),
CONSTRAINT pk_category_dim PRIMARY KEY (cID)
);

CREATE TABLE itemcategory_dim 
(	cID 		NUMBER,               
	item_id 	NUMBER, 
CONSTRAINT pk_itemcategory_dim PRIMARY KEY (cID, item_id),
CONSTRAINT fk_itemcategory_dim_item_ID FOREIGN KEY (item_id) REFERENCES item_dim(item_id) ON DELETE CASCADE, 
CONSTRAINT fk_itemcategory_dim_cID FOREIGN KEY (cID) REFERENCES category_dim(cID) ON DELETE CASCADE
);

CREATE TABLE time_dim 
(	date_key        NUMBER, 
    full_date       DATE,     
    year            NUMBER,
    month           CHAR(3),
    day_in_month    NUMBER,
    day_name        VARCHAR2(10),
    weekday_flag    VARCHAR2(10),
CONSTRAINT pk_time_dim PRIMARY KEY (date_key)
);

CREATE TABLE bid_sales_fact 
(	bid_id		            NUMBER,                                                                           
    price 	             	NUMBER(9,2),
    sales_flag              CHAR(1),	-- 'Y' or 'N' 
    buyer_userid		    NUMBER,
    seller_userid		    NUMBER,
    item_id 		        NUMBER,
    date_key		        NUMBER,
CONSTRAINT pk_bid_sales_fact PRIMARY KEY (bid_id),
CONSTRAINT fk_fact_buyer_userid FOREIGN KEY (buyer_userid) REFERENCES buyer_dim(buyer_userid) ON DELETE CASCADE,
CONSTRAINT fk_fact_seller_userid FOREIGN KEY (seller_userid) REFERENCES seller_dim(seller_userid) ON DELETE CASCADE,
CONSTRAINT fk_fact_item_id FOREIGN KEY (item_id) REFERENCES item_dim(item_id) ON DELETE CASCADE,
CONSTRAINT fk_fact_date_key FOREIGN KEY (date_key) REFERENCES time_dim(date_key) ON DELETE CASCADE
); 

COMMIT;

-- Insert data
-- Dimension tables
INSERT INTO buyer_dim
(buyer_userID, max_bid_amount, email, lname, fname, street, city, state, zip, status)
(SELECT b.userid, b.maxBidAmount, u.email, u.lname, u.fname, u.street, u.city, u.state, u.zip, u.status
FROM buyers b LEFT OUTER JOIN users u
ON b.userid = u.userid);

INSERT INTO seller_dim 
(SELECT s.userID, s.creditCardType, s.creditCardNumber, s.expiration, s.bank, s.accountNo, 
        u.email, u.lname, u.fname, u.street, u.city, u.state, u.zip, u.status
FROM sellers s LEFT OUTER JOIN users u
ON s.userid = u.userid);

INSERT INTO item_dim
SELECT itemID, name, description, openingPrice, increase, startingTime, endingTime, featured
FROM items;

INSERT INTO promotion_dim
SELECT *
FROM promotions;

INSERT INTO category_dim 
SELECT *
FROM categories;

INSERT INTO itemcategory_dim 
SELECT *
FROM itemCategory;

-- Use SQL Loader to insert data into time_dim
-- Check bids and sales date period 
SELECT MIN(TIMESTAMP), MAX(TIMESTAMP)
FROM bids;

SELECT MIN(settlementdate), MAX(settlementdate)
FROM sales;
-- bids and sales date period: 201601-201607
-- Insert calendar date from 1/1/2005 to 12/31/2006 
-- DONE!

-- Fact table
-- Create a sequence bid_sales_fact_bid_id_seq
CREATE SEQUENCE bid_sales_fact_bid_id_seq
START WITH 1 NOCACHE;

-- Create a trigger to automatically create PK
CREATE OR REPLACE TRIGGER bid_sales_fact_bid_id_trg
BEFORE INSERT ON bid_sales_fact
FOR EACH ROW
BEGIN
IF :new.bid_id IS NULL THEN
    SELECT bid_sales_fact_bid_id_seq.NEXTVAL
    INTO :new.bid_id
    FROM DUAL;
END IF;
END;

-- Check if sales data is included in bids table
SELECT *
FROM sales
WHERE NOT EXISTS
(SELECT *
FROM bids b JOIN sales s
ON b.itemid = s.itemid
AND b.userid = s.buyeruserid
AND b.price = s.price
AND b.timestamp = s.settlementdate);
-- All sales data is included in the bids table

-- Insert data into fact table
INSERT INTO bid_sales_fact 
(price, buyer_userid, seller_userid, item_id, date_key, sales_flag)
(SELECT bid_price, buyer_userid, seller_userid, bid_item, date_key,
        DECODE (sales_price, NULL, 'N', 'Y')
FROM
(SELECT bid_price, buyer_userid, seller_userid, bid_item, date_key, s.price sales_price
FROM
(SELECT b.price bid_price, b.userid buyer_userid, i.userid seller_userid, b.itemid bid_item, t.date_key
FROM bids b, items i, time_dim t
WHERE b.itemid = i.itemid
AND b.timestamp = t.full_date) bid
LEFT OUTER JOIN sales s
ON (bid_item = s.itemid
AND bid_price = s.price)));

-- Check sales data in the bid_sales_fact
SELECT COUNT(sales_flag)
FROM bid_sales_fact
WHERE sales_flag = 'Y';

SELECT COUNT(*) FROM sales;
-- bid_sales_fact properly inserted with bids and sales data

-- Check all table
SELECT COUNT(*) COUNT_BID_SALES_FACT FROM bid_sales_fact;
SELECT COUNT(*) COUNT_TIME_DIM FROM time_dim;
SELECT COUNT(*) COUNT_ITEMCATEGORY_DIM FROM itemcategory_dim;
SELECT COUNT(*) COUNT_CATEGORY_DIM FROM category_dim;
SELECT COUNT(*) COUNT_PROMOTION_DIM FROM promotion_dim;
SELECT COUNT(*) COUNT_ITEM_DIM FROM item_dim;
SELECT COUNT(*) COUNT_SELLER_DIM FROM seller_dim;
SELECT COUNT(*) COUNT_BUYER_DIM FROM buyer_dim;

COMMIT;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-- Queries
-- 1. Find the seller user id and buy user id such that the buyer has bought at least one item from the seller 
-- but the buyer and seller are located in different states.
SELECT sf.seller_userid, sf.buyer_userid
FROM bid_sales_fact sf, buyer_dim bm, seller_dim sm
WHERE sf.sales_flag = 'Y'
AND sf.buyer_userid = bm.buyer_userid
AND sf.seller_userid = sm.seller_userid
AND bm.state <> sm.state;

-- 2. Find item name along with the seller id and buyer id such that the seller has sold the item to the buyer.
SELECT i.item_name, s.seller_userid, s.buyer_userid
FROM bid_sales_fact s, item_dim i
WHERE s.sales_flag = 'Y'
AND s.item_id = i.item_id;

-- 3. For each seller and each item sold by the seller, find the total amount sold.
SELECT seller_userid, item_id, SUM(price)
FROM bid_sales_fact
WHERE sales_flag = 'Y'
GROUP BY ROLLUP (seller_userid, item_id);

-- 4. Find the top seller.
WITH salse_fact AS
(SELECT * 
FROM bid_sales_fact
WHERE  sales_flag = 'Y')
SELECT seller_userid
FROM salse_fact
GROUP BY seller_userid
HAVING COUNT(bid_id) = 
(SELECT MAX(COUNT(bid_id))
FROM salse_fact
GROUP BY seller_userid);

-- 5. Find the top buyer.
WITH salse_fact AS
(SELECT * 
FROM bid_sales_fact
WHERE  sales_flag = 'Y')
SELECT buyer_userid
FROM salse_fact
GROUP BY buyer_userid
HAVING COUNT(bid_id) = 
(SELECT MAX(COUNT(bid_id))
FROM salse_fact
GROUP BY buyer_userid);





