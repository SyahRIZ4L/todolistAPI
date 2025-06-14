# ✅ Flutter_Todolist

Aplikasi **To-Do List** berbasis Flutter dan Laravel yang dirancang untuk membantu pengguna mengelola tugas harian dengan tampilan modern dan fitur lengkap. Cocok untuk pelajar, developer, maupun pengguna umum yang ingin lebih produktif.

---

## 📱 Deskripsi Singkat

Aplikasi ini menggunakan:
- **Flutter** sebagai frontend
- **Laravel 10** sebagai backend (REST API)
- **MySQL** sebagai database

### 🔧 Fitur Utama:
- Tambah, edit, dan hapus tugas (CRUD)
- Pilihan prioritas tugas (low, medium, high)
- Deadline dengan penanggalan otomatis
- Checklist untuk menandai tugas selesai
- Tampilan modern menggunakan Flutter Card
- `created_at` dan `updated_at` mengikuti waktu laptop pengguna

---

## 🧩 Struktur Database

Tabel `tasks`:

| Kolom         | Tipe Data | Keterangan                         |
|---------------|-----------|------------------------------------|
| id            | INT       | Primary Key                        |
| title         | VARCHAR   | Judul tugas                        |
| priority      | ENUM      | low / medium / high                |
| due_date      | DATETIME  | Deadline tugas                     |
| is_done       | BOOLEAN   | Status tugas (selesai/belum)       |
| created_at    | TIMESTAMP | Otomatis saat input                |
| updated_at    | TIMESTAMP | Otomatis saat edit                 |

---

## 🔗 API Endpoint (Laravel)

| Method | Endpoint             | Fungsi                |
|--------|----------------------|------------------------|
| GET    | `/api/tasks`         | Ambil semua tugas      |
| POST   | `/api/tasks`         | Tambah tugas baru      |
| PUT    | `/api/tasks/{id}`    | Edit tugas             |
| DELETE | `/api/tasks/{id}`    | Hapus tugas            |

---

## 🧪 Tools & Teknologi
- Flutter (versi terbaru)
- Laravel 10
- MySQL
- Postman
- VS Code
- Laragon

---

## 🚀 Cara Instalasi

### 1. Clone Repository
```bash
git clone https://github.com/Thermaplates/Flutter_Todolist
cd todolist
```

### 2. Setup Laravel (Backend)
```bash
cd api
composer install
cp .env.example .env
php artisan key:generate
```
Edit file `.env`:
```
DB_DATABASE=todo_app
DB_USERNAME=root
DB_PASSWORD=
```

Lalu jalankan migrasi database:
```bash
php artisan migrate
php artisan serve
```

### 3. Setup Flutter (Frontend)
```bash
cd flutter_app
flutter pub get
flutter run
```

---

## 🧪 Cara Menjalankan
1. Jalankan API Laravel:
   ```bash
   php artisan serve
   ```
2. Jalankan Aplikasi Flutter:
   ```bash
   flutter run
   ```

---

## 🎥 Demo Aplikasi



https://github.com/user-attachments/assets/76de91f5-9a9b-4c2d-8d12-b69e890992a2



---

## 👤 Profil Pembuat

| Nama                        | ........................... |
|-----------------------------|----------------------------|
| Nomor Absen                | 20                         |
| Kelas                      | XI RPL 1                   |
| Sekolah                    | SMK Negeri 1 Bantul        |
| Jurusan                    | Rekayasa Perangkat Lunak   |

---
