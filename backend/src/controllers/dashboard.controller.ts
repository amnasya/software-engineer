import { Request, Response, NextFunction } from 'express';
import { dashboardService } from '../services/dashboard.service';
import { ok } from '../utils/response';
import { ApiError } from '../utils/apiError';

export const dashboardController = {
  async overview(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user) throw new ApiError(401, 'Unauthenticated');
      const data = req.user.role === 'brand'
        ? await dashboardService.brandOverview(req.user.id)
        : await dashboardService.influencerOverview(req.user.id);
      return ok(res, data);
    } catch (e) { next(e); }
  },

  async influencer(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user) throw new ApiError(401, 'Unauthenticated');
      if (req.user.role !== 'influencer') throw new ApiError(403, 'Influencers only');
      const data = await dashboardService.influencerOverview(req.user.id);
      return ok(res, data);
    } catch (e) { next(e); }
  },

  async brand(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user) throw new ApiError(401, 'Unauthenticated');
      if (req.user.role !== 'brand') throw new ApiError(403, 'Brands only');
      const data = await dashboardService.brandOverview(req.user.id);
      return ok(res, data);
    } catch (e) { next(e); }
  },
};
