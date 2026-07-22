-- Run this once to set up the Dalbo database
-- psql -U postgres -d dalbo_db -f src/db/schema.sql

CREATE TABLE IF NOT EXISTS users (
  id         SERIAL PRIMARY KEY,
  phone      VARCHAR(20) UNIQUE NOT NULL,
  name       VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stores OTP codes (temporary, expires quickly)
CREATE TABLE IF NOT EXISTS otps (
  id         SERIAL PRIMARY KEY,
  phone      VARCHAR(20) NOT NULL,
  code       VARCHAR(6) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used       BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS restaurants (
  id                 SERIAL PRIMARY KEY,
  name               VARCHAR(150) NOT NULL,
  cuisine_type       VARCHAR(100),
  photo_url          TEXT,
  delivery_time_min  INTEGER DEFAULT 30,
  is_open            BOOLEAN DEFAULT TRUE,
  address            TEXT,
  rating             NUMERIC(2,1) DEFAULT 4.0,
  created_at         TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS menu_items (
  id            SERIAL PRIMARY KEY,
  restaurant_id INTEGER REFERENCES restaurants(id) ON DELETE CASCADE,
  name          VARCHAR(150) NOT NULL,
  description   TEXT,
  price_usd     NUMERIC(8,2) NOT NULL,
  photo_url     TEXT,
  category      VARCHAR(80),
  is_available  BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS orders (
  id               SERIAL PRIMARY KEY,
  user_id          INTEGER REFERENCES users(id),
  restaurant_id    INTEGER REFERENCES restaurants(id),
  status           VARCHAR(30) DEFAULT 'placed',
  -- status values: placed | accepted | preparing | rider_on_the_way | delivered | cancelled
  delivery_address TEXT NOT NULL,
  delivery_lat     NUMERIC(10,7),
  delivery_lng     NUMERIC(10,7),
  payment_method   VARCHAR(30) DEFAULT 'cash_on_delivery',
  -- payment_method: cash_on_delivery | zaad | edahab (plug in WaafiPay later)
  total_usd        NUMERIC(8,2) NOT NULL,
  notes            TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id           SERIAL PRIMARY KEY,
  order_id     INTEGER REFERENCES orders(id) ON DELETE CASCADE,
  menu_item_id INTEGER REFERENCES menu_items(id),
  name         VARCHAR(150),   -- snapshot at time of order
  quantity     INTEGER NOT NULL,
  price_usd    NUMERIC(8,2) NOT NULL
);

-- Firebase push notification tokens (will be used in Phase 2)
CREATE TABLE IF NOT EXISTS fcm_tokens (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER REFERENCES users(id) ON DELETE CASCADE,
  token      TEXT UNIQUE NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id   ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status    ON orders(status);
CREATE INDEX IF NOT EXISTS idx_menu_restaurant  ON menu_items(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_otps_phone       ON otps(phone);
