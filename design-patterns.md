# Design Patterns — Konekta Backend

File ini menjelaskan setiap design pattern yang diterapkan di backend, **file mana** yang menggunakannya, **mengapa** dipakai, dan **bagaimana** cara kerjanya.

---

## Daftar File Backend

```
backend/src/
├── app.ts
├── server.ts
├── config/
│   └── db.ts
├── controllers/
│   ├── auth.controller.ts
│   ├── chat.controller.ts
│   ├── dashboard.controller.ts
│   ├── discovery.controller.ts
│   ├── notification.controller.ts
│   ├── offer.controller.ts        ← pakai Builder + Observer
│   └── profile.controller.ts
├── routes/
│   └── ...
├── middlewares/
│   └── ...
├── utils/
│   └── ...
└── services/
    ├── campaignBuilder.ts         ← BUILDER PATTERN
    ├── campaignState.ts           ← STATE PATTERN
    ├── socialMediaAdapters.ts     ← ADAPTER PATTERN
    ├── socialMediaFacade.ts       ← FACADE PATTERN
    ├── eventBus.ts                ← OBSERVER PATTERN
    ├── offer.service.ts           ← pakai Builder + Observer
    ├── notification.service.ts    ← pakai Observer
    └── ...
```

---

## 1. Creational — Builder Pattern

**File:** [backend/src/services/campaignBuilder.ts](backend/src/services/campaignBuilder.ts)

**Digunakan di:** `offer.controller.ts` (create endpoint)

### Tujuan
Membuat objek Campaign (Offer) yang memiliki 15+ properti secara terstruktur dan chainable, tanpa constructor yang panjang dan error-prone.

### Cara Kerja
```typescript
const campaign = await new CampaignBuilder()
  .setBrand(brandUserId)
  .setInfluencer(influencerUserId)
  .setTitle('Summer Launch')
  .setBudget(50000)
  .setTargets(50000, 5000, 200)
  .setDeliverables('1 TikTok + 1 IG Story')
  .setDeadline('2025-07-01')
  .build();
```

- Setiap `setXxx()` method mengembalikan `this` (builder instance), sehingga bisa di-chain.
- `build()` melakukan validasi final, eksekusi INSERT, dan mengirim notifikasi ke influencer.
- Properti opsional punya default value, properti wajib harus diset sebelum build.

### Mengapa Builder?
- Offer memiliki 15+ field. Constructor dengan 15 parameter tidak bisa dibaca.
- Builder memungkinkan partial configuration — developer hanya set field yang relevan.
- Validasi dilakukan di satu tempat (`build()`), bukan tersebar di service layer.

---

## 2. Structural — Adapter Pattern

**File:** [backend/src/services/socialMediaAdapters.ts](backend/src/services/socialMediaAdapters.ts)

**Digunakan di:** `socialMediaFacade.ts`, `dashboard.service.ts` (analitik)

### Tujuan
Menyamakan API berbagai platform sosial media (TikTok, Instagram, YouTube) yang punya endpoint, auth, dan response format berbeda-beda menjadi satu interface seragam (`ISocialMediaAdapter`).

### Interface Seragam
```typescript
export interface ISocialMediaAdapter {
  getMetrics(postId: string): Promise<SocialMediaMetrics>;
  publish(content: PostContent): Promise<PostContent>;
  fetchCampaignReport(offerId: number): Promise<PlatformReport>;
}
```

### Adapter per Platform

| Adapter | File | API yang Diadaptasi |
|---------|------|---------------------|
| `TikTokAdapter` | socialMediaAdapters.ts | TikTok Marketing API (`open.tiktokapis.com`) |
| `InstagramAdapter` | socialMediaAdapters.ts | Instagram Graph API (`graph.facebook.com`) |
| `YouTubeAdapter` | socialMediaAdapters.ts | YouTube Data API (`youtube.googleapis.com`) |

### Mengapa Adapter?
- TikTok API pakai OAuth2 bearer token + `/v2/post/public/list/`
- Instagram Graph API pakai Page Access Token + `/v18.0/{media-id}`
- YouTube Data API pakai API Key + `/v3/videos?part=statistics`
- Masing-masing punya format response yang berbeda. Adapter menyembunyikan semua perbedaan ini di balik 1 interface.
- Menambah platform baru (Twitter, Facebook) cukup membuat class baru yang implement `ISocialMediaAdapter`, tanpa mengubah kode yang sudah ada.

---

## 3. Structural — Facade Pattern

**File:** [backend/src/services/socialMediaFacade.ts](backend/src/services/socialMediaFacade.ts)

**Digunakan di:** `offer.controller.ts`, `dashboard.service.ts`

### Tujuan
Menyederhanakan akses ke berbagai layanan TikTok, Instagram, YouTube menjadi satu interface sederhana. Developer tidak perlu tahu adapter mana yang aktif, bagaimana meng-instantiate, atau bagaimana menggabungkan hasil dari multiple platform.

