# Helio G35 Dynamic Optimizer (blossom / angelica)

[![Magisk](https://img.shields.io/badge/Magisk-30.7+-brightgreen.svg)](https://github.com/topjohnwu/Magisk)
[![Target](https://img.shields.io/badge/SoC-MediaTek%20Helio%20G35%20(MT6765G)-orange.svg)]()
[![Platform](https://img.shields.io/badge/OS-Android%2014%20(RisingOS%20v5.1)-blue.svg)]()
[![License](https://img.shields.io/badge/License-MIT-purple.svg)]()

Production-grade, forensic-level dynamic memory, power-saving, and gaming performance optimizer designed specifically for **Xiaomi Redmi 9C (`blossom` / `angelica`)** running custom Android 14 ROMs (RisingOS v5.1).

---

## ⚡ Solusi A+: Field-Hardened Dynamic Engine (v3.2)

Unlike traditional Magisk tweak modules that force high clocks and power-hungry states 24/7, this module introduces an autonomous, zero-overhead background listener directly tapping kernel sysfs & cgroups:

```
┌─────────────────────────────────────────────────────────────────┐
│                      DAEMON LISTENER v3.2                       │
│           (Cek setiap 3 detik via /dev/cpuset/top-app)          │
└────────────────┬───────────────────────────────┬────────────────┘
                 │                               │
        [GAME TERDETEKSI]               [NON-GAME / IDLE]
       (Roblox, MLBB, dll)             (Chatting, Home, Layar Mati)
                 │                               │
                 ▼                               ▼
       🚀 MODE GAME AKTIF              🍃 MODE BALANCED AKTIF
  • GPU Boost & GED Game Mode = 1  • GPU Clocks = 0 (Balanced/Smart)
  • Touch Glove Mode = 1 (Sensitif) • Touch Glove Mode = 0 (Normal)
  • MTK PPM FORCE_LIMIT = 0        • MTK PPM FORCE_LIMIT = 0
  • MTK PPM PWR_THRO = 0           • MTK PPM PWR_THRO = 0
  • Wi-Fi HAL: Managed by OS       • Wi-Fi HAL: Managed by OS
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

## 🛠️ Fitur & Arsitektur Utama (v3.2)

1. **ZRAM Writeback Token Auto-Refill (Bugfix Krusial)**:
   - Kernel Linux membatasi penulisan writeback via kuota `writeback_limit`. Begitu kuota habis, writeback macet diam-diam.
   - v3.2 mengotomatisasi pengisian token (65536 pages / 256MB) setiap siklus maintenance, menjamin ZRAM tidak akan pernah stuck selamanya.
2. **Wi-Fi Stability Lock (Zero Domino Effect)**:
   - Menghapus saklar intervensi `setCAM` dan `iw power_save` agresif di runtime loop yang memicu desync firmware chip MediaTek (`halSetFWOwn` vs `DRIVER OWN`).
   - Manajemen radio diserahkan ke native Android 14 `WifiLockManager` dan Wi-Fi HAL, menjamin koneksi internet tidak akan pernah mati/bengong sendiri.
3. **DevBox & Chroot VIP Citizen Shield**:
   - Melindungi proses DevBox (`m.arbdev.devbox`), `agy`, compiler, dan daemon chroot dari Android LMKD dengan menyetel `oom_score_adj = -900`.
   - Android dipaksa mematikan aplikasi bloatware/cached terlebih dahulu bila RAM kritis, dan dilarang mengganggu DevBox.
4. **MediaTek PPM Policy Optimization**:
   - Mematikan `PPM_POLICY_FORCE_LIMIT` dan `PPM_POLICY_PWR_THRO` agar prosesor 8-core Helio G35 tidak dicekik MediaTek saat beban komputasi berat.
   - Mempertahankan `PPM_POLICY_THERMAL` aktif untuk proteksi hardware terhadap panas berlebih.
5. **AppZygote Forensic Zombie Purger**:
   - Watchdog memindai forking liar dari aplikasi sosmed/browser yang mengendap di RAM setiap 15 menit dan membasminya dengan aman.
6. **eMMC 5.1 Storage I/O Optimization**:
   - Menyetel `read_ahead_kb = 512KB`, `nr_requests = 256`, dan `rq_affinity = 2`.
7. **Official Magisk OTA**:
   - Dukungan update 1-klik langsung melalui tab Modules aplikasi Magisk (`update.json`).

---

## 📦 Instalasi

1. Download `HelioG35-Optimizer-v3.2-dynamic.zip` dari [Releases](../../releases).
2. Buka aplikasi **Magisk** atau **KernelSU** / **APatch**.
3. Masuk ke tab **Modules** -> **Install from storage**.
4. Pilih file zip, lalu reboot perangkat (atau jalankan action trigger untuk pembersihan instan).
