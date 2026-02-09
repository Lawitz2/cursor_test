-- +goose Up

-- USERS
CREATE TABLE users (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    phone         text UNIQUE,
    email         text UNIQUE,
    password_hash text,
    full_name     text NOT NULL DEFAULT '',
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

-- CATALOG
CREATE TABLE products (
    id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    slug               text NOT NULL UNIQUE,
    sku                text NOT NULL UNIQUE,
    name               text NOT NULL,
    short_description  text,
    description        text,
    composition        text,
    indications        text,
    contraindications  text,
    usage              text,
    manufacturer       text,
    is_active          boolean NOT NULL DEFAULT true,
    created_at         timestamptz NOT NULL DEFAULT now(),
    updated_at         timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_products_name_trgm ON products USING gin (name gin_trgm_ops);

CREATE TABLE product_media (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    type       text NOT NULL, -- image / video
    url        text NOT NULL,
    sort_order int  NOT NULL DEFAULT 0
);

CREATE TABLE categories (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    slug       text NOT NULL,
    name       text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX uq_categories_slug ON categories(slug);

CREATE TABLE product_categories (
    product_id  uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    category_id uuid NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, category_id)
);

CREATE TABLE product_prices (
    product_id uuid PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    currency   text NOT NULL DEFAULT 'RUB',
    price      numeric(12,2) NOT NULL,
    old_price  numeric(12,2),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE inventory (
    product_id    uuid PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    qty_available int  NOT NULL DEFAULT 0,
    qty_reserved  int  NOT NULL DEFAULT 0,
    updated_at    timestamptz NOT NULL DEFAULT now()
);

-- +goose Down

DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS product_prices;
DROP TABLE IF EXISTS product_categories;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS product_media;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

