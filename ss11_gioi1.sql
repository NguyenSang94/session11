CREATE TABLE products
(
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    stock        INT,
    price        NUMERIC(10, 2)
);

CREATE TABLE orders
(
    order_id      SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    total_amount  NUMERIC(10, 2),
    created_at    TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items
(
    order_item_id SERIAL PRIMARY KEY,
    order_id      INT REFERENCES orders (order_id),
    product_id    INT REFERENCES products (product_id),
    quantity      INT,
    subtotal      NUMERIC(10, 2)
);
INSERT INTO products (product_name, stock, price)
VALUES
    ('Product A', 10, 100.00),
    ('Product B', 5, 200.00),
    ('Product C', 3, 150.00);

BEGIN;

-- Kiểm tra tồn kho product 1
SELECT stock FROM products WHERE product_id = 1 FOR UPDATE;
-- Kiểm tra tồn kho product 2
SELECT stock FROM products WHERE product_id = 2 FOR UPDATE;

-- Nếu thiếu hàng, raise lỗi (để ROLLBACK)
DO $$
    DECLARE
        stock1 INT;
        stock2 INT;
    BEGIN
        SELECT stock INTO stock1 FROM products WHERE product_id = 1;
        SELECT stock INTO stock2 FROM products WHERE product_id = 2;

        IF stock1 < 2 THEN
            RAISE EXCEPTION 'Product 1 không đủ hàng';
        END IF;

        IF stock2 < 1 THEN
            RAISE EXCEPTION 'Product 2 không đủ hàng';
        END IF;
    END $$;

-- 1. Giảm tồn kho
UPDATE products
SET stock = stock - 2
WHERE product_id = 1;

UPDATE products
SET stock = stock - 1
WHERE product_id = 2;

-- 2. Tạo đơn hàng trong bảng orders
INSERT INTO orders (customer_name, total_amount)
VALUES ('Nguyen Van A', 0)
RETURNING order_id;

-- Giả sử trả về order_id = 1
-- Bạn sẽ thấy order_id sau khi chạy

-- 3. Thêm chi tiết đơn hàng
INSERT INTO order_items (order_id, product_id, quantity, subtotal)
VALUES
    ((SELECT MAX(order_id) FROM orders), 1, 2,
     (SELECT price * 2 FROM products WHERE product_id = 1)),
    ((SELECT MAX(order_id) FROM orders), 2, 1,
     (SELECT price FROM products WHERE product_id = 2));

-- 4. Tính tổng tiền
UPDATE orders
SET total_amount = (
    SELECT SUM(subtotal)
    FROM order_items
    WHERE order_id = orders.order_id
)
WHERE order_id = (SELECT MAX(order_id) FROM orders);

COMMIT;

SELECT * FROM products;
