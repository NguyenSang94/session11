CREATE TABLE accounts
(
    account_id    SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    balance       NUMERIC(12, 2)
);

CREATE TABLE transactions
(
    trans_id   SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts (account_id),
    amount     NUMERIC(12, 2),
    trans_type VARCHAR(20), -- 'WITHDRAW' hoặc 'DEPOSIT'
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO accounts (customer_name, balance)
VALUES ('Nguyen Van A', 1000.00);

BEGIN;

-- 1. Khóa dòng để tránh race condition
SELECT balance FROM accounts
WHERE account_id = 1 FOR UPDATE;

-- 2. Kiểm tra số dư
DO $$
    DECLARE
        curr_balance NUMERIC(12,2);
    BEGIN
        SELECT balance INTO curr_balance FROM accounts WHERE account_id = 1;

        IF curr_balance < 300 THEN
            RAISE EXCEPTION 'Không đủ tiền trong tài khoản';
        END IF;
    END $$;

-- 3. Trừ số dư
UPDATE accounts
SET balance = balance - 300
WHERE account_id = 1;

-- 4. Ghi log giao dịch
INSERT INTO transactions (account_id, amount, trans_type)
VALUES (1, 300, 'WITHDRAW');

COMMIT;

SELECT * FROM accounts;
SELECT * FROM transactions;
