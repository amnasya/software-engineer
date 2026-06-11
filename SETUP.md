# Konekta — Setup & Run Guide

Panduan lengkap untuk menjalankan project **Konekta** (Backend Express + TypeScript + MySQL, Frontend Flutter) dari nol di lokal.

---

## 1. Prasyarat

Pastikan tools berikut sudah ter-install di mesin kamu:

| Tool        | Versi Minimum | Keterangan                                      |
| ----------- | ------------- | ----------------------------------------------- |
| Node.js     | 18.x atau 20.x | Runtime backend (disarankan LTS)               |
| npm         | 9.x ke atas    | Package manager backend (ikut Node.js)         |
| MySQL       | 8.x            | Database server                                |
| Flutter SDK | 3.10.x ke atas | Framework frontend                             |
| Dart        | 3.x            | Bahasa pemrograman Flutter (ikut Flutter SDK)  |
| Git         | terbaru        | Version control (opsional)                     |

Cek versi:
```bash
node -v
npm -v
mysql --version
flutter --version
```

---

## 2. Clone & Masuk Direktori

```bash
git clone <repo-url> "konekta"
cd "konekta"
```

Struktur utama project:
```
konekta/
├── backend/        # Express + TypeScript API
├── database/       # Skema SQL
├── konekta/        # Flutter app
├── ARCHITECTURE.md
├── design-patterns.md
└── prd.md
```

---

## 3. Setup Database (MySQL)

### 3.1 Jalankan MySQL
Pastikan service MySQL sudah berjalan.

### 3.2 Buat Database & Import Schema
```bash
mysql -u root -p < database/schema.sql
```
Atau masuk ke MySQL lalu jalankan:
```sql
SOURCE database/schema.sql;
```

> ℹ️ Sesuaikan user/password di `backend/.env` (langkah 4.2).

---

## 4. Setup Backend (Express + TypeScript)

### 4.1 Install Dependencies
```bash
cd backend
npm install
```

### 4.2 Konfigurasi Environment
Buat file `backend/.env`:
```env
PORT=3000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=konekta
JWT_SECRET=replace-with-a-long-random-string
GOOGLE_CLIENT_ID=your-google-oauth-client-id.apps.googleusercontent.com
```

### 4.3 Build TypeScript
```bash
npm run build
```

### 4.4 Jalankan Backend
Mode development (auto-reload):
```bash
npm run dev
```
Mode production (setelah build):
```bash
npm start
```

Backend akan berjalan di `http://localhost:3000`.

Cek kesehatan API:
```bash
curl http://localhost:3000/
# atau endpoint health-check yang tersedia
```

---

## 5. Setup Frontend (Flutter)

### 5.1 Install Dependencies
```bash
cd ../konekta
flutter pub get
```

### 5.2 Konfigurasi Endpoint API
Cari file konfigurasi base URL di Flutter (umumnya di `lib/utils/` atau `lib/config/`). Contoh:
```dart
const String kBaseUrl = 'http://localhost:3000';
```
> ⚠️ Untuk Android emulator, ganti `localhost` menjadi `10.0.2.2`. Untuk device fisik, gunakan IP LAN (mis. `http://192.168.1.10:3000`).

### 5.3 Jalankan Aplikasi
Pastikan ada device/emulator aktif (`flutter devices`), lalu:
```bash
flutter run
```

Platform tertentu:
```bash
flutter run -d chrome        # Web
flutter run -d android       # Android emulator/device
flutter run -d windows       # Windows desktop
```

### 5.4 (Opsional) Build APK / Web
```bash
flutter build apk --release
flutter build web --release
```

---

## 6. Menjalankan Keduanya Sekaligus

Buka 2 terminal:

**Terminal 1 — Backend**
```bash
cd backend
npm run dev
```

**Terminal 2 — Flutter**
```bash
cd konekta
flutter run
```

---

## 7. Script Penting Backend (Referensi)

| Perintah          | Fungsi                                              |
| ----------------- | --------------------------------------------------- |
| `npm run dev`     | Jalankan server dengan auto-reload (ts-node-dev)    |
| `npm run build`   | Compile TypeScript ke `dist/`                       |
| `npm start`       | Jalankan server production (butuh `build` dulu)     |
| `npm run db:reset`| Reset database dari `database/schema.sql`           |

---

## 8. Troubleshooting

- **Error `ECONNREFUSED 127.0.0.1:3306`** → MySQL belum jalan atau port salah. Cek service & `DB_PORT` di `.env`.
- **Error `Access denied for user 'root'`** → Password `DB_PASSWORD` di `.env` tidak cocok.
- **`tsc: not found`** → Jalankan `npm install` di folder `backend`.
- **Flutter tidak bisa hit backend di emulator Android** → Gunakan `http://10.0.2.2:3000` sebagai base URL.
- **`flutter pub get` gagal** → Pastikan Flutter SDK versi 3.10+ dan koneksi internet aktif.
- **Google Sign-In gagal** → Pastikan `GOOGLE_CLIENT_ID` di backend `.env` sesuai dengan yang ada di konfigurasi Flutter.

---

## 9. Ringkasan Alur

1. Install prasyarat (Node, MySQL, Flutter).
2. Import `database/schema.sql` ke MySQL.
3. `cd backend` → `npm install` → buat `.env` → `npm run dev`.
4. `cd konekta` → `flutter pub get` → atur base URL → `flutter run`.

Selesai 🎉 — project Konekta siap dijalankan.
