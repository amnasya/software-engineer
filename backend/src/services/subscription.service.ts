import { pool, DbRow } from '../config/db';
import { ApiError } from '../utils/apiError';

export const subscriptionService = {
  async getPlans() {
    const [rows] = await pool.query<DbRow[]>(
      `SELECT code, name, price_idr, duration_days, max_active_campaigns, features
         FROM subscription_plans
        WHERE is_active = 1
        ORDER BY price_idr ASC`
    );
    return rows;
  },

  async getCurrent(brandUserId: number) {
    const [rows] = await pool.query<DbRow[]>(
      `SELECT s.*, sp.name AS plan_name, sp.features
         FROM subscriptions s
         JOIN subscription_plans sp ON sp.code = s.plan_code
        WHERE s.brand_user_id = ?
        ORDER BY s.started_at DESC
        LIMIT 1`,
      [brandUserId]
    );
    return rows[0] ?? null;
  },

  async subscribe(brandUserId: number, planCode: string) {
    const [planRows] = await pool.query<DbRow[]>(
      `SELECT code, duration_days FROM subscription_plans WHERE code = ? AND is_active = 1`,
      [planCode]
    );
    if (!planRows.length) throw new ApiError(404, 'Plan not found');
    const plan = planRows[0] as { code: string; duration_days: number };

    const [r] = await pool.query(
      `INSERT INTO subscriptions (brand_user_id, plan_code, started_at, expires_at, status)
       VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY), 'active')`,
      [brandUserId, plan.code, plan.duration_days]
    );
    const id = (r as { insertId: number }).insertId;

    // mirror to brand_profiles
    await pool.query(
      `UPDATE brand_profiles SET subscription_plan = ?, subscription_expires_at = DATE_ADD(NOW(), INTERVAL ? DAY) WHERE user_id = ?`,
      [plan.code, plan.duration_days, brandUserId]
    );

    return this.getCurrent(brandUserId);
  },

  async cancel(brandUserId: number) {
    const [r] = await pool.query(
      `UPDATE subscriptions SET status = 'cancelled', cancelled_at = NOW()
        WHERE brand_user_id = ? AND status = 'active'`,
      [brandUserId]
    );
    const affected = (r as { affectedRows: number }).affectedRows;
    if (!affected) throw new ApiError(404, 'No active subscription');
    return { cancelled: true };
  },
};
