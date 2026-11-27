1. Find the total number of orders placed by each customer.
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id,
    c.name; 
------------------------------------------
2. Retrieve customers who have placed more orders than the average number of orders per customer.
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id,
    c.name
HAVING COUNT(o.order_id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT 
            COUNT(o2.order_id) AS order_count
        FROM Customers c2
        LEFT JOIN Orders o2
            ON c2.customer_id = o2.customer_id
        GROUP BY c2.customer_id
    ) AS AverageOrders
);
------------------------------------------
3. Create an index on the customer_id column in the Orders table.\
CREATE INDEX idx_customer_id
ON Orders(customer_id);
------------------------------------------
4. Write a transaction to:
- Insert a new order.
- Insert corresponding order items.
- Ensure that if any step fails, all changes are rolled back.
BEGIN TRY
    BEGIN TRANSACTION;

    -- Insert a new order
    INSERT INTO Orders (
        order_id,
        customer_id,
        order_date,
        total_amount
    )
    VALUES (
        101,
        1,
        GETDATE(),
        150.00
    );

    -- Insert the corresponding order items
    INSERT INTO Order_Items (
        item_id,
        order_id,
        product_name,
        quantity,
        price
    )
    VALUES
        (1, 101, 'Laptop', 1, 100.00),
        (2, 101, 'Mouse', 2, 25.00);

    -- Commit the transaction
    COMMIT TRANSACTION;

END TRY

BEGIN CATCH
    -- Rollback if an error occurs
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();
END CATCH;
--------------------------------------------------
5. Explain: What are ACID properties?
ACID is a set of four important properties that ensure reliable database transactions.
Property	Explanation
Atomicity	A transaction is treated as one complete unit. Either all operations succeed or none of them are applied.
Consistency	A transaction must maintain the database rules and constraints, keeping the database in a valid state.
Isolation	Multiple transactions can run simultaneously without interfering with each other.
Durability	Once a transaction is committed, its changes are permanently saved, even if a system failure occurs.

Conclusion: ACID properties ensure that database transactions are reliable, accurate, and secure.
--------------------------------------------------
Q2) Using SQL Window Functions
A. From the demand table, find the cumulative total sum for qty.
SQL Query:
SELECT
    day,
    qty,
    SUM(qty) OVER (
        ORDER BY day
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS cumQty
FROM demand;
------------------------------------------------
Expected Output:
day	qty	cumQty
1	10	10
2	6	16
3	21	37
4	9	46
6	12	58
7	18	76
8	3	79
9	6	85
10	23	108