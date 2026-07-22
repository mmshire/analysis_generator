/**
 * Admin routes — secured with ADMIN_SECRET header (simple key for Phase 1)
 *
 * POST   /api/admin/restaurants           add restaurant
 * POST   /api/admin/restaurants/:id/menu  add menu item
 * PATCH  /api/admin/restaurants/:id       update restaurant (open/close, details)
 * DELETE /api/admin/restaurants/:id       delete restaurant
 * GET    /api/admin/orders                all orders (with filters)
 */

const router = require('express').Router();
const db     = require('../db');

// Simple admin key guard (replace with proper role-based auth in production)
router.use((req, res, next) => {
  if (req.headers['x-admin-secret'] !== process.env.ADMIN_SECRET) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  next();
});

// ── Restaurants ───────────────────────────────────────────────────────────────

router.post('/restaurants', async (req, res, next) => {
  try {
    const { name, cuisine_type, photo_url, delivery_time_min, is_open, address } = req.body;
    const { rows: [r] } = await db.query(
      `INSERT INTO restaurants (name, cuisine_type, photo_url, delivery_time_min, is_open, address)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [name, cuisine_type, photo_url, delivery_time_min ?? 30, is_open ?? true, address]
    );
    res.status(201).json(r);
  } catch (err) { next(err); }
});

router.patch('/restaurants/:id', async (req, res, next) => {
  try {
    const fields = ['name','cuisine_type','photo_url','delivery_time_min','is_open','address','rating'];
    const updates = [];
    const values  = [];
    let   i       = 1;
    for (const f of fields) {
      if (req.body[f] !== undefined) { updates.push(`${f} = $${i++}`); values.push(req.body[f]); }
    }
    if (!updates.length) return res.status(400).json({ error: 'Nothing to update' });
    values.push(req.params.id);
    const { rows: [r] } = await db.query(
      `UPDATE restaurants SET ${updates.join(', ')} WHERE id = $${i} RETURNING *`, values
    );
    res.json(r);
  } catch (err) { next(err); }
});

router.delete('/restaurants/:id', async (req, res, next) => {
  try {
    await db.query(`DELETE FROM restaurants WHERE id = $1`, [req.params.id]);
    res.json({ deleted: true });
  } catch (err) { next(err); }
});

// ── Menu items ────────────────────────────────────────────────────────────────

router.post('/restaurants/:id/menu', async (req, res, next) => {
  try {
    const { name, description, price_usd, photo_url, category } = req.body;
    const { rows: [item] } = await db.query(
      `INSERT INTO menu_items (restaurant_id, name, description, price_usd, photo_url, category)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [req.params.id, name, description, price_usd, photo_url, category]
    );
    res.status(201).json(item);
  } catch (err) { next(err); }
});

// ── All orders ────────────────────────────────────────────────────────────────

router.get('/orders', async (req, res, next) => {
  try {
    const { status } = req.query;
    const { rows } = await db.query(
      `SELECT o.*, u.phone, u.name AS customer_name, r.name AS restaurant_name
       FROM orders o
       JOIN users u ON u.id = o.user_id
       JOIN restaurants r ON r.id = o.restaurant_id
       ${status ? 'WHERE o.status = $1' : ''}
       ORDER BY o.created_at DESC`,
      status ? [status] : []
    );
    res.json(rows);
  } catch (err) { next(err); }
});

module.exports = router;
