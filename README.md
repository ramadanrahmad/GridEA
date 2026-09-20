# Asisten Grid Pro V22 🤖📈

**Asisten Grid Pro V22** adalah Expert Advisor (EA) canggih untuk MetaTrader 5 yang dirancang khusus sebagai asisten *grid trading* semi-otomatis pada pair **XAUUSD (Emas)**. 

EA ini tidak mengambil posisi secara acak, melainkan memberikan Anda kendali penuh (sebagai *sniper* atau *director*) dengan menyediakan alat bantu eksekusi instan, sinkronisasi SL/TP masal, dan sistem penyelamatan posisi tingkat lanjut (*Smart Runner*).

---

## 🔥 Fitur Utama

### 1. ⚡ Eksekusi Grid Sekali Klik (One-Click Grid)
Terdapat panel tombol di layar chart (B & S). Cukup dengan satu klik, EA akan mengeksekusi 1 posisi *Market* dan langsung menebar 8 *layer Limit Order* dengan jarak (step) dan lot (multiplier) yang dinamis sesuai pengaturan.

### 2. 🎯 Limit Order Catching (Jebakan Manual)
Anda bisa menganalisis chart dan meletakkan 1 *Buy Limit* atau *Sell Limit* biasa di area *support/resistance* kunci. Begitu tersentuh (atau bahkan sebelum tersentuh), EA akan "menangkap" limit tersebut dan menyulapnya menjadi susunan 8 *layer Grid* secara otomatis.

### 3. 🔄 Global SL/TP Sync (Sinkronisasi Cerdas)
Lupakan memodifikasi SL/TP satu per satu! Cukup *drag & drop* garis SL/TP di salah satu posisi Anda di chart MT5. EA akan mendeteksinya dalam hitungan milidetik dan **menyelaraskan SL/TP** tersebut ke seluruh posisi yang aktif di grup yang sama. 

### 4. 🛡️ Independent Magic Grids & Manual Freedom
Setiap Grid yang Anda buat memiliki *Magic Number* uniknya sendiri. Artinya, Grid A dan Grid B tidak akan saling menulari SL/TP. Selain itu, **posisi manual murni (Magic 0) akan diabaikan 100% oleh EA**, memungkinkan Anda melakukan *scalping* manual dengan aman tanpa terganggu logika Grid EA.

### 5. 🏃 Smart Auto-Runner (Survival TP)
Fitur paling jenius dalam EA ini. Saat Anda memasang TP bersama untuk sebuah grup Grid, EA secara rahasia **menghapus TP dari posisi terdalam (harga terbaik)**.
* **Hasilnya:** Ketika harga menyentuh TP, semua posisi lain *take profit* secara normal, sementara posisi terbaik Anda **selamat**. EA lalu otomatis memotong lot posisi tersebut menjadi **0.01 lot** dan membiarkannya lepas sebagai *Runner* untuk mengejar profit maksimal!

### 6. 🆘 Manual Close to Runner (Tombol Darurat)
Grid sedang *floating minus* karena berita fundamental? Cukup *close* salah satu posisinya secara manual dari HP/Terminal Anda. EA akan mengaktifkan protokol darurat: menutup semua sisa posisi yang merugi, menghapus jebakan limit, dan **menyelamatkan posisi terbaik (pucuk)** dengan memotong lot-nya jadi 0.01 sebagai *Runner* pembalik keadaan.

### 7. 🎛️ Panel Utilitas Interaktif
* **B (Buy):** Eksekusi Buy Grid instan.
* **S (Sell):** Eksekusi Sell Grid instan.
* **C (Close):** Menutup semua posisi terbuka.
* **X (Delete):** Menghapus semua jebakan *Limit Order*.
* **CL (Clear SL/TP):** Menghapus seluruh memori sinkronisasi dan me-nol-kan SL/TP semua posisi dengan aman.

---

## ⚙️ Cara Pemasangan
1. Download file `GridEA_FixTP.mq5`.
2. Letakkan file tersebut di dalam folder `MQL5/Experts/` pada direktori data MetaTrader 5 Anda.
3. *Compile* menggunakan MetaEditor (tekan F7).
4. Pasang ke *chart* XAUUSD. Aktifkan *Algo Trading* di terminal MT5.

> **Catatan:** EA ini sangat kuat, selalu gunakan Money Management yang baik dan sesuaikan `GridStep` serta besaran `Lot` pada pengaturan Input sesuai dengan modal (Equity) Anda.
