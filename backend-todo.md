# Backend — Daftar yang Harus Diperbaiki & Dibuat

Hasil audit menyeluruh: membandingkan semua API call dari Flutter vs implementasi backend.

---

## 🔴 KRITIS — Bug yang Menyebabkan Error Saat ini

### 1. Schema DB tidak cocok dengan query di service

**`analytics.service.ts`** menggunakan tabel dan kolom yang tidak ada di `schema.sql`:

| Yang dipakai di service | Yang ada di schema |
|---|---|
| `FROM campaigns` | Tidak ada — tabelnya `offers` |
| `FROM applicants` | Tidak ada — tabelnya `campaign_applicants` atau `offer_applications` |
| `o.proposed_rate` | Tidak ada di tabel `offers` |
| `o.reach`, `o.engagement` | Tidak ada di tabel `offers` |
| `JOIN campaigns c ON c.id = o.campaign_id` | Kolom `campaign_id` tidak ada di `offers` |

**`dashboard.service.ts`** juga bermasalah:
- Query `FROM campaign_applicants ca JOIN offers o ON o.id = ca.offer_id WHERE o.influencer_user_id = ?` — padahal `influencer_user_id` di tabel `offers` sekarang **nullable** dan bukan penanda "offer milik influencer ini"
- `campaign_applicants` dan `offer_applications` dipakai bergantian — hanya satu yang ada di schema

**`offer.service.ts`**:
- `INSERT INTO offers` menggunakan kolom `description`, `niche`, `deliverable`, `platforms` — kolom-kolom ini tidak ada di `schema.sql` (schema punya `brief`, `deliverables`, `requirements`)
- `INSERT INTO offer_applications` — tabel ini tidak ada di schema, yang ada adalah `campaign_applicants`
- `INSERT INTO offer_progress` — tabel `offer_progress` tidak ada di schema sama sekali

**`subscription.service.ts`**:
- Query ke tabel `subscriptions` dan `subscription_plans` — tidak ada di schema
- Query ke kolom `brand_profiles.subscription_plan` dan `subscription_expires_at` — tidak ada di schema

**`chat.service.ts`**:
- `INSERT INTO messages` menggunakan kolom `body` — schema punya `message_text`
- `UPDATE conversations SET last_message` — kolom `last_message` tidak ada di schema conversations

**`notification.service.ts`**:
- Kolom `data` dan `is_read` di tabel `notifications` — schema punya `read_status` bukan `is_read`, dan tidak ada kolom `data`

---

### 2. Flutter memanggil endpoint yang tidak ada / salah path

| Flutter memanggil | Backend tersedia | Status |
|---|---|---|
| `POST /conversations` body: `{other_user_id}` | `POST /conversations/ensure` body: `{brand_user_id, influencer_user_id}` | ❌ Path & body beda |
| `POST /offers/:id/applicants` | `POST /offers/:id/apply` | ❌ Path beda |
| `GET /subscriptions/me` | `GET /subscriptions/mine` | ❌ Path beda |
| `POST /notifications/:id/read` | `POST /notifications/read` body: `{ids:[]}` | ❌ Pattern beda |
| `GET /brands` (dari discovery) | Tidak dimount di `app.ts` — hanya `/influencers` | ❌ Route tidak terdaftar |

**`app.ts`** mount: `app.use('/', discoveryRoutes)` — ini hanya expose `/influencers` dan `/brands` tapi tanpa prefix. Itu OK, tapi perlu dipastikan tidak bentrok dengan route lain.

---

### 3. Subscription — Flutter kirim `plan_id` (int), backend expect `plan_code` (string)

Flutter (`subscription_repository.dart`):
```dart
_api.post('/subscriptions/subscribe', {'plan_id': planId})  // kirim int
```

Backend (`subscription.controller.ts`):
```typescript
const code = String(req.body?.plan_code ?? '')  // baca plan_code string
```

Data tidak akan ter-proses karena field name berbeda.

---

### 4. Discovery service menggunakan query SQL yang salah

`discovery.service.ts` `listInfluencers`:
```sql
JOIN campaigns c ON c.id = o.campaign_id  -- tabel campaigns tidak ada
```
Query ini akan crash saat dipanggil.

---

## 🟡 PENTING — Fitur yang Belum Ada Sama Sekali

### 5. Tabel `offer_applications` tidak ada di schema

Backend `offer.service.ts` menggunakan `offer_applications` tapi schema punya `campaign_applicants`. Perlu diseragamkan — pilih satu nama dan konsisten.

