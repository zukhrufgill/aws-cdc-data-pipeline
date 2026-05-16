-- ============================================
-- RDS Source Table Definitions
-- ============================================

-- Orders table (production OLTP source)
CREATE TABLE public.orders (
    id SERIAL PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2),
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Sample data inserts
INSERT INTO public.orders (customer_id, amount, status) VALUES (101, 250.00, 'placed');
INSERT INTO public.orders (customer_id, amount, status) VALUES (202, 999.99, 'shipped');
INSERT INTO public.orders (customer_id, amount, status) VALUES (303, 150.00, 'pending');
INSERT INTO public.orders (customer_id, amount, status) VALUES (404, 750.00, 'shipped');
INSERT INTO public.orders (customer_id, amount, status) VALUES (505, 1200.00, 'processing');

-- Test CDC with an update
UPDATE public.orders SET status = 'delivered' WHERE customer_id = 101;

-- Test CDC with a delete
DELETE FROM public.orders WHERE customer_id = 303;
