# Changelog Helio G35 Optimizer

## v3.1-dynamic (Solusi A - Dynamic Foreground Game Listener)
- **Dynamic Game Detection**: Otomatis mendeteksi game yang sedang aktif di foreground (`/dev/cpuset/top-app/cgroup.procs`).
- **Auto-Switch Power States**:
  - Saat bermain game (Roblox, MLBB, FreeFire, dll): GPU Boost, MediaTek GED game mode, Wi-Fi CAM (zero latency), dan Touch Glove Mode aktif.
  - Saat keluar game / chatting / idle: GPU balanced, Wi-Fi Power Save ON (menghemat 50-80 mA idle), Glove touch OFF.
- **Deep Sleep Preservation**: Layar mati otomatis menurunkan clocks dan mengizinkan deep sleep CPU & Wi-Fi.
- **Zombie Purger**: Membasmi bangkai AppZygote dan runaway process.
- **Official Magisk OTA**: Dukungan resmi Magisk OTA Update (`updateJson`) langsung dari GitHub.
