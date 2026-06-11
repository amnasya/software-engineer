import { Request, Response, NextFunction } from 'express';
import { pool, DbResult, DbRow } from '../config/db';
import { ok } from '../utils/response';
import { ApiError } from '../utils/apiError';

// Plan definitions — plan_id maps to index (1-based)
export const PLANS = [
  {
    plan_id: 1,
    plan_code: 'free',
    plan_name: 'Free',
    price_idr: 0,
    features: ['1 active campaign', 'Up to 20 influencer views', 'Basic analytics'],
  },
  {
    plan_id: 2,
    plan_code: 'starter',
    plan_name: 'Starter',
    price_idr: 149000,
    features: ['5 active campaigns', 'Unlimited influencer views', 'Standard analytics', 'In-app chat'],
  },
  {
    plan_id: 3,
    plan_code: 'pro',
    plan_name: 'Pro',
    price_idr: 499000,
    features: ['Unlimited campaigns', 'Priority support', 'Advanced analytics', 'Featured placement'],
  },
  {
    plan_id: 4,
    plan_code: 'enterprise',
    plan_name: 'Enterprise',
    price_idr: 1499000,
    features: ['Everything in Pro', 'Dedicated manager', 'Custom contracts', 'SSO & audit log'],
  },
];

function findPlan(planId?: number, planCode?: string) {
  if (planId) return PLANS.find((p) => p.plan_id === planId);
  if (planCode) return PLANS.find((p) => p.plan_code === planCode);
  return undefined;
}

export const subscriptionController = {
  async plans(_req: Request, res: Response, next: NextFunction) {
    try {
      return ok(res, PLANS);
    } catch (e) { next(e); }
  },

  // GET /subscriptions/me  (Flutter calls /me)
  async me(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user || req.user.role !== 'brand') throw new ApiError(403, 'Brands only');
      const [rows] = await pool.query<DbRow[]>(
        `SELECT id, plan_id, plan_code, plan_name, status, started_at, expires_at
           FROM brand_subscriptions
          WHERE brand_user_id = ? AND status = 'active'
          ORDER BY id DESC
          LIMIT 1`,
        [req.user.id]
      );
      const active = rows[0] as Record<string, unknown> | undefined;
      const planCode = (active?.plan_code as string) ?? 'free';
      const planId = (active?.plan_id as number) ?? 1;
      const planName = (active?.plan_name as string) ?? 'Free';

      // Format matches Flutter Subscription model: plan_id, plan_name, status, expires_at
      return ok(res, {
        plan_id: planId,
        plan_name: planName,
        plan_code: planCode,
        status: (active?.status as string) ?? 'active',
        expires_at: active?.expires_at ?? null,
        started_at: active?.started_at ?? null,
      });
    } catch (e) { next(e); }
  },

  // GET /subscriptions/mine  (route alias kept for backwards compat)
  async mine(req: Request, res: Response, next: NextFunction) {
    return subscriptionController.me(req, res, next);
  },

  // POST /subscriptions/subscribe — Flutter sends { plan_id: int }
  async subscribe(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user || req.user.role !== 'brand') throw new ApiError(403, 'Brands only');

      // Accept plan_id (Flutter) or plan_code (legacy)
      const planId = req.body?.plan_id ? Number(req.body.plan_id) : undefined;
      const planCode = req.body?.plan_code ? String(req.body.plan_code) : undefined;
      const plan = findPlan(planId, planCode);
      if (!plan) throw new ApiError(400, 'Unknown plan');

      const [r] = await pool.query<DbResult>(
        `INSERT INTO brand_subscriptions
           (brand_user_id, plan_id, plan_code, plan_name, status, started_at, expires_at)
         VALUES (?, ?, ?, ?, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY))`,
        [req.user.id, plan.plan_id, plan.plan_code, plan.plan_name]
      );

      return ok(res, {
        id: r.insertId,
        plan_id: plan.plan_id,
        plan_name: plan.plan_name,
        plan_code: plan.plan_code,
        status: 'active',
      }, 'Subscribed');
    } catch (e) { next(e); }
  },

  // POST /subscriptions/cancel
  async cancel(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user || req.user.role !== 'brand') throw new ApiError(403, 'Brands only');
      await pool.query(
        `UPDATE brand_subscriptions
            SET status = 'cancelled', cancelled_at = NOW()
          WHERE brand_user_id = ? AND status = 'active'`,
        [req.user.id]
      );
      return ok(res, { ok: true }, 'Cancelled');
    } catch (e) { next(e); }
  },
};
