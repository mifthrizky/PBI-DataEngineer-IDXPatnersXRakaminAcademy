# Proyek Optimalisasi ETL untuk Data Warehouse Perbankan

Proyek ini merupakan bagian dari program **PBI Data Engineer - IDX Partners & Rakamin Academy**. Tujuannya adalah merancang dan mengimplementasikan proses ETL (Extract, Transform, Load) yang efisien untuk membangun sebuah Data Warehouse (DWH) untuk sistem perbankan.

Proses ETL ini dirancang untuk mengintegrasikan data dari berbagai sumber, termasuk database transaksional (OLTP), file CSV, dan file Excel, kemudian memuatnya ke dalam model Star Schema di DWH.

## 1. Tujuan Proyek

* **Merancang Skema Data Warehouse**: Mendesain dan membuat model data Star Schema yang terdiri dari tabel fakta (Fact) dan dimensi (Dimension) untuk mendukung analisis data perbankan.
* **Mengembangkan Job ETL**: Membangun alur kerja ETL menggunakan Talend Open Studio for Data Integration untuk mengekstrak data dari berbagai sumber.
* **Integrasi Data**: Menggabungkan data transaksi yang berasal dari MS SQL Server, file CSV, dan file Excel ke dalam satu tabel fakta.
* **Transformasi dan Pembersihan Data**: Melakukan transformasi data seperti join tabel, konversi tipe data, dan deduplikasi data untuk memastikan konsistensi dan kualitas data.
* **Membuat Prosedur Analitis**: Menyediakan Stored Procedure pada DWH untuk mempermudah kueri analitis yang umum dilakukan.

## 2. Teknologi yang Digunakan

* **ETL Tool**: Talend Open Studio for Data Integration (Versi 8.0.1)
* **Database**: Microsoft SQL Server (Versi 16.00.1000)
* **Bahasa**: SQL (T-SQL)

## 3. Skema Data Warehouse (Star Schema)

Data Warehouse ini dirancang dengan satu tabel fakta dan tiga tabel dimensi.

### Tabel Fakta (Fact Table)

**`FactTransaction`**
Tabel ini menyimpan data kuantitatif dari setiap transaksi perbankan.

```sql
CREATE TABLE FactTransaction(
	TransactionID INT PRIMARY KEY,
	AccountID INT,
	TransactionDate DATETIME2(0),
	Amount DECIMAL(10, 4),
	TransactionType VARCHAR(50),
	BranchID INT
);
```

### Tabel Dimensi (Dimension Tables)

**`DimCustomer`**
Menyimpan informasi deskriptif mengenai nasabah.

```sql
CREATE TABLE DimCustomer(
	CustomerID INT PRIMARY KEY,
	CustomerName VARCHAR(100),
	Address Varchar(200),
	CityName VARCHAR(200),
	StateName VARCHAR(200),
	Age INT,
	Gender VARCHAR(10),
	Email VARCHAR(100)
);
```

**`DimAccount`**
Menyimpan detail mengenai rekening nasabah.

```sql
CREATE TABLE DimAccount(
	AccountID INT PRIMARY KEY,
	CustomerID INT,
	AccountType VARCHAR(50),
	Balance INT,
	DateOpened DATETIME2(0),
	Status VARCHAR(50)
);
```

**`DimBranch`**
Menyimpan informasi mengenai cabang bank.

```sql
CREATE TABLE DimBranch(
	BranchID INT PRIMARY KEY,
	BranchName VARCHAR(100),
	BranchLocation VARCHAR(100)
);
```

*(Sumber: `Create_DataWarehouse.sql`)*

## 4. Proses ETL Menggunakan Talend

Proses ETL terdiri dari beberapa job yang dirancang untuk memuat data ke setiap tabel di DWH.

#### Sumber Data:
1.  **Database MS SQL Server (`sample`)**: Sebagai database transaksional (OLTP) utama yang berisi data nasabah, rekening, cabang, dan sebagian transaksi.
2.  **File Excel (`transaction_excel.xlsx`)**: Berisi data transaksi tambahan.
3.  **File CSV (`transaction_csv.csv`)**: Berisi data transaksi tambahan lainnya.

#### Job Talend:
* **`Load_DimCustomer`**: Mengekstrak data dari tabel `customer` di database OLTP, melakukan join dengan tabel `city` dan `state` untuk mendapatkan nama kota dan provinsi, kemudian memuat hasilnya ke tabel `DimCustomer`.
* **`Load_DimBranch`**: Mengekstrak data dari tabel `branch` dan memuatnya ke `DimBranch`.
* **`Load_DimAccount`**: Mengekstrak data dari tabel `account` dan memuatnya ke `DimAccount`.
* **`Load_FactTransaction`**: Job ini melakukan proses optimalisasi dengan:
    1.  Mengekstrak data transaksi dari tiga sumber berbeda: `transaction_db` (SQL Server), `transaction_excel.xlsx`, dan `transaction_csv.csv`.
    2.  Menggunakan komponen **`tUnite`** untuk menggabungkan ketiga sumber data tersebut.
    3.  Menggunakan komponen **`tUniqRow`** untuk menghilangkan data duplikat berdasarkan `TransactionID`.
    4.  Memuat data yang sudah bersih dan terintegrasi ke dalam tabel `FactTransaction`.

## 5. Prosedur Analitis (Stored Procedures)

Untuk mempermudah analisis, dibuat dua stored procedure utama di DWH:

1.  **`dbo.DailyTransaction`**
    * **Fungsi**: Menghitung total transaksi dan total jumlah (amount) per hari dalam rentang tanggal yang ditentukan.
    * **Parameter**: `@start_date`, `@end_date`.

2.  **`dbo.BalancePerCustomer`**
    * **Fungsi**: Menghitung saldo terkini seorang nasabah berdasarkan saldo awal dan riwayat transaksinya (Deposit akan menambah, tipe lain akan mengurangi).
    * **Parameter**: `@name` (nama nasabah).

*(Sumber: `Create_StockProcedure.sql`)*

## 6. Cara Menjalankan Proyek

1.  **Persiapan Database**:
    * Pastikan Microsoft SQL Server sudah terpasang.
    * Buat database `DWH` dan jalankan skrip `Create_DataWarehouse.sql` untuk membuat semua tabel.
    * Siapkan database sumber `sample` dengan data transaksional.

2.  **Setup Talend**:
    * Impor proyek Talend (`IDX_ETL`) ke dalam Talend Open Studio.
    * Buka setiap job dan perbarui konfigurasi koneksi database (host, user, password) dan path file (CSV & Excel) pada bagian **Metadata**.

3.  **Eksekusi Job**:
    * Jalankan job-job Talend dengan urutan sebagai berikut untuk menjaga integritas data:
        1.  `Load_DimCustomer`
        2.  `Load_DimBranch`
        3.  `Load_DimAccount`
        4.  `Load_FactTransaction`
    * Setelah semua job berhasil, jalankan skrip `Create_StockProcedure.sql` pada database `DWH` untuk membuat stored procedure.

## 7. Lisensi

Proyek ini dilisensikan di bawah **MIT License**. Lihat file `LICENSE` untuk detail lebih lanjut.
