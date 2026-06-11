// ============================================================
// LAYER INI menggunakan beberapa DESIGN PATTERN:
//   - BUILDER: create() bisa direfactor pakai CampaignBuilder (lihat
//     services/campaignBuilder.ts). Saat ini masih inline INSERT.
//   - STATE: updateStatus() validasi transisi pakai aturan di
//     services/campaignState.ts (CampaignStateMachine).
//   - OBSERVER: setelah create/updateStatus, idealnya publish ke
//     eventBus.publish('campaign.created' / 'campaign.status_changed').
//     Saat ini notifikasi masih hardcoded di service ini (legacy).
// ============================================================

import { pool, DbRow, DbResult } from '../../config/db';
import { ApiError } from '../../core/utils/apiError';

export interface OfferInput {
  brand_user_id: number;
  influencer_user_id: number;
  title: string;
  brief?: string;
  budget: number;
  reward_per_creator?: number;
  target_views?: number;
  target_likes?: number;
  target_shares?: number;
  deliverables?: string;
  requirements?: string;
  target_audience?: string;
  deadline?: string;
  room_code?: string;
  is_public?: boolean;
}

export const offerService = {
  async create(input: OfferInput) {
    const [r] = await pool.query<DbResult>(
      `INSERT INTO offers
       (brand_user_id, influencer_user_id, title, brief, budget, reward_per_creator,
        target_views, target_likes, target_shares, deliverables, requirements,
        target_audience, deadline, room_code, status, is_public)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?, 'open', ?)`,
      [
        input.brand_user_id, input.influencer_user_id, input.title, input.brief ?? null,
        input.budget, input.reward_per_creator ?? input.budget,
        input.target_views ?? 0, input.target_likes ?? 0, input.target_shares ?? 0,
        input.deliverables ?? null, input.requirements ?? null,
        input.target_audience ?? null, input.deadline ?? null, input.room_code ?? null,
        input.is_public === false ? 0 : 1,
      ]
    );
    // notify influencer
    await pool.query(
      `INSERT INTO notifications (user_id, type, title, body, icon)
       VALUES (?, 'offer', ?, ?, 'mail')`,
      [input.influencer_user_id, 'New offer', `${input.title}`]
    );
    return this.getById((r as DbResult).insertId);
  },

  async list(userId: number, role: 'influencer' | 'brand') {
    const col = role === 'brand' ? 'brand_user_id' : 'influencer_user_id';
    const [rows] = await pool.query<DbRow[]>(
      `SELECT o.*, bp.brand_name, bp.logo_url,
              ip.username AS influencer_username, u2.name AS influencer_name
       FROM offers o
       JOIN brand_profiles bp ON bp.user_id = o.brand_user_id
       JOIN influencer_profiles ip ON ip.user_id = o.influencer_user_id
       JOIN users u2 ON u2.id = o.influencer_user_id
       WHERE o.${col} = ?
       ORDER BY o.created_at DESC`,
      [userId]
    );
    return rows;
  },

  async getById(id: number) {
    const [rows] = await pool.query<DbRow[]>(
      `SELECT o.*, bp.brand_name, bp.logo_url, bp.industry, bp.location AS brand_location,
              ip.username AS influencer_username, u2.name AS influencer_name
       FROM offers o
       JOIN brand_profiles bp ON bp.user_id = o.brand_user_id
       LEFT JOIN influencer_profiles ip ON ip.user_id = o.influencer_user_id
       LEFT JOIN users u2 ON u2.id = o.influencer_user_id
       WHERE o.id = ?`,
      [id]
    );
    return rows[0] ?? null;
  },

  async updateStatus(id: number, userId: number, status: string) {
    const allowed = [
      'draft','open','offered','negotiation','accepted','in_progress',
      'submitted','completed','rejected','cancelled',
    ];
    if (!allowed.includes(status)) throw new ApiError(400, 'Invalid status');

    const [rows] = await pool.query<DbRow[]>(
      'SELECT brand_user_id, influencer_user_id, title FROM offers WHERE id = ?',
      [id]
    );
    if (!rows.length) throw new ApiError(404, 'Offer not found');
    const offer = rows[0] as { brand_user_id: number; influencer_user_id: number; title: string };

    if (userId !== offer.brand_user_id && userId !== offer.influencer_user_id) {
      throw new ApiError(403, 'Not allowed to change this offer');
    }

    await pool.query('UPDATE offers SET status = ? WHERE id = ?', [status, id]);

    const notifyUser = userId === offer.brand_user_id ? offer.influencer_user_id : offer.brand_user_id;
    await pool.query(
      `INSERT INTO notifications (user_id, type, title, body, icon)
       VALUES (?, 'status', ?, ?, 'sync')`,
      [notifyUser, 'Status updated', `${offer.title} is now ${status}`]
    );
    return this.getById(id);
  },
};
