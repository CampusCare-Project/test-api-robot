# CampusCare — Test Automation

Suite pengujian otomatis untuk sistem **CampusCare** menggunakan [Robot Framework](https://robotframework.org/). Mencakup pengujian API (REST) dan pengujian aplikasi mobile (Android via Appium + Expo Go).

---

## 📁 Struktur Proyek

```
tests/
├── .gitignore
├── README.md
└── robot/
    ├── requirements.txt          # Daftar dependensi Python
    ├── robot.args                # Konfigurasi argumen untuk test API
    ├── robot_app.args            # Konfigurasi argumen untuk test Mobile
    ├── resources/                # File resource & keyword yang dapat digunakan ulang
    │   ├── common.resource       # Keyword umum (HTTP session, assertion, helper)
    │   ├── auth.resource         # Keyword autentikasi (login per peran)
    │   └── mobile_expo.resource  # Keyword Appium untuk Expo Go (Android)
    └── suites/                   # Test suite Robot Framework
        ├── 01_api_auth.robot         # Pengujian autentikasi (login, validasi token)
        ├── 02_api_users.robot        # Pengujian manajemen pengguna
        ├── 03_api_masterdata.robot   # Pengujian data master (kategori, gedung, ruangan)
        └── 04_api_report_flow.robot  # Pengujian alur laporan end-to-end (E2E)
```

> **Catatan:** Direktori `results/` dan `.venv/` di-*ignore* oleh Git dan akan dibuat secara otomatis saat dibutuhkan.

---

## 📦 Dependensi

### Runtime
| Library | Versi | Kegunaan |
|---|---|---|
| `robotframework` | 7.1.1 | Framework utama pengujian |
| `robotframework-requests` | 0.9.7 | Pengujian REST API via HTTP |
| `robotframework-pabot` | 2.18.0 | Eksekusi test secara paralel |
| `robotframework-browser` | 18.9.1 | Pengujian web browser (Playwright) |
| `robotframework-appiumlibrary` | *latest* | Pengujian aplikasi mobile (Android/Appium) |

### Prasyarat Sistem
| Kebutuhan | Keterangan |
|---|---|
| **Python 3.10+** | Runtime utama Robot Framework |
| **pip** | Package manager Python |
| **Node.js** (opsional) | Diperlukan jika menggunakan `robotframework-browser` (Playwright) |
| **Appium Server** | Wajib jika menjalankan test mobile |
| **Android Device / Emulator** | Perangkat target untuk test mobile |
| **Expo Go** | Aplikasi Expo Go terinstal di perangkat Android |
| **CampusCare Backend** | Semua layanan backend harus berjalan (default: `http://localhost:8080`) |

---

## ⚙️ Persyaratan untuk Menjalankan

### 1. Backend CampusCare
Pastikan seluruh layanan backend CampusCare sudah berjalan dan dapat diakses:
- **API Gateway** → `http://localhost:8080`
- **Frontend** (opsional, untuk test browser) → `http://localhost:8081`

### 2. Akun Pengguna
Pastikan akun-akun berikut sudah tersedia di database:

| Peran | Identifier Default | Password Default |
|---|---|---|
| Admin | `helmi3` | `123456` |
| Student | `student` | `123456` |
| Teknisi | `teknisi3` | `123456` |

> Nilai default ini dapat diubah di file `robot/robot.args`.

### 3. Data Teknisi
Untuk suite **04_api_report_flow**, pastikan minimal satu akun dengan peran `TEKNISI` sudah tersedia di endpoint `/api/auth/technician` dan identifiernya cocok dengan variabel `TECH_IDENTIFIER`.

---

## 🚀 Cara Menjalankan

### Langkah 1 — Siapkan Virtual Environment

```bash
# Buat virtual environment
python -m venv .venv

# Aktifkan virtual environment
# Windows (PowerShell)
.venv\Scripts\Activate.ps1

# Linux / macOS
source .venv/bin/activate
```

### Langkah 2 — Install Dependensi

```bash
pip install -r robot/requirements.txt
```

> **Khusus `robotframework-browser`:** Setelah install, jalankan perintah berikut sekali untuk mengunduh Playwright browser:
> ```bash
> rfbrowser init
> ```

### Langkah 3 — Jalankan Test

#### ✅ Menjalankan Semua Test API

```bash
robot --argumentfile robot/robot.args robot/suites/
```

#### ✅ Menjalankan Suite Tertentu

```bash
# Hanya test autentikasi
robot --argumentfile robot/robot.args robot/suites/01_api_auth.robot

# Hanya test manajemen pengguna
robot --argumentfile robot/robot.args robot/suites/02_api_users.robot

# Hanya test data master
robot --argumentfile robot/robot.args robot/suites/03_api_masterdata.robot

# Hanya test alur laporan (E2E)
robot --argumentfile robot/robot.args robot/suites/04_api_report_flow.robot
```

#### ✅ Menjalankan Test Mobile (Android + Appium)

> Pastikan Appium Server sudah berjalan (`http://127.0.0.1:4723`) dan perangkat Android terhubung.

```bash
robot --argumentfile robot/robot_app.args robot/suites/
```

#### ✅ Menjalankan Test secara Paralel (dengan Pabot)

```bash
pabot --argumentfile robot/robot.args robot/suites/
```

---

## 🔧 Konfigurasi Variabel

Semua variabel dapat di-*override* langsung dari command line dengan flag `--variable`:

```bash
# Contoh: mengubah URL dan kredensial
robot --argumentfile robot/robot.args \
  --variable BASE_URL:http://192.168.1.10:8080 \
  --variable ADMIN_IDENTIFIER:admin_saya \
  --variable ADMIN_PASSWORD:rahasia \
  robot/suites/
```

### Variabel Tersedia (`robot.args`)

| Variabel | Default | Keterangan |
|---|---|---|
| `BASE_URL` | `http://localhost:8080` | URL API Gateway |
| `FRONTEND_URL` | `http://localhost:8081` | URL Frontend |
| `ADMIN_IDENTIFIER` | `helmi3` | Username/email login admin |
| `ADMIN_PASSWORD` | `123456` | Password admin |
| `STUDENT_IDENTIFIER` | `student` | Username/email login mahasiswa |
| `STUDENT_PASSWORD` | `123456` | Password mahasiswa |
| `TECH_IDENTIFIER` | `teknisi3` | Username/email login teknisi |
| `TECH_PASSWORD` | `123456` | Password teknisi |
| `HEADLESS` | `True` | Mode headless untuk browser test |

### Variabel Tersedia (`robot_app.args`)

| Variabel | Default | Keterangan |
|---|---|---|
| `APPIUM_SERVER` | `http://127.0.0.1:4723` | URL Appium Server |
| `DEVICE_NAME` | `Android Device` | Nama perangkat Android |
| `EXPO_GO_PACKAGE` | `host.exp.exponent` | Package name Expo Go |
| `EXPO_GO_ACTIVITY` | `host.exp.exponent.experience.HomeActivity` | Activity utama Expo Go |
| `LOGIN_IDENTIFIER` | `helmi3` | Username login di aplikasi mobile |
| `LOGIN_PASSWORD` | `123456` | Password login di aplikasi mobile |

---

## 📊 Hasil Pengujian

Hasil pengujian tersimpan otomatis di direktori `results/` (di-*ignore* oleh Git):

```
results/
├── robot/    # Hasil test API (output.xml, log.html, report.html)
└── mobile/   # Hasil test Mobile (output.xml, log.html, report.html)
```

Buka file `report.html` atau `log.html` di browser untuk melihat laporan detail pengujian.

---

## 🗂️ Cakupan Test Suite

| Suite | Deskripsi |
|---|---|
| `01_api_auth` | Login berhasil sebagai Admin & Student; validasi login dengan password salah |
| `02_api_users` | Admin dapat melihat & menambah pengguna; Student tidak dapat menambah pengguna |
| `03_api_masterdata` | Admin dapat membuat Kategori, Gedung, dan Ruangan sekaligus |
| `04_api_report_flow` | Alur lengkap: persiapan data → buat laporan → verifikasi → assign teknisi → in-progress → selesai → feedback → cek detail |
