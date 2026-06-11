# Backend Features - Konekta API

Stack: **Node.js + Express + TypeScript + MySQL**

---

## 1. Authentication (`/auth`)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| POST | `/auth/register` | Daftar akun baru (influencer / brand) |
| POST | `/auth/login` | Login email & password, return JWT |
| POST | `/auth/logout` | Logout (client-side, stateless JWT) |
| POST | `/auth/forgot-password` | Alur reset password |
| GET | `/auth/google` | Redirect ke Google OAuth |
| POST | `/auth/google/callback` | Callback OAuth2 dari Google |
| POST | `/auth/google/exchange` | Tukar Google token (mobile) |
| POST | `/auth/google/idtoken` | Verifikasi Google idToken langsung |

- Password di-hash dengan bcrypt
- JWT untuk autentikasi stateless
- Profil otomatis dibuat saat register
- Support Google Sign-In untuk web & mobile

---

## 2. Profile (`/profile`)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/profile/me` | Ambil profil user yang sedang login |
| PUT | `/profile/me` | Update profil umum (nama, avatar, bio, lokasi) |
| PUT | `/profile/brand` | Update profil brand (nama brand, industri, logo, website) |
| POST | `/profile/influencer/social-media` | Tambah akun media sosial |

- Profil terpisah antara influencer dan brand
- Influencer: niche, followers, engagement rate, rate card, media kit, info payout
- Brand: brand name, industri, website, logo

---

## 3. Discovery (publik, tanpa auth)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/influencers` | Cari influencer dengan filter |
| GET | `/influencers/:id` | Detail profil influencer |
| GET | `/brands` | Cari brand dengan filter |
| GET | `/brands/:id` | Detail profil brand |

- Filter: niche, lokasi, platform, jumlah followers, engagement rate
- Pagination, full-text search
- Menampilkan metrik kampanye (aktif / selesai)

---

## 4. Offers / Campaigns (`/offers`)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/offers` | List offer publik (untuk Explore screen) |
| GET | `/offers/mine` | Offer milik user (brand: offer dibuat, influencer: offer yang dilamar) |
| GET | `/offers/applications/mine` | List lamaran influencer |
| POST | `/offers` | Brand buat offer baru |
| GET | `/offers/:id` | Detail offer (publik) |
| PUT | `/offers/:id` | Update offer |
| POST | `/offers/:id/apply` | Influencer melamar ke offer |
| GET | `/offers/:id/applicants` | Brand lihat semua pelamar |
| GET | `/offers/:id/applicants/:appId` | Brand lihat detail satu pelamar |
| PATCH | `/offers/:id/applicants/:appId/status` | Brand approve / reject / shortlist |
| POST | `/offers/:id/progress` | Tambah milestone/progres campaign |
| GET | `/offers/:id/progress` | Lihat riwayat progres |

- Status offer: `draft` → `open` → `in_progress` → `completed`
- Status lamaran: `pending` → `approved` / `rejected` / `shortlisted`
- Saat satu pelamar di-approve, pelamar lain otomatis ditolak (transaksi DB)
- Tracking progres dengan milestone

---

## 5. Chat / Conversations (`/conversations`)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/conversations` | List semua percakapan user |
| POST | `/conversations/ensure` | Buat atau ambil percakapan antara dua user |
| GET | `/conversations/:id/messages` | Ambil semua pesan dalam percakapan |
| POST | `/conversations/:id/messages` | Kirim pesan (maks 2000 karakter) |

- Chat dua arah antara brand dan influencer
- Auto-buat percakapan jika belum ada
- Verifikasi membership sebelum boleh membaca/mengirim

---

## 6. Notifications (`/notifications`)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/notifications` | List notifikasi user (maks 200) |
| GET | `/notifications/unread-count` | Jumlah notifikasi belum dibaca |
| POST | `/notifications/read` | Tandai notifikasi tertentu sudah dibaca |
| POST | `/notifications/read-all` | Tandai semua sudah dibaca |

- Tipe notifikasi: `campaign_target`, `message`, `payment`, `verification`, `application`
- Status read/unread per notifikasi

---

## 7. Dashboard (`/dashboard`)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/dashboard/overview` | Overview sesuai role user |
| GET | `/dashboard/influencer` | Dashboard influencer (lamaran, earnings, followers) |
| GET | `/dashboard/brand` | Dashboard brand (offer, pelamar, budget) |

- Data berbeda tergantung role (influencer / brand)
- Menampilkan KPI utama per role

---

## 8. Analytics (`/analytics`)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/analytics/brand` | Analitik brand: offer aktif/selesai, pengeluaran, niche teratas, time-series |
| GET | `/analytics/influencer` | Analitik influencer: lamaran, approval rate, earnings, engagement, tren 30 hari |

- Rolling 30-hari untuk data tren
- KPI cards + breakdown per niche

---

## 9. Subscription (`/subscriptions`)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/subscriptions/plans` | List semua paket (Free, Pro Monthly, Pro Annual) |
| GET | `/subscriptions/mine` | Paket aktif user saat ini |
| POST | `/subscriptions/subscribe` | Subscribe ke paket tertentu |
| POST | `/subscriptions/cancel` | Batalkan langganan aktif |

- 3 tier: Free / Pro Monthly (Rp 149K) / Pro Annual (Rp 1.5M)
- Auto-expiry 30 hari
- Riwayat invoice tersimpan

---

## 10. Social Media (`/social`)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/social/mine` | List akun sosmed yang terhubung |
| DELETE | `/social/mine/:id` | Hapus akun sosmed |
| POST | `/social/mine` | Tambah akun sosmed |

- Platform: Instagram, TikTok, YouTube, Twitter, Facebook, Other
- Tracking followers & engagement per platform

---

## Arsitektur

```
routes → controllers (Zod validation) → services (business logic + DB) → MySQL
```

- **Auth middleware** (`requireAuth`) melindungi semua endpoint yang butuh login
- **Role-based access** — beberapa endpoint hanya bisa diakses brand atau influencer
- **Parameterized queries** — mencegah SQL injection
- **Zod** — validasi input di semua endpoint yang menerima body
- **Error handling** terpusat via `errorHandler` middleware
