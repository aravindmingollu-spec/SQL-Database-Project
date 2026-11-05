
CREATE TABLE customers (
    customer_id      INTEGER PRIMARY KEY,
    city             TEXT NOT NULL,
    membership_tier  TEXT NOT NULL CHECK (membership_tier IN ('Bronze','Silver','Gold','Platinum')),
    signup_date      TEXT NOT NULL,
    loyalty_points   INTEGER NOT NULL CHECK (loyalty_points >= 0)
);
CREATE TABLE products (
    product_id       INTEGER PRIMARY KEY,
    product_name     TEXT NOT NULL,
    category         TEXT NOT NULL,
    storage_type     TEXT NOT NULL CHECK (storage_type IN ('Ambient','Chilled','Frozen')),
    unit_price       REAL NOT NULL CHECK (unit_price > 0)
);
CREATE TABLE orders (
    order_id           INTEGER PRIMARY KEY,
    customer_id        INTEGER NOT NULL,
    order_timestamp    TEXT NOT NULL,
    delivery_priority  INTEGER NOT NULL CHECK (delivery_priority BETWEEN 1 AND 3),
    delivery_temp_c    REAL NOT NULL CHECK (delivery_temp_c BETWEEN -40 AND 55),
    payment_method     TEXT NOT NULL CHECK (payment_method IN ('Card','Digital Wallet','Gift Card')),
    fulfillment_status TEXT NOT NULL CHECK (fulfillment_status IN ('Delivered','Picked Up')),
    subtotal           REAL NOT NULL CHECK (subtotal >= 0),
    delivery_fee       REAL NOT NULL CHECK (delivery_fee >= 0),
    order_total        REAL NOT NULL CHECK (order_total >= 0),
    item_count         INTEGER NOT NULL CHECK (item_count >= 1),
    CHECK (ABS(order_total - (subtotal + delivery_fee)) < 0.011),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_id          INTEGER NOT NULL,
    product_id        INTEGER NOT NULL,
    add_to_cart_order INTEGER NOT NULL CHECK (add_to_cart_order >= 1),
    quantity          INTEGER NOT NULL CHECK (quantity >= 1),
    unit_price        REAL NOT NULL CHECK (unit_price > 0),
    line_total        REAL NOT NULL CHECK (line_total >= 0),
    reordered         INTEGER NOT NULL CHECK (reordered IN (0,1)),
    PRIMARY KEY (order_id, product_id),
    UNIQUE (order_id, add_to_cart_order),
    CHECK (ABS(line_total - quantity * unit_price) < 0.011),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) WITHOUT ROWID;
CREATE TABLE data_provenance (
    source_id INTEGER PRIMARY KEY,
    source_mode TEXT NOT NULL,
    source_filename TEXT,
    origin_notes TEXT NOT NULL,
    sampled_order_count INTEGER NOT NULL,
    sampled_line_count INTEGER NOT NULL
);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_timestamp);
CREATE INDEX idx_items_product ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category);
