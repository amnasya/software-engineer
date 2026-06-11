import express, { Request, Response } from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.routes';
import profileRoutes from './routes/profile.routes';
import discoveryRoutes from './routes/discovery.routes';
import offerRoutes from './routes/offer.routes';
import chatRoutes from './routes/chat.routes';
import notificationRoutes from './routes/notification.routes';
import dashboardRoutes from './routes/dashboard.routes';
import googleAuthRoutes from './routes/googleAuth.routes';
import analyticsRoutes from './routes/analytics.routes';
import subscriptionRoutes from './routes/subscription.routes';
import { errorHandler } from './middlewares/error';

export const app = express();
app.use(cors());
app.use(express.json({ limit: '5mb' }));

app.get('/health', (_req: Request, res: Response) =>
  res.json({ success: true, message: 'Konekta API is running' })
);

app.use('/auth', authRoutes);
app.use('/auth', googleAuthRoutes);
app.use('/profile', profileRoutes);
app.use('/', discoveryRoutes); // /influencers, /brands
app.use('/offers', offerRoutes);
app.use('/conversations', chatRoutes);
app.use('/notifications', notificationRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/subscriptions', subscriptionRoutes);
app.use('/analytics', analyticsRoutes);

app.use((_req: Request, res: Response) =>
  res.status(404).json({ success: false, message: 'Endpoint not found' })
);
app.use(errorHandler);
