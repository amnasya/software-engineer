# Product Requirements Document (PRD)

## Konekta

**Platform:** Mobile App
**Frontend:** Flutter (Dart) -- > hanya flutter dart
**Backend:** Express.js (typescript)
**Database:** MySQL

---

ARSITEKTUR YANG DIGUNAKAN ADALAH MICRO-SERVICE

## 1. Ringkasan Produk

**Konekta** adalah aplikasi mobile yang menghubungkan **influencer** dan **brand** dalam satu platform. Aplikasi ini memiliki dua sisi pengguna:

* **Sisi Influencer**: mencari peluang endorsement, mengelola profil media sosial, menerima tawaran kerja sama, dan memantau status endorsement.
* **Sisi Brand**: mencari influencer yang relevan, melihat data performa/informasi influencer, mengirim penawaran kerja sama, dan memantau progres kampanye.

Tujuan utama aplikasi adalah mempermudah proses pencocokan, negosiasi, tracking, dan komunikasi antara influencer dan brand.

---

## 2. Tujuan Produk

1. Mempertemukan brand dan influencer secara efisien.
2. Menyediakan sistem pencarian dan filter yang relevan untuk kedua sisi.
3. Membantu influencer memantau semua endorsement dalam satu tempat.
4. Membantu brand menemukan influencer yang sesuai dengan kebutuhan campaign.
5. Meningkatkan transparansi status kerja sama melalui tracking yang jelas.

---

## 3. Masalah yang Diselesaikan

### Untuk Influencer

* Sulit menemukan brand yang cocok.
* Workflow endorsement tersebar di chat, email, dan spreadsheet.
* Sulit melacak status kerja sama yang sedang berjalan.

### Untuk Brand

* Sulit menemukan influencer yang tepat berdasarkan niche, audience, dan budget.
* Proses pencarian influencer memakan waktu.
* Kurangnya data terstruktur untuk membandingkan kandidat influencer.

---

## 4. Target Pengguna

### 4.1 Influencer

* Micro influencer
* Mid-tier influencer
* Content creator
* KOL / Key Opinion Leader

### 4.2 Brand

* UMKM
* Brand lokal
* Startup
* Agency marketing / talent management
* Enterprise brand yang menjalankan campaign influencer marketing

---

## 5. Value Proposition

### Untuk Influencer

* Mendapatkan peluang endorsement lebih cepat.
* Semua kerja sama tercatat rapi.
* Bisa memantau status penawaran dan deadline.

### Untuk Brand

* Lebih cepat menemukan influencer yang relevan.
* Data influencer lebih mudah dibandingkan.
* Proses campaign lebih terstruktur.

---

## 6. Product Scope

### 6.1 MVP Scope

Fitur inti yang harus ada pada versi pertama:

* Registrasi dan login
* Pilih role: Influencer / Brand
* Lengkapi profil sesuai role
* Pencarian dan filter influencer / brand
* Detail profil influencer / brand
* Kirim penawaran kerja sama
* Terima / tolak penawaran
* Tracking status endorsement/campaign
* Notifikasi dasar
* Chat atau messaging dasar
* Dashboard sederhana untuk masing-masing role

### 6.2 Out of Scope untuk MVP

* AI recommendation engine
* Payment escrow / payment gateway
* Contract signing digital advanced
* KYC lengkap
* Analytics campaign mendalam
* Multi-team management untuk brand
* Web admin panel kompleks

---

## 7. User Roles

### 7.1 Influencer

Fungsi utama:

* Membuat profil personal dan sosial media
* Menunjukkan niche, rate card, audience, dan media kit
* Menerima penawaran dari brand
* Melacak status endorsement
* Mengelola jadwal pekerjaan

### 7.2 Brand

Fungsi utama:

* Membuat profil brand/perusahaan
* Mencari influencer sesuai kebutuhan campaign
* Mengirim brief / penawaran
* Memantau progres campaign
* Mengelola daftar influencer yang disimpan

### 7.3 Admin (opsional untuk fase berikutnya)

* Moderasi user dan konten
* Verifikasi akun
* Menangani report / abuse
* Monitoring platform

---

## 8. User Journey

### 8.1 Influencer Journey

