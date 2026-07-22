/**
 * Restaurant & menu routes (public — no auth required)
 *
 * GET /api/restaurants           list all restaurants
 * GET /api/restaurants/:id       single restaurant + full menu
 */

const router = require('express').Router();
const db     = require('../db');

router.get('/', async (_req, res, next) => {
  try {
    const { rows } = await db.query(`
      SELECT id, name, cuisine_type, photo_url,
             delivery_time_min, is_open, address, rating
      FROM restaurants
      ORDER BY is_open DESC, rating DESC
    `);
    res.json(rows);
  } catch (err) { next(err); }
});

router.get('/:id', async (req, res, next) => {
  try {
    const { rows: [restaurant] } = await db.query(
      `SELECT * FROM restaurants WHERE id = $1`, [req.params.id]
    );
    if (!restaurant) return res.status(404).json({ error: 'Restaurant not found' });

    const { rows: menu } = await db.query(
      `SELECT * FROM menu_items WHERE restaurant_id = $1 AND is_available = TRUE ORDER BY category, name`,
      [req.params.id]
    );

    // Group menu by category for the app
    const categories = {};
    for (const item of menu) {
      if (!categories[item.category]) categories[item.category] = [];
      categories[item.category].push(item);
    }

    res.json({ ...restaurant, menu, categories });
  } catch (err) { next(err); }
});

module.exports = router;
