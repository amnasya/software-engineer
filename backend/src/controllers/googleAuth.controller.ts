import { Request, Response } from 'express';
import { OAuth2Client, LoginTicket } from 'google-auth-library';
import { client, clientId } from '../config/googleOAuth';
import User from '../models/User';
import BearerToken from '../models/BearerToken';

function googleAuthUrl() {
  return client.generateAuthUrl({
    access_type: 'offline',
    prompt: 'consent',
    scope: ['email', 'profile'],
  });
}

export async function googleAuth(_req: Request, res: Response) {
  const url = googleAuthUrl();
  res.redirect(url);
}

export async function googleAuthMobile(req: Request, res: Response) {
  const url = googleAuthUrl();
  res.json({ auth_url: url });
}

/// Payload yang sama dipakai di semua response Google login (frontend expect
/// `data.token`, `data.user`).
type GxResult = { token: string; user: { id: number; email: string; name: string }; expires_at: Date };

async function _buildResult(userId: number): Promise<GxResult> {
  const tokenData = await BearerToken.create(userId);
  const user = await User.findById(userId);
  if (!user) throw new Error('User not found');
  return {
    token: tokenData.token,
    user: { id: user.id, email: user.email, name: user.name ?? '' },
    expires_at: tokenData.expiresAt,
  };
}

export async function googleCallback(req: Request, res: Response) {
  try {
    const { code } = req.query;
    if (!code) return res.status(400).json({ error: 'Authorization code required' });

    const { tokens } = await client.getToken(code as string);
    client.setCredentials(tokens);

    const ticket: LoginTicket = await client.verifyIdToken({
      idToken: tokens.id_token ?? '',
      audience: process.env.GOOGLE_CLIENT_ID ?? '',
    });

    const payload = ticket.getPayload();
    if (!payload) throw new Error('No payload');

    const { email, name, sub: googleId } = payload;

    const user = await User.findOrCreateOAuth({
      email: email ?? '', name: name ?? '', provider: 'google', providerId: googleId ?? '',
    });

    const result = await _buildResult(user.id);
    res.json({ success: true, message: 'Google OAuth login successful', data: result });
  } catch (err) {
    console.error('Google callback error:', err);
    res.status(401).json({ error: 'Google authentication failed' });
  }
}

export async function googleExchange(req: Request, res: Response) {
  try {
    const { code } = req.body;
    if (!code) return res.status(400).json({ error: 'Authorization code is required' });

    const { tokens } = await client.getToken(code);
    client.setCredentials(tokens);

    const ticket: LoginTicket = await client.verifyIdToken({
      idToken: tokens.id_token ?? '',
      audience: process.env.GOOGLE_CLIENT_ID ?? '',
    });

    const payload = ticket.getPayload();
    if (!payload) throw new Error('No payload');

    const { email, name, sub: googleId } = payload;

    const user = await User.findOrCreateOAuth({
      email: email ?? '', name: name ?? '', provider: 'google', providerId: googleId ?? '',
    });

    const result = await _buildResult(user.id);
    res.json({ success: true, message: 'Google OAuth login successful', data: result });
  } catch (err) {
    console.error('Google exchange error:', err);
    res.status(401).json({ error: 'Google authentication failed' });
  }
}

/// Verifikasi Google idToken yang dikirim langsung dari mobile (google_sign_in
/// plugin). idToken sudah ditandatangani oleh Google untuk client ID kita, jadi
/// cukup verify audience-nya lalu lanjut ke flow user yang sama.
export async function googleIdToken(req: Request, res: Response) {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ error: 'idToken is required' });

    const verifier = new OAuth2Client(clientId);
    const ticket: LoginTicket = await verifier.verifyIdToken({
      idToken,
      audience: clientId,
    });

    const payload = ticket.getPayload();
    if (!payload) throw new Error('No payload');

    const { email, name, sub: googleId } = payload;

    const user = await User.findOrCreateOAuth({
      email: email ?? '', name: name ?? '', provider: 'google', providerId: googleId ?? '',
    });

    const result = await _buildResult(user.id);
    res.json({ success: true, message: 'Google OAuth login successful', data: result });
  } catch (err) {
    console.error('Google idToken error:', err);
    res.status(401).json({ error: 'Google authentication failed' });
  }
}
