-- name: GetCartByGuestToken :one
SELECT * FROM carts 
WHERE guest_token = $1 AND status = 'active' 
LIMIT 1;

-- name: CreateCart :one
INSERT INTO carts (guest_token) 
VALUES ($1) 
RETURNING *;

-- name: GetCartItems :many
SELECT 
    ci.id, ci.cart_id, ci.product_id, ci.qty, ci.price_snapshot,
    p.name as product_name,
    p.slug as product_slug,
    p.sku as product_sku,
    pp.price as current_price,
    pp.currency
FROM cart_items ci
JOIN products p ON ci.product_id = p.id
LEFT JOIN product_prices pp ON p.id = pp.product_id
WHERE ci.cart_id = $1;

-- name: AddItemToCart :exec
INSERT INTO cart_items (cart_id, product_id, qty, price_snapshot)
VALUES ($1, $2, $3, $4)
ON CONFLICT (cart_id, product_id) DO UPDATE SET
    qty = cart_items.qty + EXCLUDED.qty,
    price_snapshot = EXCLUDED.price_snapshot;

-- name: UpdateCartItemQty :exec
UPDATE cart_items 
SET qty = $3 
WHERE cart_id = $1 AND product_id = $2;

-- name: RemoveCartItem :exec
DELETE FROM cart_items 
WHERE cart_id = $1 AND product_id = $2;

-- name: ClearCart :exec
DELETE FROM cart_items 
WHERE cart_id = $1;