1. Daftar akun.
2. Pilih role influencer.
3. Lengkapi profil sosial media, niche, dan rate.
4. Masuk ke dashboard.
5. Cari brand atau menunggu offer masuk.
6. Terima penawaran.
7. Diskusi melalui chat.
8. Tracking status pekerjaan sampai selesai.

### 8.2 Brand Journey

1. Daftar akun.
2. Pilih role brand.
3. Lengkapi profil brand dan kebutuhan campaign.
4. Cari influencer berdasarkan filter.
5. Simpan kandidat atau kirim offer.
6. Diskusi dengan influencer.
7. Pantau status campaign.
8. Evaluasi hasil kerja sama.

---

## 9. Fitur Utama

### 9.1 Authentication

* Register
* Login
* Logout
* Forgot password
* Role selection saat onboarding

### 9.2 Profile Management

#### Influencer Profile

* Nama
* Foto profil
* Bio
* Niche / kategori konten
* Platform sosial media (Instagram, TikTok, YouTube, dll.)
* Jumlah followers
* Engagement rate
* Rate card
* Lokasi
* Portofolio / media kit

#### Brand Profile

* Nama brand
* Logo
* Deskripsi brand
* Industri
* Lokasi
* Website / social media
* Kategori campaign

### 9.3 Discovery / Search

#### Brand mencari influencer berdasarkan:

* Niche
* Lokasi
* Platform sosial media
* Range followers
* Engagement rate
* Budget
* Category
* Audience demographic (jika tersedia)

#### Influencer mencari brand berdasarkan:

* Kategori brand
* Lokasi
* Tipe campaign
* Budget range
* Status aktif campaign

### 9.4 Offer / Campaign Management

* Brand mengirim penawaran kerja sama
* Influencer menerima / menolak / nego
* Status campaign:

  * Draft
  * Offered
  * Negotiation
  * Accepted
  * In Progress
  * Submitted
  * Completed
  * Rejected
  * Cancelled

### 9.5 Messaging

* Chat 1 lawan 1 antara brand dan influencer
* Lampiran file sederhana
* Riwayat percakapan

### 9.6 Tracking Dashboard

#### Influencer Dashboard

* Total offer masuk
* Campaign aktif
* Campaign selesai
* Deadline terdekat
* Status pembayaran (jika nanti ditambahkan)

#### Brand Dashboard

* Total influencer ditemukan
* Offer terkirim
* Campaign aktif
* Campaign selesai
* Response rate

### 9.7 Notification

* Offer baru
* Pesan baru
* Status berubah
* Reminder deadline

---

## 10. Functional Requirements

### 10.1 Authentication

* User dapat mendaftar dengan email dan password.
* User dapat login sesuai role.
* Sistem menyimpan role user di database.

### 10.2 Profile

* User dapat mengisi dan mengubah profil.
* Influencer dapat menambahkan beberapa akun sosial media.
* Brand dapat mengisi detail perusahaan dan campaign needs.

### 10.3 Search and Filter

* Brand dapat mencari influencer berdasarkan filter tertentu.
* Influencer dapat mencari brand berdasarkan kategori campaign.
* Hasil pencarian dapat diurutkan berdasarkan relevansi.

### 10.4 Offer Management

* Brand dapat membuat offer ke influencer.
* Influencer dapat menerima / menolak / meminta revisi.
* Semua perubahan status tersimpan di sistem.

### 10.5 Chat

* User dapat mengirim pesan setelah ada koneksi / offer.
* Pesan tersimpan dan bisa dibuka kembali.

### 10.6 Tracking

* User dapat melihat riwayat campaign.
* User dapat memeriksa status terbaru setiap offer.

---

## 11. Non-Functional Requirements

* **Performance:** hasil pencarian harus tampil cepat dan responsif.
* **Scalability:** sistem harus siap menampung banyak influencer dan brand.
* **Security:** password di-hash, endpoint dilindungi JWT.
* **Reliability:** data offer dan campaign tidak boleh hilang.
* **Usability:** UI sederhana, mudah dipahami, cocok untuk mobile.
* **Maintainability:** arsitektur code harus modular.

---

## 12. Data Entity (High Level)

### 12.1 User

* id
* name
* email
* password_hash
* role (`influencer` / `brand`)
* created_at
* updated_at

### 12.2 Influencer Profile

* user_id
* username
* bio
* niche
* location
* followers_count
* engagement_rate
* rate_card
* media_kit_url

### 12.3 Brand Profile

