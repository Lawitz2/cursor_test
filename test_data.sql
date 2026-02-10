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
                                                         ('c222