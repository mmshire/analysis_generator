/**
 * Auth routes — phone number + OTP flow
 *
 * POST /api/auth/send-otp    { phone }
 * POST /api/auth/verify-otp  { phone, code }
 * PATCH /api/auth/profile    { name }  (requires Bearer token)
 *
 * DEV MODE: set OTP_DEV_MODE=true in .env — code "123456" always works.
 * PRODUCTION: replace the sendSms() stub below with your SMS provider
 *             (e.g. Africa's Talking, Twilio, or a local Somaliland gateway).
 */

const router  = require('express').Router();
const jwt     = require('jsonwebtoken');
const db      = require('../db');
const requireAuth = require('../middleware/auth');

// ── helpers ────────────────────────────────────────────────────────────────

function generateOtp() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

async function sendSms(phone, code) {
  // TODO: replace with real SMS provider
  // Example with Africa's Talking:
  //   const AfricasTalking = require('africastalking')({ apiKey, username });
  //   await AfricasTalking.SMS.send({ to: [phone], message: `Your Dalbo code: ${code}` });
  console.log(`[DEV] OTP for ${phone}: ${code}`);
}

// ── routes ─────────────────────────────────────────────────────────────────

router.post('/send-otp', async (req, res, next) => {
  try {
    const { phone } = req.body;
    if (!phone) return res.status(400).json({ error: 'Phone number required' });

    const code      = generateOtp();
    const expiresAt = new Date(Date.now() + (process.env.OTP_EXPIRY_MINUTES || 10) * 60 * 1000);

    // Invalidate any previous unused OTPs for this phone
    await db.query(`UPDATE otps SET used = TRUE WHERE phone = $1 AND used = FALSE`, [phone]);

    await db.query(
      `INSERT INTO otps (phone, code, expires_at) VALUES ($1, $2, $3)`,
      [phone, code, expiresAt]
    );

    await sendSms(phone, code);

    res.json({ message: 'OTP sent', dev_note: process.env.OTP_DEV_MODE === 'true' ? 'Use code 123456 in dev mode' : undefined });
  } catch (err) { next(err); }
});

router.post('/verify-otp', async (req, res, next) => {
  try {
    const { phone, code } = req.body;
    if (!phone || !code) return res.status(400).json({ error: 'Phone and code required' });

    // Dev mode shortcut
    const devMode = process.env.OTP_DEV_MODE === 'true';

    if (!devMode || code !== '123456') {
      const { rows } = await db.query(
        `SELECT * FROM otps WHERE phone = $1 AND code = $2 AND used = FALSE AND expires_at > NOW() ORDER BY created_at DESC LIMIT 1`,
        [phone, code]
      );
      if (!rows.length) return res.status(400).json({ error: 'Invalid or expired OTP' });

      await db.query(`UPDATE otps SET used = TRUE WHERE id = $1`, [rows[0].id]);
    }

    // Upsert user
    const { rows: users } = await db.query(
      `INSERT INTO users (phone) VALUES ($1)
       ON CONFLICT (phone) DO UPDATE SET phone = EXCLUDED.phone
       RETURNING *`,
      [phone]
    );
    const user = users[0];

    const token = jwt.sign({ id: user.id, phone: user.phone }, process.env.JWT_SECRET, { expiresIn: '90d' });

    res.json({ token, user: { id: user.id, phone: user.phone, name: user.name } });
  } catch (err) { next(err); }
});

router.patch('/profile', requireAuth, async (req, res, next) => {
  try {
    const { name } = req.body;
    const { rows } = await db.query(
      `UPDATE users SET name = $1 WHERE id = $2 RETURNING id, phone, name`,
      [name, req.user.id]
    );
    res.json(rows[0]);
  } catch (err) { next(err); }
});

module.exports = router;