* user_id
* brand_name
* description
* industry
* website
* location
* logo_url

### 12.4 Social Media Account

* id
* influencer_user_id
* platform
* handle
* followers_count
* engagement_rate

### 12.5 Offer / Campaign

* id
* brand_user_id
* influencer_user_id
* title
* brief
* budget
* status
* deadline
* created_at
* updated_at

### 12.6 Message

* id
* conversation_id
* sender_user_id
* message_text
* attachment_url
* created_at

### 12.7 Notification

* id
* user_id
* type
* title
* body
* read_status
* created_at

---

## 13. API Requirements (Express.js)

### Authentication

* `POST /auth/register`
* `POST /auth/login`
* `POST /auth/logout`
* `POST /auth/forgot-password`

### Profile

* `GET /profile/me`
* `PUT /profile/me`
* `POST /profile/influencer/social-media`
* `PUT /profile/brand`

### Discovery

* `GET /influencers`
* `GET /brands`
* `GET /influencers/:id`
* `GET /brands/:id`

### Offers / Campaigns

* `POST /offers`
* `GET /offers`
* `GET /offers/:id`
* `PATCH /offers/:id/status`

### Chat

* `GET /conversations`
* `POST /conversations`
* `GET /conversations/:id/messages`
* `POST /conversations/:id/messages`

### Notifications

* `GET /notifications`
* `PATCH /notifications/:id/read`

---

## 14. Database Consideration (MySQL)

### Relasi utama

* 1 user = 1 role utama
* 1 influencer dapat memiliki banyak social media account
* 1 brand dapat memiliki banyak offer
* 1 conversation dapat berisi banyak message
* 1 user dapat memiliki banyak notification

### Index yang disarankan

* `users.email`
* `offers.brand_user_id`
* `offers.influencer_user_id`
* `social_media_accounts.influencer_user_id`
* `notifications.user_id`

---

## 15. MVP Success Metrics

* Jumlah pendaftaran user baru
* Persentase profil yang lengkap
* Jumlah pencarian influencer / brand per hari
* Jumlah offer yang dikirim
* Response rate offer
* Jumlah campaign yang selesai
* Retention 7 hari dan 30 hari

---

## 16. Risiko Produk

1. **Data profil tidak lengkap** → hasil pencarian kurang akurat.
2. **Aktivitas chat rendah** → offer tidak berlanjut menjadi campaign.
3. **Verifikasi akun belum matang** → risiko akun palsu.
4. **Kurangnya transparansi rate** → negosiasi menjadi lambat.
5. **Cold start problem** → sulit menemukan banyak user di awal.

---

## 17. Rekomendasi Fase Pengembangan

### Fase 1 - MVP

* Auth
* Profil
* Search
* Offer
* Tracking
* Chat dasar

### Fase 2

* Verifikasi akun
* Media kit upload
* Bookmark / shortlist
* Rating / review
* Notifikasi real-time

### Fase 3

* Payment tracking
* Analytics campaign
* Recommendation engine
* Admin dashboard
* Integrasi API sosial media

---

## 18. Catatan Teknis

### Frontend Flutter

* Gunakan arsitektur clean / modular.
* Pisahkan layer UI, state management, repository, dan data source.
* Rekomendasi state management: BLoC, Riverpod, atau Provider.

### Backend Express.js

* Gunakan REST API yang konsisten.
* Autentikasi menggunakan JWT.
* Validasi request dengan middleware.
* Logging dan error handling wajib rapi.

### Database MySQL

* Gunakan foreign key dan index.
* Simpan data status offer secara terstruktur.
* Pertimbangkan soft delete untuk data penting.

---

## 19. Definition of Done (MVP)

Produk MVP dianggap selesai jika:

* User bisa daftar dan login.
* Influencer dan brand bisa membuat profil.
* Brand bisa mencari influencer.
* Influencer bisa menerima offer.
* Status campaign bisa dilacak.
* Chat dasar berjalan.
* Data tersimpan aman di backend dan MySQL.

---

## 20. Ringkasan

Konekta adalah platform penghubung influencer dan brand yang fokus pada **discovery, offer management, chat, dan tracking campaign**. Untuk MVP, fokus utama adalah membuat alur kerja yang sederhana namun lengkap agar kedua sisi dapat langsung menggunakan aplikasi untuk mencari, menawarkan, dan memantau kerja sama.
