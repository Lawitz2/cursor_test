BEGIN;

-- 1. Clean up existing data
TRUNCATE TABLE users, products, categories, carts, orders RESTART IDENTITY CASCADE;

-- 2. USERS (IDs: 1111...)
INSERT INTO users (id, phone, email, password_hash, full_name) VALUES
                                                                   ('11111111-1111-1111-1111-111111111111', '+15550100', 'alice@example.com', 'hash_secret_123', 'Alice Admin'),
                                                                   ('22222222-2222-2222-2222-222222222222', '+15550101', 'bob@example.com',   'hash_secret_456', 'Bob Buyer'),
                                                                   ('33333333-3333-3333-3333-333333333333', NULL,        'charlie@example.com', 'hash_secret_789', 'Charlie Guest');

-- 3. CATEGORIES (IDs: aaaa...)
INSERT INTO categories (id, slug, name) VALUES
                                            ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'electronics', 'Electronics'),
                                            ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'clothing',    'Clothing'),
                                            ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'home',        'Home & Garden');

-- 4. PRODUCTS (IDs: b111... "b" is valid hex)
INSERT INTO products (id, slug, sku, name, description, manufacturer, is_active) VALUES
                                                                                     ('b1111111-1111-1111-1111-111111111111', 'smartphone-x', 'ELEC-PHN-001', 'Smartphone X', 'Latest model with AI camera', 'TechCorp', true),
                                                                                     ('b2222222-2222-2222-2222-222222222222', 'laptop-pro',   'ELEC-LPT-002', 'Laptop Pro 15', 'High performance laptop', 'CompInc', true),
                                                                                     ('b3333333-3333-3333-3333-333333333333', 'cotton-tshirt','CLOTH-TSH-001','Basic Cotton T-Shirt', '100% Organic Cotton', 'EcoWear', true),
                                                                                     ('b4444444-4444-4444-4444-444444444444', 'coffee-mug',   'HOME-MUG-001', 'Ceramic Coffee Mug', 'Holds 12oz of liquid', 'HomeGoods', true);

-- 5. PRODUCT DETAILS

-- Link Products to Categories
INSERT INTO product_categories (product_id, category_id) VALUES
                                                             ('b1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'), -- Phone -> Electronics
                                                             ('b2222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'), -- Laptop -> Electronics
                                                             ('b3333333-3333-3333-3333-333333333333', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'), -- Shirt -> Clothing
                                                             ('b4444444-4444-4444-4444-444444444444', 'cccccccc-cccc-cccc-cccc-cccccccccccc'); -- Mug -> Home

-- Prices
INSERT INTO product_prices (product_id, price, old_price) VALUES
                                                              ('b1111111-1111-1111-1111-111111111111', 999.00, 1099.00),
                                                              ('b2222222-2222-2222-2222-222222222222', 1499.50, NULL),
                                                              ('b3333333-3333-3333-3333-333333333333', 19.99, NULL),
                                                              ('b4444444-4444-4444-4444-444444444444', 9.99, 12.99);

-- Inventory
INSERT INTO inventory (product_id, qty_available, qty_reserved) VALUES
                                                                    ('b1111111-1111-1111-1111-111111111111', 50, 2),
                                                                    ('b2222222-2222-2222-2222-222222222222', 10, 0),
                                                                    ('b3333333-3333-3333-3333-333333333333', 100, 5),
                                                                    ('b4444444-4444-4444-4444-444444444444', 0, 0);

-- Product Media
INSERT INTO product_media (product_id, type, url, sort_order) VALUES
                                                                  ('b1111111-1111-1111-1111-111111111111', 'image', 'https://example.com/phone_front.jpg', 1),
                                                                  ('b1111111-1111-1111-1111-111111111111', 'image', 'https://example.com/phone_back.jpg', 2),
                                                                  ('b2222222-2222-2222-2222-222222222222', 'video', 'https://example.com/laptop_review.mp4', 1);

-- 6. CARTS (IDs: c111... "c" is valid hex)
INSERT INTO carts (id, user_id, guest_token, status) VALUES
                                                         ('c1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', NULL, 'active'),
                                                         ('c2222222-2222-2222-2222-222222222222', NULL, 'guest_token_abc123', 'abandoned');

INSERT INTO cart_items (cart_id, product_id, qty, price_snapshot) VALUES
                                                                      ('c1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111', 1, 999.00),
                                                                      ('c1111111-1111-1111-1111-111111111111', 'b4444444-4444-4444-4444-444444444444', 2, 9.99),
                                                                      ('c2222222-2222-2222-2222-222222222222', 'b3333333-3333-3333-3333-333333333333', 1, 19.99);

-- 7. ORDERS (IDs: d111... "d" is valid hex)
INSERT INTO orders (id, order_number, user_id, status, total_amount, delivery_method, delivery_price, delivery_address_json) VALUES
                                                                                                                                 ('d1111111-1111-1111-1111-111111111111', 'ORD-2023-001', '22222222-2222-2222-2222-222222222222', 'paid', 1519.50, 'courier', 20.00, '{"city": "New York", "street": "5th Ave"}'),
                                                                                                                                 ('d2222222-2222-2222-2222-222222222222', 'ORD-2023-002', '11111111-1111-1111-1111-111111111111', 'awaiting_payment', 1019.00, 'pickup', 0.00, NULL);

-- Order Items
INSERT INTO order_items (order_id, product_id, name_snapshot, sku_snapshot, price, qty, line_total) VALUES
    ('d1111111-1111-1111-1111-111111111111', 'b2222222-2222-2222-2222-222222222222', 'Laptop Pro 15', 'ELEC-LPT-002', 1499.50, 1, 1499.50);

INSERT INTO order_items (order_id, product_id, name_snapshot, sku_snapshot, price, qty, line_total) VALUES
                                                                                                        ('d2222222-2222-2222-2222-222222222222', 'b1111111-1111-1111-1111-111111111111', 'Smartphone X', 'ELEC-PHN-001', 999.00, 1, 999.00),
                                                                                                        ('d2222222-2222-2222-2222-222222222222', 'b4444444-4444-4444-4444-444444444444', 'Ceramic Coffee Mug', 'HOME-MUG-001', 10.00, 2, 20.00);

-- 8. PAYMENTS
INSERT INTO payment_attempts (order_id, provider, status, amount, provider_payment_id) VALUES
                                                                                           ('d1111111-1111-1111-1111-111111111111', 'tbank', 'succeeded', 1519.50, 'pay_ext_987654'),
                                                                                           ('d2222222-2222-2222-2222-222222222222', 'tbank', 'failed', 1019.00, 'pay_ext_123456');

COMMIT;