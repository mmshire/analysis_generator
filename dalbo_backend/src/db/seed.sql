-- Sample data: 5 restaurants in Hargeisa, Somaliland
-- Run after schema.sql:  psql -U postgres -d dalbo_db -f src/db/seed.sql

INSERT INTO restaurants (name, cuisine_type, photo_url, delivery_time_min, is_open, address, rating)
VALUES
  ('Rays Kitchen',
   'Somali',
   'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600',
   25, TRUE, '26 June Road, Hargeisa', 4.8),

  ('Pizza Corner Hargeisa',
   'Pizza & Fast Food',
   'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600',
   35, TRUE, 'Ahmed Dhagah Street, Hargeisa', 4.5),

  ('Oriental Palace',
   'Chinese & Asian',
   'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600',
   40, TRUE, 'Jigjiga Yar, Hargeisa', 4.3),

  ('Al-Baraka Suqaar House',
   'Somali Grills',
   'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600',
   20, TRUE, 'Mohamoud Haybe Road, Hargeisa', 4.7),

  ('Gollis Café & Bakery',
   'Café & Bakery',
   'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600',
   15, FALSE, 'Gollis University Area, Hargeisa', 4.2)
ON CONFLICT DO NOTHING;

-- Menu items for Rays Kitchen (id=1)
INSERT INTO menu_items (restaurant_id, name, description, price_usd, photo_url, category)
VALUES
  (1, 'Somali Beef Stew', 'Slow-cooked beef with spiced tomato sauce, served with rice', 4.50,
   'https://images.unsplash.com/photo-1547592180-85f173990554?w=400', 'Mains'),
  (1, 'Hilib Ari (Goat Meat)', 'Grilled goat served with canjeero flatbread', 5.00,
   'https://images.unsplash.com/photo-1529694157872-4e0c0f3b238b?w=400', 'Mains'),
  (1, 'Canjeero Breakfast', 'Traditional Somali pancake with honey and butter', 2.00,
   'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400', 'Breakfast'),
  (1, 'Baasto (Spaghetti)', 'Somali-style pasta with spiced meat sauce', 3.50,
   'https://images.unsplash.com/photo-1551183053-bf91798d9e17?w=400', 'Mains'),
  (1, 'Fresh Mango Juice', 'Cold-pressed local mango', 1.50,
   'https://images.unsplash.com/photo-1546173159-315724a31696?w=400', 'Drinks');

-- Menu items for Pizza Corner (id=2)
INSERT INTO menu_items (restaurant_id, name, description, price_usd, photo_url, category)
VALUES
  (2, 'Margherita Pizza (Large)', 'Classic tomato, mozzarella, basil', 7.00,
   'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400', 'Pizza'),
  (2, 'BBQ Chicken Pizza', 'Grilled chicken, BBQ sauce, peppers', 8.50,
   'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400', 'Pizza'),
  (2, 'Beef Burger', 'Double patty, cheddar, lettuce, tomato', 5.00,
   'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400', 'Burgers'),
  (2, 'Loaded Fries', 'Crispy fries with cheese sauce and jalapeños', 3.00,
   'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=400', 'Sides'),
  (2, 'Soft Drink (330ml)', 'Coke, Fanta, Sprite', 0.75,
   'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400', 'Drinks');

-- Menu items for Oriental Palace (id=3)
INSERT INTO menu_items (restaurant_id, name, description, price_usd, photo_url, category)
VALUES
  (3, 'Fried Rice (Chicken)', 'Wok-fried rice with egg, vegetables and chicken', 4.00,
   'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400', 'Rice'),
  (3, 'Kung Pao Chicken', 'Spicy stir-fried chicken with peanuts', 5.50,
   'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=400', 'Mains'),
  (3, 'Spring Rolls (6 pcs)', 'Crispy vegetable spring rolls with sweet chili', 3.00,
   'https://images.unsplash.com/photo-1515669097368-22e68427d265?w=400', 'Starters'),
  (3, 'Sweet & Sour Fish', 'Crispy fish fillet in tangy sauce', 6.00,
   'https://images.unsplash.com/photo-1559742811-822873691df8?w=400', 'Mains');

-- Menu items for Al-Baraka Suqaar House (id=4)
INSERT INTO menu_items (restaurant_id, name, description, price_usd, photo_url, category)
VALUES
  (4, 'Suqaar (Beef Cubes)', 'Flash-fried spiced beef cubes, Somali style', 4.00,
   'https://images.unsplash.com/photo-1529694157872-4e0c0f3b238b?w=400', 'Grills'),
  (4, 'Mixed Grill Platter', 'Suqaar + ribs + liver for two', 9.00,
   'https://images.unsplash.com/photo-1544025162-d76694265947?w=400', 'Grills'),
  (4, 'Rice & Stew Combo', 'Basmati rice with daily stew', 3.50,
   'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400', 'Mains'),
  (4, 'Somali Tea (Shaah)', 'Spiced tea with milk and cardamom', 0.75,
   'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=400', 'Drinks');

-- Menu items for Gollis Café (id=5)
INSERT INTO menu_items (restaurant_id, name, description, price_usd, photo_url, category)
VALUES
  (5, 'Cappuccino', 'Double espresso with steamed milk foam', 2.00,
   'https://images.unsplash.com/photo-1534778101976-62847782c213?w=400', 'Drinks'),
  (5, 'Croissant', 'Buttery fresh-baked croissant', 1.50,
   'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400', 'Bakery'),
  (5, 'Chocolate Cake Slice', 'Rich dark chocolate layer cake', 2.50,
   'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400', 'Bakery'),
  (5, 'Club Sandwich', 'Triple-decker with chicken, egg, lettuce', 4.50,
   'https://images.unsplash.com/photo-1528736235302-52922df5c122?w=400', 'Sandwiches')
ON CONFLICT DO NOTHING;
