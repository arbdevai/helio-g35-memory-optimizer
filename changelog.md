# Changelog Helio G35 Optimizer

## v3.2-dynamic (Solusi A+ - Field Hardened Edition)
- **Fix ZRAM Writeback Token Auto-Refill**: Mengatasi bug habisnya kuota `writeback_limit` ZRAM (kembali ke 0 setelah 2 hari) yang menyebabkan writeback macet diam-diam. Kini kuota di-refill otomatis setiap siklus maintenance.
- **Wi-Fi Stability Lock (Zero Domino Effect)**: Menghapus saklar intervensi `setCAM` dan `iw power_save` agresif di runtime loop yang memicu desync firmware MediaTek Wi-Fi. Wi-Fi HAL kini dikelola native oleh Android 14 tanpa risiko disconnect/bengong.
- **DevBox & Chroot VIP Citizen Shield**: Melindungi proses DevBox (`m.arbdev.devbox`), `agy`, and daemon chroot dari pembantaian Android LMKD dengan menyetel `oom_score_adj = -900`. Kompilasi dan task berat tetap aman saat RAM menipis.
- **MediaTek PPM Policy Unthrottle**: Menonaktifkan `PPM_POLICY_FORCE_LIMIT` dan `PPM_POLICY_PWR_THRO` agar clock 8-core CPU tidak dicekik MediaTek saat beban berat, seraya tetap menjaga `PPM_POLICY_THERMAL` sebagai proteksi hardware.
- **RisingOS RAMBoost Revert Defense**: Menjaga `apps_swappiness = 160` dan `system_swappiness = 100` agar tidak ter-override oleh trigger init RisingOS.
- **Enhanced Action.sh**: Menambahkan verifikasi status perisai DevBox, auto-refill token ZRAM, dan asynchronous eMMC discard trim (`fstrim`).

## v3.1-dynamic (Solusi A - Dynamic Foreground Game Listener)
- **Dynamic Game Detection**: Otomatis mendeteksi game yang sedang aktif di foreground (`/dev/cpuset/top-app/cgroup.procs`).
- **Auto-Switch Power States**:
  - Saat bermain game (Roblox, MLBB, FreeFire, dll): GPU Boost, MediaTek GED game mode, dan Touch Glove Mode aktif.
  - Saat keluar game / chatting / idle: GPU balanced, Glove touch OFF.
- **Deep Sleep Preservation**: Layar mati otomatis menurunkan clocks dan mengizinkan deep sleep CPU.
- **Zombie Purger**: Membasmi bangkai AppZygote dan runaway process.
- **Official Magisk OTA**: Dukungan resmi Magisk OTA Update (`updateJson`) langsung dari GitHub.
