-- Create database tables (code provided by professor)
DROP TABLE sales;
DROP TABLE retractions;
DROP TABLE bids;
DROP TABLE promotions;
DROP TABLE itemCategory;
DROP TABLE categories;
DROP TABLE items;
DROP TABLE buyers;
DROP TABLE sellers;
DROP TABLE users;

CREATE TABLE users 
(     	userID 		NUMBER 
                    CONSTRAINT pk_users PRIMARY KEY, -- uses user_id sequence number
       	email 		VARCHAR2(50),
        lname 		VARCHAR2(20),
       	fname 		VARCHAR2(25),
       	street 		VARCHAR2(50),
        city  		VARCHAR2(25),
       	state 		VARCHAR2(2),
        zip 		VARCHAR2(10),
     	status 		CHAR(1)		-- 'G' or 'B'
);

CREATE TABLE sellers 
(	userID		     NUMBER 
                     CONSTRAINT fk_sellers REFERENCES users(userID) ON DELETE CASCADE,
	creditCardType 	 VARCHAR2(10),
	creditCardNumber VARCHAR2(16),
	expiration 	     VARCHAR2(6),
	bank 	 	     VARCHAR2(20),
	accountNo 	     VARCHAR2(25),
    CONSTRAINT pk_sellers PRIMARY KEY (userID) 
);

create table buyers 
(   	userID 		    NUMBER 
                        CONSTRAINT fk_buyers REFERENCES users(userID) ON DELETE CASCADE,
        maxBidAmount 	NUMBER, 
		CONSTRAINT pk_buyers PRIMARY KEY (userID)
);

CREATE TABLE items 
(	    itemID 		    NUMBER
                        CONSTRAINT pk_items PRIMARY KEY, -- uses item_id sequence number
        name 		    VARCHAR2(50),
        description 	VARCHAR2(64),
        openingPrice 	NUMBER(9,2),
        increase 	    NUMBER(9,2),
        startingTime 	DATE,
        endingTime 	    DATE,
        featured 	    CHAR(1),	-- 'Y' or 'N'
        userID 		    NUMBER 
                        CONSTRAINT fk_items REFERENCES sellers(userID) ON DELETE CASCADE 
);

CREATE TABLE categories 
(	cID 	    	NUMBER 
                    CONSTRAINT pk_categories PRIMARY KEY, -- uses category_id number
	name    	    VARCHAR2(20),
	description 	VARCHAR2(128)
);

CREATE TABLE itemCategory 
(	cID 		NUMBER 
                CONSTRAINT fk_itemcategory_cID REFERENCES categories(cID) ON DELETE CASCADE,
	itemID 		NUMBER 
                CONSTRAINT fk_itemcategory_itemID REFERENCES items(itemID) ON DELETE CASCADE, 
    CONSTRAINT pk_itemcategory PRIMARY KEY (cID, itemID)
);

CREATE TABLE promotions 
(	itemID 		    NUMBER 
                    CONSTRAINT fk_promotions REFERENCES items(itemID) ON DELETE CASCADE,
	startingTime 	DATE,
	endingTime   	DATE,
	salePrice	    NUMBER(9,2),
    CONSTRAINT pk_promotions PRIMARY KEY (itemID,startingTime)
);

CREATE TABLE bids 
(	userID 		NUMBER 
                CONSTRAINT  fk_bids_userID REFERENCES buyers(userID) ON DELETE CASCADE,
	itemID 		NUMBER 
                CONSTRAINT fk_bids_itemID REFERENCES items(itemID) ON DELETE CASCADE,
    price 		NUMBER(9,2),
	timestamp 	DATE,
    CONSTRAINT pk_bids PRIMARY KEY (userID, itemID, price)
); 

CREATE TABLE retractions 
( 	retractionTimestamp  DATE,
	userID 		NUMBER 
                CONSTRAINT fk_retractions_userID REFERENCES users(userID) ON DELETE CASCADE,
  	itemID 		NUMBER 
                CONSTRAINT fk_retractions_itemID REFERENCES items(itemID) ON DELETE CASCADE,
	reason 		VARCHAR2(128),
    CONSTRAINT pk_retractions PRIMARY KEY (retractionTimestamp, userId, itemID)
);

CREATE TABLE sales 
( 	itemID 		    NUMBER 
                    CONSTRAINT fk_sales_itemID REFERENCES items(itemID) ON DELETE CASCADE,
	sellerUserID 	NUMBER 
                    CONSTRAINT fk_sales_sellerUserID REFERENCES sellers(userID) ON DELETE CASCADE,
   	buyerUserID 	NUMBER 
                    CONSTRAINT fk_sales_buyerUserID REFERENCES buyers(userID) ON DELETE CASCADE,
   	price 		    NUMBER(9,2),
  	settlementdate 	DATE,
    CONSTRAINT pk_sales PRIMARY KEY (itemID)
);