### Method Facade
```typescript
const facade = new SocialMediaFacade();

// Satu call → dapatkan laporan gabungan dari semua platform
const summary = await facade.getCampaignSummary(offerId);
// { platforms: [reportTikTok, reportIG], combined: { totalViews: 100000, ... } }

// Satu call → publish ke platform tertentu
await facade.publishPost('tiktok', userId, { url: 'video.mp4' });

// Satu call → sync metrics dari semua platform ke DB
await facade.syncMetrics(offerId);
```

### Mengapa Facade?
- Tanpa facade: controller/service perlu tahu `TikTokAdapter`, `InstagramAdapter`, harus instantiate masing-masing, loop manual, gabung hasil.
- Dengan facade: cukup panggil `getCampaignSummary(offerId)` — facade di bawahnya yang mencari semua platform connected, panggil adapter yang sesuai, dan gabung hasilnya.
- Facade = "front desk" yang menangani semua kompleksitas di belakangnya.

---

## 4. Behavioral — Observer Pattern

**File:** [backend/src/services/eventBus.ts](backend/src/services/eventBus.ts)

**Digunakan di:** `offer.service.ts`, `campaignState.ts`, `socialMediaFacade.ts`, `notification.service.ts`

### Tujuan
Memisahkan concern antara "event terjadi" dengan "respons terhadap event". Tidak perlu hardcoded `notify()` call di setiap service. Event yang sama bisa memicu banyak respons otomatis (notifikasi + analytics + activity log).

### EventBus (Subject/Publisher)
```typescript
const eventBus = new EventBus();

// Publish event
await eventBus.publish('campaign.status_changed', {
  offer_id: 1,
  user_id: 5,
  title: 'Campaign Status Changed',
});
```

### 3 Subscribers (Observers)
Setiap event type punya multiple observers yang dijalankan **konkuren**:

| Subscriber | File | Tujuan |
|------------|------|--------|
| `notificationSubscriber` | eventBus.ts | Buat entry di tabel `notifications` |
| `analyticsSubscriber` | eventBus.ts | Track performance di `analytics_logs` |
| `activityLogSubscriber` | eventBus.ts | Audit trail di `activity_logs` |

### Event Types yang Diterima

| Event | Dicontohkan di | Subscribers |
|-------|----------------|-------------|
| `campaign.created` | `campaignBuilder.ts` → `build()` | notify, analytics, log |
| `campaign.status_changed` | `campaignState.ts` → `transition()` | notify, log |
| `campaign.completed` | `campaignState.ts` → `transition()` | notify, analytics, log |
| `campaign.cancelled` | `campaignState.ts` → `transition()` | notify, log |
| `campaign.rejected` | `campaignState.ts` → `transition()` | notify, log |
| `application.approved` | `campaignState.ts` → `transition()` | notify, log |
| `application.rejected` | `campaignState.ts` → `transition()` | notify, log |
| `metrics.synced` | `socialMediaFacade.ts` → `syncMetrics()` | analytics |
| `message.sent` | `chat.service.ts` (akan datang) | log |

### Mengapa Observer?
- **Tanpa Observer:** Setiap service harus langsung panggil `notificationService.create()`, `analyticsService.track()`, `activityLog.create()` — hardcode,重复 code, sulit maintain.
- **Dengan Observer:** Service cukup `await eventBus.publish('event.name', payload)`. Semua subscriber otomatis dipanggil. Tambah subscriber baru = hanya subscribe, tidak ubah kode existing.
- `Promise.allSettled` memastikan error di satu subscriber tidak mengganggu subscriber lain.

### Contoh Integrasi di offer.service.ts (sebelum vs sesudah)

**Sebelum (hardcoded):**
```typescript
// Di offerService.updateStatus():
await pool.query('UPDATE offers SET status = ? WHERE id = ?', [status, id]);
// Notifikasi hardcoded → harus copy-paste di setiap service yang update status
await pool.query(`INSERT INTO notifications ...`, [notifyUser, 'Status updated', ...]);
```

**Sesudah (Observer):**
```typescript
// Di campaignState.ts transition():
await pool.query('UPDATE offers SET status = ? WHERE id = ?', [toState, offerId]);

// Publish event → semua subscriber otomatis di-trigger
await eventBus.publish('campaign.status_changed', {
  offer_id,
  user_id: userId,
  title: offer.title,
  from_state: fromState,
  to_state: toState,
});
```

---

## 5. Behavioral — State Pattern

**File:** [backend/src/services/campaignState.ts](backend/src/services/campaignState.ts)

**Digunakan di:** `offer.controller.ts` (updateStatus endpoint), `offer.service.ts`

### Tujuan
Mengemas semua aturan transisi status Campaign (Offer) dan Application ke dalam state objects, bukan if-else atau switch-case yang tersebar. Setiap state tahu transisi apa yang valid darinya.

### State Machine Campaign (Offer)

```
draft → open → offered → negotiation → accepted → in_progress → submitted → completed
  │       │       │          │            │
  └───────┼───────┼──────────┼────────────┼── rejected
          │       │          │            │
          └───────┴──────────┴────────────┼── cancelled
                                         │
                                         └── (semua state bisa → cancelled)
```

