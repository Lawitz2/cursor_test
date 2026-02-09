-- name: ListCategories :many
SELECT * FROM categories
ORDER BY name;

-- name: GetCategoryBySlug :one
SELECT * FROM categories
WHERE slug = $1 LIMIT 1;

-- name: ListProducts :many
SELECT
    p.*,
    pp.price,
    pp.old_price,
    pp.currency,
    i.qty_available
FROM products p
         LEFT JOIN product_prices pp ON p.id = pp.product_id
         LEFT JOIN inventory i ON p.id = i.product_id
WHERE p.is_active = true
ORDER BY p.created_at DESC;

-- name: GetProductBySlug :one
SELECT
    p.*,
    pp.price,
    pp.old_price,
    pp.currency,
    i.qty_available
FROM products p
         LEFT JOIN product_prices pp ON p.id = pp.product_id
         LEFT JOIN inventory i ON p.id = i.product_id
WHERE p.slug = $1 AND p.is_active = true
    LIMIT 1;

-- name: ListProductsByCategory :many
SELECT
    p.*,
    pp.price,
    pp.old_price,
    pp.currency
FROM products p
         JOIN product_categories pc ON p.id = pc.product_id
         LEFT JOIN product_prices pp ON p.id = pp.product_id
WHERE pc.category_id = $1 AND p.is_active = true
ORDER BY p.created_at DESC;
