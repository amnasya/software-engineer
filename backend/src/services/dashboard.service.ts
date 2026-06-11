import { pool, DbRow } from '../config/db';

export const dashboardService = {
  async influencerOverview(userId: number) {
    const [[profile]] = await pool.query<DbRow[]>(
      'SELECT followers_count, engagement_rate FROM influencer_profiles WHERE user_id = ?',
      [userId]
    );

    // Count active/completed from campaign_applicants (correct source for influencer campaigns)
    const [[counts]] = await pool.query<DbRow[]>(
      `SELECT
         SUM(CASE WHEN o.status = 'in_progress' THEN 1 ELSE 0 END) AS active,
         SUM(CASE WHEN o.status = 'completed'   THEN 1 ELSE 0 END) AS completed,
         SUM(CASE WHEN ca.status = 'pending'    THEN 1 ELSE 0 END) AS pending_proposals
       FROM campaign_applicants ca
       JOIN offers o ON o.id = ca.offer_id
       WHERE ca.influencer_user_id = ?`,
      [userId]
    );

    const [campaigns] = await pool.query<DbRow[]>(
      `SELECT o.id, o.title, o.brief, o.status, o.budget, o.deadline, o.created_at,
              ca.status AS application_status, ca.progress,
              bp.brand_name
       FROM campaign_applicants ca
       JOIN offers o ON o.id = ca.offer_id
       LEFT JOIN brand_profiles bp ON bp.user_id = o.brand_user_id
       WHERE ca.influencer_user_id = ? AND ca.status IN ('approved', 'pending')
       ORDER BY o.created_at DESC
       LIMIT 5`,
      [userId]
    );

    const p = profile as { followers_count?: number; engagement_rate?: number } | undefined;
    const c = counts as { active?: number; completed?: number; pending_proposals?: number } | undefined;

    return {
      summary: {
        audience_reached: p?.followers_count ?? 0,
        engagement_rate: p?.engagement_rate ?? 0,
        total_interactions: 0,
        completed_campaigns: c?.completed ?? 0,
        active_campaigns: c?.active ?? 0,
        pending_proposals: c?.pending_proposals ?? 0,
      },
      active_campaigns: campaigns,
    };
  },

  async brandOverview(userId: number) {
    const [[counts]] = await pool.query<DbRow[]>(
      `SELECT
         COUNT(DISTINCT o.influencer_user_id) AS creators_hired,
         COALESCE(SUM(o.budget), 0)           AS total_budget,
         COUNT(o.id)                          AS campaigns_created,
         SUM(CASE WHEN o.status = 'in_progress' THEN 1 ELSE 0 END) AS active_campaigns,
         SUM(CASE WHEN o.status = 'completed'   THEN 1 ELSE 0 END) AS completed_campaigns
       FROM offers o WHERE o.brand_user_id = ?`,
      [userId]
    );

    const [[perf]] = await pool.query<DbRow[]>(
      `SELECT
         AVG(ip.engagement_rate)              AS avg_engagement,
         COALESCE(SUM(ip.followers_count), 0) AS total_followers
       FROM offers o
       JOIN influencer_profiles ip ON ip.user_id = o.influencer_user_id
       WHERE o.brand_user_id = ?`,
      [userId]
    );

    const [[approvals]] = await pool.query<DbRow[]>(
      `SELECT COUNT(*) AS cnt FROM campaign_applicants ca
       JOIN offers o ON o.id = ca.offer_id
       WHERE o.brand_user_id = ? AND ca.status = 'pending'`,
      [userId]
    );

    const [recent_campaigns] = await pool.query<DbRow[]>(
      `SELECT o.id, o.title, o.deadline, o.status, o.budget, o.room_code,
              o.is_public,
              (SELECT COUNT(*) FROM campaign_applicants ca2 WHERE ca2.offer_id = o.id) AS applicants_count,
              ip.username AS influencer_username, u2.name AS influencer_name
       FROM offers o
       LEFT JOIN influencer_profiles ip ON ip.user_id = o.influencer_user_id
       LEFT JOIN users u2 ON u2.id = o.influencer_user_id
       WHERE o.brand_user_id = ?
       ORDER BY o.created_at DESC
       LIMIT 5`,
      [userId]
    );

    const ap = approvals as { cnt?: number } | undefined;
    const cf = perf as { avg_engagement?: number; total_followers?: number } | undefined;
    const co = counts as {
      creators_hired?: number; total_budget?: number; campaigns_created?: number;
      active_campaigns?: number; completed_campaigns?: number;
    } | undefined;

    return {
      summary: {
        audience_reached: Number(cf?.total_followers ?? 0),
        engagement_rate: Number((cf?.avg_engagement ?? 0)),
        total_interactions: 0,
        completed_campaigns: co?.completed_campaigns ?? 0,
        active_campaigns: co?.active_campaigns ?? 0,
        pending_approvals: ap?.cnt ?? 0,
        creators_hired: co?.creators_hired ?? 0,
        total_budget: co?.total_budget ?? 0,
        campaigns_created: co?.campaigns_created ?? 0,
      },
      stats: {
        total_campaigns: co?.campaigns_created ?? 0,
        active_campaigns: co?.active_campaigns ?? 0,
        completed_campaigns: co?.completed_campaigns ?? 0,
        total_budget: co?.total_budget ?? 0,
      },
      recent_campaigns,
    };
  },
};
