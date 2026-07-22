/**
 * Order routes (all require Bearer token)
 *
 * POST  /api/orders                    create order
 * GET   /api/orders                    user's order history
 * GET   /api/orders/:id                single order detail
 * PATCH /api/orders/:id/status         update status (for admin/rider use)
 * POST  /api/orders/:id/fcm-token      save Firebase token for push notifications
 */

const router      = require('express').Router();
const db          = require('../db');
const requireAuth = require('../middleware/auth');

router.use(requireAuth);

// ── Create order ────────────────────────────────────────────────────────────

router.post('/', async (req, res, next) => {
    try {
    const { restaurant_id, items, delivery_address, delivery_lat, delivery_lng, payment_method, notes } = req.body;

    if (!items?.length) return res.status(400).json({ error: 'Order must have at least one item' });

    // Calculate total from live menu prices (never trust client-sent prices)
    const itemIds = items.map(i => i.menu_item_id);
    const { rows: menuItems } = await db.query(
      `SELECT id, price_usd, name FROM menu_items WHERE id = ANY($1::int[])`,
      [itemIds]
    );
    const priceMap = Object.fromEntries(menuItems.map(m => [m.id, m]));

    let total_usd = 0;
    for (const item of items) {
      const menu = priceMap[item.menu_item_id];
      if (!menu) return res.status(400).json({ error: `Menu item ${item.menu_item_id} not found` });
      total_usd += menu.price_usd * item.quantity;
    }

    const { rows: [order] } = await db.query(
      `INSERT INTO orders (user_id, restaurant_id, status, delivery_address, delivery_lat, delivery_lng, payment_method, total_usd, notes)
       VALUES ($1, $2, 'placed', $3, $4, $5, $6, $7, $8) RETURNING *`,
      [req.user.id, restaurant_id, delivery_address, delivery_lat, delivery_lng,
       payment_method || 'cash_on_delivery', total_usd.toFixed(2), notes]
    );

    // Insert order items
    for (const item of items) {
      const menu = priceMap[item.menu_item_id];
      await db.query(
        `INSERT INTO order_items (order_id, menu_item_id, name, quantity, price_usd)
         VALUES ($1, $2, $3, $4, $5)`,
        [order.id, item.menu_item_id, menu.name, item.quantity, menu.price_usd]
      );
    }

    res.status(201).json(order);
  } catch (err) { next(err); }
});

// ── Order history ────────────────────────────────────────────────────────────

router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT o.*, r.name AS restaurant_name, r.photo_url AS restaurant_photo
       FROM orders o
       JOIN restaurants r ON r.id = o.restaurant_id
       WHERE o.user_id = $1
       ORDER BY o.created_at DESC`,
      [req.user.id]
    );
    res.json(rows);
  } catch (err) { next(err); }
});

// ── Single order ─────────────────────────────────────────────────────────────

router.get('/:id', async (req, res, next) => {
  try {
    const { rows: [order] } = await db.query(
      `SELECT o.*, r.name AS restaurant_name, r.photo_url AS restaurant_photo,
              r.address AS restaurant_address
       FROM orders o
       JOIN restaurants r ON r.id = o.restaurant_id
       WHERE o.id = $1 AND o.user_id = $2`,
      [req.params.id, req.user.id]
    );
    if (!order) return res.status(404).json({ error: 'Order not found' });

    const { rows: orderItems } = await db.query(
      `SELECT * FROM order_items WHERE order_id = $1`, [order.id]
    );
    res.json({ ...order, items: orderItems });
  } catch (err) { next(err); }
});

// ── Update status (admin / rider endpoint) ────────────────────────────────────

const VALID_STATUSES = ['placed', 'accepted', 'preparing', 'rider_on_the_way', 'delivered', 'cancelled'];

router.patch('/:id/status', async (req, res, next) => {
  try {
    const { status } = req.body;
    if (!VALID_STATUSES.includes(status))
      return res.status(400).json({ error: 'Invalid status', valid: VALID_STATUSES });

    const { rows: [order] } = await db.query(
      `UPDATE orders SET status = $1, updated_at = NOW()
       WHERE id = $2 RETURNING *`,
      [status, req.params.id]
    );
    if (!order) return res.status(404).json({ error: 'Order not found' });

    // TODO: send Firebase push notification here (Phase 2)
    // await sendPushNotification(order.user_id, `Your order is now: ${status}`);

    res.json(order);
  } catch (err) { next(err); }
});

// ── Save FCM token (for push notifications later) ─────────────────────────────

router.post('/fcm-token', async (req, res, next) => {
  try {
    const { token } = req.body;
    await db.query(
      `INSERT INTO fcm_tokens (user_id, token, updated_at)
       VALUES ($1, $2, NOW())
       ON CONFLICT (token) DO UPDATE SET user_id = $1, updated_at = NOW()`,
      [req.user.id, token]
    );
    res.json({ saved: true });
  } catch (err) { next(err); }
});

module.exports = router;
