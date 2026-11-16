-- COFFEY starter schema (SQLite). Apply with: sqlite3 coffey.db < database/schema.sql
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS menu_items (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  price_cents INTEGER NOT NULL CHECK (price_cents >= 0),
  image_url TEXT NOT NULL,
  ingredients_json TEXT NOT NULL,
  nutrition_json TEXT NOT NULL,
  allergens TEXT NOT NULL DEFAULT '',
  available INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY,
  public_code TEXT NOT NULL UNIQUE,
  user_id INTEGER REFERENCES users(id),
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'confirmed',
  subtotal_cents INTEGER NOT NULL CHECK (subtotal_cents >= 0),
  payment_method TEXT NOT NULL,
  payment_reference TEXT,
  pickup_at TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  menu_item_id INTEGER NOT NULL REFERENCES menu_items(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price_cents INTEGER NOT NULL CHECK (unit_price_cents >= 0),
  PRIMARY KEY (order_id, menu_item_id)
);

CREATE TABLE IF NOT EXISTS reservations (
  id INTEGER PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  reserved_for TEXT NOT NULL,
  party_size INTEGER NOT NULL CHECK (party_size BETWEEN 1 AND 20),
  status TEXT NOT NULL DEFAULT 'requested',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS favorites (
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  menu_item_id INTEGER NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, menu_item_id)
);

CREATE TABLE IF NOT EXISTS newsletter_subscribers (
  id INTEGER PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  subscribed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  active INTEGER NOT NULL DEFAULT 1
);

-- Safe placeholder sample records. Replace the password hash before any real deployment.
INSERT OR IGNORE INTO users (id, name, email, password_hash)
VALUES (1, 'Coffey Demo', 'friend@coffey.cafe', '$2b$12$REPLACE_WITH_A_REAL_BCRYPT_HASH');

INSERT OR IGNORE INTO menu_items
  (id, name, category, description, price_cents, image_url, ingredients_json, nutrition_json, allergens)
VALUES
  (1, 'Velvet flat white', 'Drinks', 'Double espresso, silky steamed milk', 500,
   'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=700&q=78',
   '["Coffee","whole milk"]', '{"calories":180,"protein_g":4,"carbohydrates_g":12,"fat_g":3}', 'Milk'),
  (2, 'Avocado & whipped feta toast', 'Breakfast', 'Sourdough, smashed avocado, whipped feta, chilli oil', 1300,
   'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=700&q=78',
   '["Avocado","sourdough","feta","lemon","chilli"]', '{"calories":217,"protein_g":11,"carbohydrates_g":23,"fat_g":13}', 'Gluten, milk');

INSERT OR IGNORE INTO orders
  (id, public_code, user_id, customer_name, customer_email, status, subtotal_cents, payment_method, pickup_at)
VALUES
  (1, 'CF-DEMO01', 1, 'Coffey Demo', 'friend@coffey.cafe', 'ready_for_pickup', 1000, 'pay_at_pickup', '2026-11-16 09:00:00');

INSERT OR IGNORE INTO order_items (order_id, menu_item_id, quantity, unit_price_cents)
VALUES (1, 1, 2, 500);