Kolom yang perlu ditambah ke `campaign_applicants` agar service bisa jalan:
- `message TEXT NULL` — untuk pesan saat melamar
- `proposed_rate DECIMAL(15,2) NULL` — rate yang diajukan influencer

### 6. Tabel `offer_progress` belum ada

`offer.service.ts` punya `addProgress` dan `getProgress` yang INSERT/SELECT dari `offer_progress`, tapi tabel ini tidak ada di schema.

Perlu dibuat:
```sql
CREATE TABLE offer_progress (
    id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    offer_id            BIGINT UNSIGNED NOT NULL,
    influencer_user_id  BIGINT UNSIGNED NOT NULL,
    milestone           VARCHAR(120) NOT NULL,
    status              VARCHAR(40) NOT NULL,
    notes               TEXT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
```

### 7. Tabel `brand_subscriptions` tidak ada di schema

`subscription.controller.ts` query ke `brand_subscriptions` tapi schema tidak punya tabel ini. Ada `subscription_invoices` tapi strukturnya berbeda.

### 8. Dashboard influencer tidak mengembalikan format yang Flutter harapkan

Flutter (`dashboard_repository.dart`) expect:
```json
{ "summary": { "audience_reached", "engagement_rate", ... } }
```

Backend `dashboardService.influencerOverview` mengembalikan:
```json
{ "summary": { "audience_reached", ... }, "active_campaigns": [...] }
```

Tapi query-nya salah — mencari `WHERE influencer_user_id = ?` di tabel offers, padahal `influencer_user_id` sekarang nullable dan diisi hanya saat offer sudah assigned. Dashboard influencer seharusnya query dari `campaign_applicants` bukan langsung dari `offers`.

### 9. Endpoint `GET /subscriptions/me` vs `GET /subscriptions/mine`

Flutter memanggil `/subscriptions/me` tapi route yang ada adalah `/subscriptions/mine`. Salah satu perlu diubah agar konsisten.

### 10. Format response subscription tidak cocok dengan model Flutter

Flutter model `Subscription` (dari `subscription_repository.dart`) expect field:
- `plan_id` (int)
- `plan_name` (string)  
- `status`
- `expires_at`

Backend `subscriptionController.mine` mengembalikan:
```json
{ "plan": { "plan_code": "free" }, "history": [...] }
```

Format tidak cocok sama sekali.

---

## 🟠 PERLU DITAMBAHKAN — Fitur yang Dibutuhkan Frontend

### 11. `GET /offers` — response format tidak cocok

Flutter `CampaignRepository.listOffers` expect array langsung `[]`, tapi `listPublic` di controller memang return array — **ini sudah benar**. Namun `listForInfluencer` dan `listForBrand` (via `/offers/mine`) juga return array — OK.

Yang kurang: field `applicants_count` di response `listPublic`. Flutter card menampilkan jumlah pelamar tapi query di `listPublic` tidak menghitung applicants.

Perlu tambah subquery:
```sql
(SELECT COUNT(*) FROM campaign_applicants ca WHERE ca.offer_id = o.id) AS applicants_count
```

### 12. `POST /conversations` — Flutter buat conversation dengan `other_user_id` saja

`chat_repository.dart`:
```dart
api.post('/conversations', {'other_user_id': otherUserId})
```

Backend `/conversations/ensure` expect `{brand_user_id, influencer_user_id}`. Backend perlu bisa resolve siapa brand/influencer dari `other_user_id` + current user, atau Flutter perlu diubah — lebih mudah fix di backend dengan endpoint baru:

```
POST /conversations
body: { other_user_id: int }
```
Backend tentukan sendiri siapa brand/influencer berdasarkan role masing-masing user.

### 13. `POST /notifications/:id/read` tidak ada

Flutter:
```dart
api.post('/notifications/$id/read', {})
```

Backend hanya punya `POST /notifications/read` dengan body `{ids: []}`. Perlu tambah route:
```
POST /notifications/:id/read
```

### 14. `GET /brands` — response format

`discovery.service.listBrands` mengembalikan `{ page, limit, items: [] }` tapi Flutter `DiscoveryRepository.brands` melakukan `.cast<Map>()` langsung pada response — expect flat array, bukan object dengan `items`. Perlu diseragamkan.

