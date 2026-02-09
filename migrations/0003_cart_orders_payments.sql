-- +goose Up

-- CART
CREATE TABLE carts (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     uuid REFERENCES users(id) ON DELETE SET NULL,
    guest_token text UNIQUE,
    status      text NOT NULL DEFAULT 'active', -- active/converted/abandoned
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE cart_items (
    id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id        uuid NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id     uuid NOT NULL REFERENCES products(id),
    qty            int  NOT NULL CHECK (qty > 0),
    price_snapshot numeric(12,2),
    UNIQUE (cart_id, product_id)
);

-- ORDERS
CREATE TABLE orders (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number          text NOT NULL UNIQUE,
    user_id               uuid REFERENCES users(id) ON DELETE SET NULL,
    status                text NOT NULL, -- awaiting_payment/paid/...
    total_amount          numeric(12,2) NOT NULL,
    currency              text NOT NULL DEFAULT 'RUB',
    delivery_method       text NOT NULL,
    delivery_price        numeric(12,2) NOT NULL DEFAULT 0,
    delivery_address_json jsonb,
    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);

CREATE TABLE order_items (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id      uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id    uuid NOT NULL REFERENCES products(id),
    name_snapshot text NOT NULL,
    sku_snapshot  text NOT NULL,
    price         numeric(12,2) NOT NULL,
    qty           int NOT NULL CHECK (qty > 0),
    line_total    numeric(12,2) NOT NULL
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- PAYMENTS
CREATE TABLE payment_attempts (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id            uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    provider            text NOT NULL, -- tbank
    status              text NOT NULL, -- created/redirected/succeeded/failed/cancelled
    amount              numeric(12,2) NOT NULL,
    currency            text NOT NULL DEFAULT 'RUB',
    provider_payment_id text UNIQUE,
    provider_payload    jsonb,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_payment_attempts_order_id ON payment_attempts(order_id);

-- +goose Down

DROP INDEX IF EXISTS idx_payment_attempts_order_id;
DROP TABLE IF EXISTS payment_attempts;

DROP INDEX IF EXISTS idx_order_items_order_id;
DROP TABLE IF EXISTS order_items;

DROP INDEX IF EXISTS idx_orders_status;
DROP INDEX IF EXISTS idx_orders_user_id;
DROP TABLE IF EXISTS orders;

DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS carts;