| State | Valid Transitions | Keterangan |
|-------|-------------------|------------|
| `draft` | open, rejected, cancelled | Belum dipublikasi |
| `open` | offered, rejected, cancelled | Aktif, bisa diterima influencer |
| `offered` | negotiation, accepted, rejected, cancelled | Influencer menerima/tolak |
| `negotiation` | accepted, rejected, cancelled | Negosiasi budget/deliverable |
| `accepted` | in_progress, rejected, cancelled | Kontrak disepakati |
| `in_progress` | submitted, cancelled | Influencer sedang bikin konten |
| `submitted` | completed, rejected | Konten dikirim, brand review |
| `completed` | *(none)* | Terminal — campaign selesai |
| `rejected` | *(none)* | Terminal — ditolak |
| `cancelled` | *(none)* | Terminal |

### State Machine Application

```
pending → approved → completed
     │         │
     │         └── (bisa → rejected)
     └───────────┘ (bisa → rejected langsung dari pending)
```

| State | Valid Transitions |
|-------|-------------------|
| `pending` | approved, rejected |
| `approved` | completed, rejected |
| `rejected` | *(none)* |
| `completed` | *(none)* |

### Cara Kerja
```typescript
const campaignState = new CampaignStateMachine();

// Cek validasi → state machine yang memutuskan
const isValid = campaignState.isValidTransition('in_progress', 'completed');
// false → tidak boleh skip submitted → completed

// Eksekusi transisi
const result = await campaignState.transition(offerId, userId, 'in_progress', 'submitted');
// result.success === true
// DB otomatis update status
// Notifikasi otomatis dikirim ke influencer/brand
```

### Mengapa State Pattern?
- **Tanpa State Pattern:** Setiap service punya `if (!allowed.includes(status))` hardcoded, validasi status spread di controller, service, dan migration. Sulit tambah state baru.
- **Dengan State Pattern:** Semua aturan transisi terenkapsulasi di `CampaignStates`. Tambah state baru = tambah entry di `CampaignStates`, tidak ubah kode existing (Open/Closed Principle).
- `onEnter` hook memungkinkan eksekusi logic otomatis saat state berubah (misal: saat `in_progress` aktif, trigger analytics tracking).
- `ApplicationStateMachine` mengikuti pola yang sama untuk `campaign_applicants`.

---

## Ringkasan Pola & Lokasi

| Pattern | Kategori | File | Digunakan Oleh |
|---------|----------|------|----------------|
| **Builder** | Creational | `services/campaignBuilder.ts` | `offer.controller.ts` (create) |
| **Adapter** | Structural | `services/socialMediaAdapters.ts` | `socialMediaFacade.ts`, `dashboard.service.ts` |
| **Facade** | Structural | `services/socialMediaFacade.ts` | `offer.controller.ts`, `dashboard.service.ts` |
| **Observer** | Behavioral | `services/eventBus.ts` | `offer.service.ts`, `campaignState.ts`, `socialMediaFacade.ts` |
| **State** | Behavioral | `services/campaignState.ts` | `offer.controller.ts`, `offer.service.ts` |

---

## Dependency Graph

```
               ┌──────────────┐
               │  eventBus.ts │  ← Observer (semua event lewat sini)
               └──────┬───────┘
                      │ publish
        ┌─────────────┼──────────────┐
        ▼             ▼              ▼
  notification    analytics      activity
  subscriber     subscriber      subscriber
        │             │              │
        └──────┬──────┴──────┬───────┘
               ▼             ▼
          notifications    analytics_     activity_
          (table)          logs (table)   logs (table)


          ┌─────────────────────┐
          │   campaignState.ts  │  ← State Pattern
          │  (CampaignStateMachine)
          │  (ApplicationStateMachine)
          └──────────┬──────────┘
                     │ transition()
                     │ publish('campaign.status_changed')
                     ▼
                ┌────────────┐
                │ eventBus.ts│  ← Observer (triggered by state)
                └────────────┘


          ┌─────────────────────────┐
          │ socialMediaAdapters.ts  │  ← Adapter Pattern
          │  TikTokAdapter          │
          │  InstagramAdapter       │
          │  YouTubeAdapter         │
          └────��─────┬──────────────┘
                     │ semua implement ISocialMediaAdapter
                     ▼
          ┌─────────────────────────┐
          │  socialMediaFacade.ts   │  ← Facade Pattern
          │  (SocialMediaFacade)    │
          │  getCampaignSummary()   │
          │  syncMetrics()          │
          │  publishPost()          │
          └──────────┬──────────────┘
                     │ panggil adapter yang sesuai
                     ▼
          socialMediaAdapters.ts


          ┌─────────────────────────┐
          │   campaignBuilder.ts    │  ← Builder Pattern
          │   CampaignBuilder       │
          │                         │
          │   new CampaignBuilder() │
          │     .setBrand(x)        │
          │     .setTitle(y)        │
          │     .setBudget(z)       │
          │     .build()            │
          └─────────────────────────┘
```
