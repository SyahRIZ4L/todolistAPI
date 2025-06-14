# ✅ Flutter ToDoList App

**Flutter ToDoList** adalah aplikasi manajemen tugas harian berbasis **Flutter** dan **Laravel 10**, yang dirancang dengan antarmuka modern, responsif, dan mudah digunakan. Cocok digunakan oleh pelajar, mahasiswa, developer, hingga pengguna umum yang ingin meningkatkan produktivitas dan keteraturan dalam menyelesaikan tugas sehari-hari.

---

## 📱 Tentang Aplikasi

Aplikasi ini dibangun menggunakan:
- **Flutter** (Frontend mobile)
- **Laravel 10** (Backend RESTful API)
- **MySQL** (Database)

Aplikasi ini mengusung pendekatan client-server, memisahkan logika frontend dan backend, serta memanfaatkan API untuk menghubungkan keduanya.

---

## ✨ Fitur Unggulan

- ✅ **CRUD Tugas**  
  Tambah, edit, dan hapus tugas dengan mudah melalui antarmuka yang intuitif.

- 🎯 **Penentuan Prioritas**  
  Tandai tingkat urgensi tugas dengan pilihan: `Low`, `Medium`, atau `High`.

- 📅 **Deadline Otomatis**  
  Pilih tanggal jatuh tempo menggunakan date picker modern.

- ☑️ **Checklist Selesai**  
  Tandai tugas yang telah diselesaikan dengan satu sentuhan.

- 📦 **Manajemen Waktu**  
  Kolom `created_at` dan `updated_at` secara otomatis menyesuaikan waktu dari perangkat pengguna.

- 🎨 **Desain Modern**  
  Tampilan Flutter yang clean dan responsive, dengan komponen `Card` untuk menyusun daftar tugas dengan rapi.

---

## 🗂️ Struktur Tabel Database

Tabel: **`tasks`**

| Kolom        | Tipe Data | Deskripsi                          |
|--------------|-----------|-------------------------------------|
| `id`         | INT       | Primary Key, auto increment         |
| `title`      | VARCHAR   | Judul atau nama tugas               |
| `priority`   | ENUM      | Nilai: low, medium, high            |
| `due_date`   | DATETIME  | Tanggal batas akhir tugas           |
| `is_done`    | BOOLEAN   | Status tugas: selesai atau belum    |
| `created_at` | TIMESTAMP | Tercatat saat tugas dibuat          |
| `updated_at` | TIMESTAMP | Diubah otomatis saat tugas diedit   |

---

## 🔗 Endpoint API (Laravel Backend)

| Method | Endpoint             | Fungsi                       |
|--------|----------------------|------------------------------|
| GET    | `/api/tasks`         | Menampilkan semua tugas      |
| POST   | `/api/tasks`         | Menambahkan tugas baru       |
| PUT    | `/api/tasks/{id}`    | Mengedit data tugas tertentu |
| DELETE | `/api/tasks/{id}`    | Menghapus tugas berdasarkan ID |

---

## 🧰 Teknologi & Tools

- 🔹 Flutter (SDK mobile UI modern)
- 🔹 Laravel 10 (Framework backend PHP)
- 🔹 MySQL (Relational database)
- 🔹 Postman (Testing API)
- 🔹 Visual Studio Code (Code Editor)
- 🔹 Laragon (Local development environment)

---

## 🚀 Langkah Instalasi & Menjalankan Proyek

### 1. Clone Repository
```bash
git clone https://github.com/Thermaplates/Flutter_Todolist
cd Flutter_Todolist
```

### 2. Konfigurasi Backend (Laravel)
```bash
cd api
composer install
cp .env.example .env
php artisan key:generate
```

Edit `.env`:
```env
DB_DATABASE=todo_app
DB_USERNAME=root
DB_PASSWORD=
```

Jalankan migrasi database:
```bash
php artisan migrate
php artisan serve
```

### 3. Jalankan Aplikasi Flutter
```bash
cd flutter_app
flutter pub get
flutter run
```

---

## ▶️ Cara Menjalankan Aplikasi

1. **Backend**:  
   Pastikan Laravel API berjalan di terminal:  
   ```bash
   php artisan serve
   ```

2. **Frontend**:  
   Jalankan Flutter app di emulator atau perangkat fisik:  
   ```bash
   flutter run
   ```

---

## 🎬 Demo Aplikasi



Uploading Recording 2025-06-14 203604.mp4…



---

## 👤 Profil Pengembang

| Informasi         | Detail                        |
|-------------------|-------------------------------|
| **Nama**          | [Nama Kamu]                   |
| **Nomor Absen**   | 20                            |
| **Kelas**         | XI RPL 1                      |
| **Sekolah**       | SMK Negeri 1 Bantul           |
| **Jurusan**       | Rekayasa Perangkat Lunak (RPL)|

---

## 📌 Catatan Tambahan

- Backend Laravel bisa di-deploy ke hosting seperti Heroku atau Vercel (menggunakan API proxy).
- Flutter frontend dapat di-build menjadi APK atau dijalankan di emulator Android/iOS.
- Untuk pengembangan lebih lanjut, kamu bisa menambahkan fitur seperti login/register, reminder notifikasi, atau penyimpanan berbasis cloud.
