# Helio G35 Dynamic Optimizer (blossom / angelica)

[![Magisk](https://img.shields.io/badge/Magisk-30.7+-brightgreen.svg)](https://github.com/topjohnwu/Magisk)
[![Target](https://img.shields.io/badge/SoC-MediaTek%20Helio%20G35%20(MT6765G)-orange.svg)]()
[![Platform](https://img.shields.io/badge/OS-Android%2014%20(RisingOS%20v5.1)-blue.svg)]()
[![License](https://img.shields.io/badge/License-MIT-purple.svg)]()

Production-grade, forensic-level dynamic memory, power-saving, and gaming performance optimizer designed specifically for **Xiaomi Redmi 9C (`blossom` / `angelica`)** running custom Android 14 ROMs (RisingOS v5.1).

---

## ⚡ Solusi A: Dynamic Foreground Game Listener

Unlike traditional Magisk tweak modules that force high clocks and power-hungry states 24/7, this module introduces an autonomous, zero-overhead background listener directly tapping kernel sysfs & cgroups:

```
┌─────────────────────────────────────────────────────────────────┐
│                      DAEMON LISTENER v3.1                       │
│           (Cek setiap 3 detik via /dev/cpuset/top-app)          │
└────────────────┬───────────────────────────────┬────────────────┘
                 │                               │
        [GAME TERDETEKSI]               [NON-GAME / IDLE]
       (Roblox, MLBB, dll)             (Chatting, Home, Layar Mati)
                 │                               │
                 ▼                               ▼
       🚀 MODE GAME AKTIF              🍃 MODE BALANCED AKTIF
  • GPU Boost & GED Game Mode = 1  • GPU Clocks = 0 (Balanced/Smart)
  • Wi-Fi CAM = 1 (Zero latency)   • Wi-Fi Power Save = ON (Deep sleep)
  • Wi-Fi Power Save = OFF         • Wi-Fi CAM = 0 (Hemat 50-80 mA)
  • Touch Glove Mode = 1 (Sensitif) • Touch Glove Mode = 0 (Normal)
                                   • Wi-Fi Scan Throttling = 1 (ON)
```

### Supported Games (Auto-Detected)
- Roblox (`com.roblox.client`)
- Mobile Legends: Bang Bang (`com.mobile.legends`)
- Free Fire / Free Fire MAX (`com.dts.freefireth`, `com.dts.freefiremax`)
- PUBG Mobile / BGMI (`com.tencent.ig`, `com.pubg.krmobile`)
- Car Parking Multiplayer (`com.olzhas.carparking`)
- Bus Simulator Indonesia (`com.maleo.bussimulatorid`)
- Genshin Impact / Honkai / ZZZ (`com.miHoYo.`, `com.hoyoverse.`)
- Minecraft PE (`com.mojang.minecraftpe`)
- COD Mobile (`com.activision.callofduty`, `com.garena.game.codm`)
- *Custom games*: Bisa ditambahkan dengan mudah di file `game_list.txt`.

---

## 🛠️ Fitur & Arsitektur Utama

1. **Dynamic Frequency & Power Governance**:
   - Menurunkan konsumsi daya saat idle dan chatting.
   - Deteksi layar mati (`lcd-backlight/brightness == 0`) yang seketika mengaktifkan mode hemat daya untuk deep sleep.
2. **AppZygote Zombie Purger**:
   - Membersihkan bangkai proses terisolasi (Chrome/Webview AppZygote) tanpa membunuh aplikasi yang sedang dipakai.
3. **eMMC 5.1 Storage Optimization**:
   - `read_ahead_kb = 512KB` untuk partisi internal flash eMMC 5.1.
   - `rq_affinity = 2` dan `iostats = 0` memangkas overhead CPU scheduler.
4. **ZRAM Writeback Guard**:
   - Mencegah keausan chip eMMC dengan membatasi writeback page swap ke 65536 pages.
5. **Pixel 9 Pro XL Spoofing Aman**:
   - Identitas global aplikasi menggunakan Pixel 9 Pro XL tanpa merusak modem/sinyal cellular (radio baseband tetap terkunci di `blossom`).
6. **Magisk OTA Update Support**:
   - Dilengkapi `updateJson` resmi sehingga dapat diperbarui langsung dengan 1 ketukan di aplikasi Magisk.

---

## 📲 Cara Pemasangan

### Opsi 1: Lewat Magisk App
1. Unduh file `HelioG35-Optimizer-v3.1-dynamic.zip` dari tab [Releases](https://github.com/arbdevai/helio-g35-memory-optimizer/releases).
2. Buka **Magisk App** -> Tab **Modules** -> **Install from storage**.
3. Pilih file zip yang diunduh.
4. Selesai! Modul langsung aktif tanpa perlu restart HP.

### Opsi 2: Lewat Termux / Root Shell
```sh
su -c "/data/adb/magisk/magisk --install-module /sdcard/HelioG35-Optimizer-v3.1-dynamic.zip"
```

---

## 🔄 Pembaruan OTA (Over-The-Air)
Modul ini mendukung pembaruan otomatis Magisk. Setiap ada pembaruan versi di repositori ini, tab Modules di Magisk App akan memunculkan tombol **Update**.