-- Insert data into existing database tables using SQL Loader

-- Check data in database tables
SELECT COUNT(*) COUNT_USERS FROM users;
SELECT COUNT(*) COUNT_SELLERS FROM sellers;
SELECT COUNT(*) COUNT_BUYERS FROM buyers;
SELECT COUNT(*) COUNT_ITEMS FROM items;
SELECT COUNT(*) COUNT_CATEGORIES FROM categories;
SELECT COUNT(*) COUNT_ITEMCATEGORY FROM itemCategory;
SELECT COUNT(*) COUNT_PROMOTIONS FROM promotions;
SELECT COUNT(*) COUNT_BIDS FROM bids;
SELECT COUNT(*) COUNT_RETRACTIONS FROM retractions;
SELECT COUNT(*) COUNT_SALES FROM sales;


-- Create star schema
-- STEP1: drop tables
DROP TABLE bid_sales_fact;
DROP TABLE item_dim;
DROP TABLE seller_dim;
DROP TABLE buyer_dim;
DROP TABLE date_dim;

-- STEP2: create tables
CREATE TABLE item_dim 
(	item_id 		        NUMBER 
                            CONSTRAINT pk_item_dim PRIMARY KEY,
    item_name           	VARCHAR2(30)  NOT NULL UNIQUE ,
    category1 	            VARCHAR2(50)  NOT NULL,
    category2               VARCHAR2(50),
    category3               VARCHAR2(50),
    featured 	            CHAR(1)       NOT NULL,	-- 'Y' or 'N'
    opening_price         	NUMBER(9,2)   NOT NULL,
    opening_start_time   	DATE          NOT NULL,
    opening_end_time 	    DATE          NOT NULL,
    promotion_price         NUMBER(9,2),
    promotion_start_time   	DATE,
    promotion_end_time 	    DATE
);

CREATE TABLE seller_dim 
(	seller_user_id		    NUMBER 
                            CONSTRAINT pk_seller_dim PRIMARY KEY,
    seller_zip 		        VARCHAR2(10)  NOT NULL,
    seller_state 	        VARCHAR2(2)   NOT NULL, 
    seller_city  		    VARCHAR2(20)  NOT NULL,
    credit_card_type 	    VARCHAR2(10)  NOT NULL,
    bank 		            VARCHAR2(20)  NOT NULL,
    offered_item_amount     INTEGER       NOT NULL
);

CREATE TABLE buyer_dim 
(	buyer_user_id		    NUMBER 
                            CONSTRAINT pk_buyer_dim PRIMARY KEY,
    buyer_zip 		        VARCHAR2(10)  NOT NULL,
    buyer_state 	        VARCHAR2(2)   NOT NULL, 
    buyer_city  		    VARCHAR2(20)  NOT NULL,
    max_bid_amount          NUMBER(9,2)   NOT NULL
);

CREATE TABLE date_dim 
(	date_id		            NUMBER 
                            CONSTRAINT pk_date_dim PRIMARY KEY,
    year                    INTEGER       NOT NULL,
    month                   INTEGER       NOT NULL,
    day                     INTEGER       NOT NULL
);

CREATE TABLE bid_sales_fact 
(	bid_id		            NUMBER 
                            CONSTRAINT pk_bid_sales_fact PRIMARY KEY,                                                  
    price 	             	NUMBER(9,2)   NOT NULL,
    increase                NUMBER(9,2)   NOT NULL,
    retraction              CHAR(1)       NOT NULL,	-- 'Y' or 'N'
    sales                   CHAR(1)       NOT NULL,	-- 'Y' or 'N'   
    item_id 		        NUMBER
                            CONSTRAINT fk_item_id REFERENCES item_dim(item_id) ON DELETE CASCADE,
    seller_user_id		    NUMBER
                            CONSTRAINT fk_seller_user_id REFERENCES seller_dim(seller_user_id) ON DELETE CASCADE,
    buyer_user_id		    NUMBER
                            CONSTRAINT fk_buyer_user_id REFERENCES buyer_dim(buyer_user_id) ON DELETE CASCADE,
    date_id		            NUMBER
                            CONSTRAINT fk_date_id REFERENCES date_dim(date_id) ON DELETE CASCADE
); 

COMMIT;

-- STEP3: insert data





