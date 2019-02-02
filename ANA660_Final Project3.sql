-- Project Week4
DROP INDEX bid_sales_fact_ind1;
DROP INDEX bid_sales_fact_ind2;
DROP INDEX seller_dim_state_ind;
DROP INDEX buyer_dim_state_ind;

-- Queries
-- 1. Find the seller user id and buy user id such that the buyer has bought at least one item from the seller 
-- but the buyer and seller are located in different states.
CREATE INDEX bid_sales_fact_ind1 ON bid_sales_fact (sales_flag, seller_userid, buyer_userid, item_id);
CREATE INDEX seller_dim_state_ind ON seller_dim (state);
CREATE INDEX buyer_dim_state_ind ON buyer_dim (state);

ANALYZE TABLE bid_sales_fact COMPUTE STATISTICS
ANALYZE TABLE buyer_dim COMPUTE STATISTICS
ANALYZE TABLE seller_dim COMPUTE STATISTICS

EXPLAIN PLAN FOR
SELECT sf.seller_userid, sf.buyer_userid
FROM bid_sales_fact sf, buyer_dim bm, seller_dim sm
WHERE sf.sales_flag = 'Y'
AND sf.buyer_userid = bm.buyer_userid
AND sf.seller_userid = sm.seller_userid
AND bm.state <> sm.state;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 2. Find item name along with the seller id and buyer id such that the seller has sold the item to the buyer.
ANALYZE TABLE bid_sales_fact COMPUTE STATISTICS
ANALYZE TABLE item_dim COMPUTE STATISTICS

EXPLAIN PLAN FOR
SELECT i.item_name, s.seller_userid, s.buyer_userid
FROM bid_sales_fact s, item_dim i
WHERE s.sales_flag = 'Y'
AND s.item_id = i.item_id;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 3. For each seller and each item sold by the seller, find the total amount sold.
CREATE INDEX bid_sales_fact_ind2 ON bid_sales_fact (sales_flag, seller_userid, item_id, price); 

ANALYZE TABLE bid_sales_fact COMPUTE STATISTICS

EXPLAIN PLAN FOR
SELECT seller_userid, item_id, SUM(price)
FROM bid_sales_fact
WHERE sales_flag = 'Y'
GROUP BY ROLLUP (seller_userid, item_id);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 4. Find the top seller.
ANALYZE TABLE bid_sales_fact COMPUTE STATISTICS

EXPLAIN PLAN FOR
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

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 5. Find the top buyer.
ANALYZE TABLE bid_sales_fact COMPUTE STATISTICS

EXPLAIN PLAN FOR
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

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);



