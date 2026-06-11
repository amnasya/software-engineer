# Konekta — User Flow

## 1. Splash Screen
- Menampilkan logo Konekta
- Cek status login user (JWT valid / tidak)
- Arahkan ke:
  - Dashboard (jika sudah login)
  - Onboarding (jika belum login)

## 2. Onboarding Screen (3 halaman)
- Slide 1: Discover premium brands
- Slide 2: Track every deliverable
- Slide 3: Get paid, stay organized
- Tombol "Get Started" → ke Register / Login
- Tombol "Already have an account? Log in" → ke Login Screen

## 3. Register Screen
- Input email dan password
- Tombol "Register"
- Link "Already have an account? Log in" → ke Login Screen
- Link "Forgot password?"

## 4. Login Screen
- Input email dan password
- Tombol "Login"
- Link "Don't have an account? Register" → ke Register Screen
- Link "Forgot password?"

## 5. Role Selection Screen
Setelah berhasil register/login, user diminta memilih role:
- **Influencer** → membuat brand menemukan kampanye yang relevan untuk creator
- **Brand** → membuat brand/jasa, mencari influencer untuk kampanye
- Setelah memilih role ��� menuju Complete Profile Screen sesuai role

## 6. Complete Profile Screen

### 6a. Influencer — Complete Profile
- Input: username, akun TikTok, short description, dan industry (pilih chip: Fashion, Beauty, F&B, Tech, Others)
- Jika pilih "Others" → muncul text field tambahan
- Tombol "Continue" → masuk ke Influencer Dashboard

### 6b. Brand — Complete Profile
- Input: brand name, industry, website, deskripsi singkat
- Tombol "Continue" → masuk ke Brand Dashboard

## 7. Main Screen — Influencer Dashboard

### 7a. Home (Dashboard)
- Welcome message + greeting
- Ringkasan statistik: total offer masuk, campaign aktif, campaign selesai
- Quick action: "Explore Campaigns" → ke Explore Screen

### 7b. Search Screen
- Pencarian brand berdasarkan: kategori campaign, lokasi, tipe campaign, budget range
- Hasil pencarian ditampilkan dalam card
- Card brand: nama brand, kategori, lokasi, rating, jumlah campaign aktif
- Tap card → Brand Detail Screen

### 7c. Explore Screen
- Daftar kampanye yang terbuka untuk influencer
- Filter: budget, kategori, deadline
- Card kampanye: title, brand, budget, deadline
- Tombol "Apply to Campaign" → kirim penawaran ke brand

### 7d. Profile Screen
- Edit profil: nama, bio, foto, sosial media, niche, rate card
- Logout → kembali ke Login Screen

### 7e. Chat Screen
- Daftar percakapan dengan brand
- Chat room: kirim pesan, lihat riwayat percakapan

### 7f. Notification Screen
- Notifikasi: offer baru, pesan baru, status berubah, reminder deadline
- Tap notifikasi → buka detail offer / buka chat

## 8. Main Screen — Brand Dashboard

### 8a. Home (Dashboard)
- Welcome message + greeting
- Ringkasan statistik: total influencer ditemukan, offer terkirim, campaign aktif, campaign selesai
- Quick action: "Find Influencers" → ke Search Screen

### 8b. Search Screen
- Pencarian influencer berdasarkan: niche, lokasi, platform sosial media, range followers, engagement rate, budget
- Hasil pencarian ditampilkan dalam card
- Card influencer: nama, niche, foto, followers, engagement rate, rate card
- Tap card → Influencer Detail Screen
- Tombol "Send Offer" → kirim penawaran ke influencer

### 8c. Explore Screen
- Daftar campaign sendiri yang dibuat brand
- Filter: status campaign (Draft, Offered, Negotiation, Accepted, In Progress, Submitted, Completed, Rejected, Cancelled)
- Tap card → Campaign Detail Screen

### 8d. Create Campaign Screen
- Membuat campaign baru: title, brief, budget, deadline
- Tombol "Save Draft" atau "Publish Campaign"

### 8e. Profile Screen
- Edit profil brand: nama brand, deskripsi, website, lokasi
- Logout → kembali ke Login Screen

### 8f. Chat Screen
- Daftar percakapan dengan influencer
- Chat room: kirim pesan, lihat riwayat percakapan

### 8g. Notification Screen
- Notifikasi: response dari influencer, pesan baru, status campaign berubah
- Tap notifikasi → buka detail offer / buka chat

## 9. Campaign Detail Screen
- Informasi campaign: title, brief, budget, deadline, status
- Status campaign: Draft → Offered → Negotiation → Accepted → In Progress → Submitted → Completed
- Action button sesuai status:
  - "Accept Offer" / "Reject Offer" / "Negotiate"
  - Tombol "View Progress" → ke Campaign Performance Screen
  - Tombol "Chat" → ke Chat Room dengan influencer terkait

## 10. Campaign Performance Screen
- Progress bar campaign berdasarkan deliverable
- Timeline deadline
- Status pengerjaan tiap deliverable

## 11. Logout
- Semua session dihapus
- Kembali ke Login Screen