Begitu juga `listInfluencers` — return `{ page, limit, items }` tapi `BrandExploreScreen` handle keduanya karena ada fallback:
```dart
(res is List) ? res : (res as Map)['items']
```
Jadi ini sudah aman. Tapi `DiscoveryRepository.influencers` tidak punya fallback — akan crash jika response bukan List.

### 15. Endpoint `GET /dashboard/brand` — field yang dikembalikan kurang

`BrandAnalyticsScreen` memanggil `/dashboard/brand` dan mengharapkan field `recent_campaigns` dan `stats`. Backend `brandOverview` mengembalikan `{ summary, rooms }` — tidak ada `recent_campaigns` atau `stats`.

---

## 🟢 SCHEMA — Yang Perlu Diperbaiki/Ditambah di `schema.sql`

```sql
-- 1. Tambah kolom ke campaign_applicants
ALTER TABLE campaign_applicants 
  ADD COLUMN message TEXT NULL AFTER influencer_user_id,
  ADD COLUMN proposed_rate DECIMAL(15,2) NULL AFTER message;

-- 2. Buat tabel offer_progress
CREATE TABLE offer_progress (
    id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    offer_id            BIGINT UNSIGNED NOT NULL,
    influencer_user_id  BIGINT UNSIGNED NOT NULL,
    milestone           VARCHAR(120) NOT NULL,
    status              VARCHAR(40) NOT NULL,
    notes               TEXT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_progress_offer (offer_id),
    CONSTRAINT fk_progress_offer FOREIGN KEY (offer_id) REFERENCES offers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Buat tabel brand_subscriptions
CREATE TABLE brand_subscriptions (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    brand_user_id   BIGINT UNSIGNED NOT NULL,
    plan_id         INT NOT NULL,
    plan_code       VARCHAR(40) NOT NULL,
    plan_name       VARCHAR(120) NOT NULL,
    status          ENUM('active','cancelled','expired') NOT NULL DEFAULT 'active',
    started_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at      TIMESTAMP NULL,
    cancelled_at    TIMESTAMP NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_bsub_brand (brand_user_id),
    CONSTRAINT fk_bsub_brand FOREIGN KEY (brand_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Fix kolom notifications
ALTER TABLE notifications 
  ADD COLUMN data JSON NULL AFTER body,
  ADD COLUMN is_read TINYINT(1) NOT NULL DEFAULT 0;
-- Atau: hapus read_status dan ganti dengan is_read

-- 5. Fix kolom conversations
ALTER TABLE conversations ADD COLUMN last_message TEXT NULL;

-- 6. Fix kolom messages: message_text → body (atau sebaliknya, seragamkan)
-- Schema punya message_text, chat.service.ts pakai body
```

---

## 📋 Ringkasan Prioritas

| Prioritas | Item | Dampak |
|---|---|---|
| 🔴 P1 | Fix nama tabel: `offer_applications` → `campaign_applicants` di semua service | App crash |
| 🔴 P1 | Fix kolom `offers`: `description/niche/deliverable` → `brief/deliverables/requirements` | Insert offer gagal |
| 🔴 P1 | Fix `messages.body` → `messages.message_text` di `chat.service.ts` | Chat tidak bisa kirim pesan |
| 🔴 P1 | Fix `notifications.is_read` → `read_status` di `notification.service.ts` | Notifikasi error |
| 🔴 P1 | Buat tabel `offer_progress` di schema | Progress endpoint crash |
| 🔴 P1 | Fix `analytics.service.ts` — hapus referensi ke tabel `campaigns` | Analytics crash total |
| 🟡 P2 | Fix path `POST /conversations` agar terima `other_user_id` | Chat tidak bisa dimulai |
| 🟡 P2 | Fix path `POST /offers/:id/apply` vs `/offers/:id/applicants` | Apply offer gagal |
| 🟡 P2 | Fix path `GET /subscriptions/mine` → `/me` | Subscription tidak load |
| 🟡 P2 | Fix format response subscription agar cocok dengan Flutter model | Subscription screen error |
| 🟡 P2 | Tambah `POST /notifications/:id/read` | Mark baca tidak berfungsi |
| 🟠 P3 | Tambah `applicants_count` di `GET /offers` | Jumlah pelamar tidak muncul |
| 🟠 P3 | Fix `dashboard/brand` tambah `recent_campaigns` dan `stats` | Brand analytics kosong |
| 🟠 P3 | Fix `subscription.controller` terima `plan_id` bukan `plan_code` | Subscribe tidak berfungsi |
