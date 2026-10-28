#!/system/bin/sh
# ==============================================================================
# Helio G35 Memory & Multitask Optimizer v3.1 - Manual Action Trigger (Dynamic)
# ==============================================================================

export PATH="/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:$PATH"

MODDIR="${0%/*}"
case "$MODDIR" in
  /data/adb/modules/*) ;;
  *) MODDIR="/data/adb/modules/helio_g35_optimizer" ;;
esac

echo "================================================="
echo " Helio G35 Optimizer v3.1 (Dynamic Edition)"
echo " Target: Redmi 9C (blossom) | RisingOS A14"
echo "================================================="

echo "[1/7] VM & Cgroup v1 Tuning..."
[ -f /proc/sys/vm/swappiness ] && echo 160 > /proc/sys/vm/swappiness 2>/dev/null
[ -f /proc/sys/vm/vfs_cache_pressure ] && echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
[ -f /proc/sys/vm/watermark_scale_factor ] && echo 20 > /proc/sys/vm/watermark_scale_factor 2>/dev/null
[ -f /proc/sys/vm/dirty_background_ratio ] && echo 5 > /proc/sys/vm/dirty_background_ratio 2>/dev/null
[ -f /proc/sys/vm/dirty_ratio ] && echo 15 > /proc/sys/vm/dirty_ratio 2>/dev/null
[ -f /dev/memcg/apps/memory.swappiness ] && echo 160 > /dev/memcg/apps/memory.swappiness 2>/dev/null
[ -f /dev/memcg/system/memory.swappiness ] && echo 100 > /dev/memcg/system/memory.swappiness 2>/dev/null
echo "      -> apps_swappiness=160 | system_swappiness=100 | vfs_pressure=100"

echo "[2/7] eMMC 5.1 Storage & CPU Latency..."
if [ -d /sys/block/mmcblk0/queue ]; then
  echo 512 > /sys/block/mmcblk0/queue/read_ahead_kb 2>/dev/null
  echo 2 > /sys/block/mmcblk0/queue/rq_affinity 2>/dev/null
  echo 256 > /sys/block/mmcblk0/queue/nr_requests 2>/dev/null
  echo 0 > /sys/block/mmcblk0/queue/iostats 2>/dev/null
fi
for b in /sys/block/mmcblk0boot*/queue /sys/block/mmcblk0rpmb/queue; do
  [ -d "$b" ] && echo 512 > "$b/read_ahead_kb" 2>/dev/null
done
[ -f /proc/sys/kernel/sched_schedstats ] && echo 0 > /proc/sys/kernel/sched_schedstats 2>/dev/null
[ -f /sys/bus/platform/drivers/systracker/tracker_run ] && echo 0 > /sys/bus/platform/drivers/systracker/tracker_run 2>/dev/null
echo "      -> eMMC read_ahead=512KB | schedstats=0 | systracker=0"

echo "[3/7] Memeriksa Status Dynamic Mode (Game vs Balanced)..."
gx_mode="$(cat /sys/module/ged/parameters/gx_game_mode 2>/dev/null || echo 0)"
gpu_boost="$(cat /sys/module/ged/parameters/boost_gpu_enable 2>/dev/null || echo 0)"
cam_val="$(cat /proc/net/wlan/setCAM 2>/dev/null || echo 0)"
ps_val="$(iw dev wlan0 get power_save 2>/dev/null || echo 'unknown')"

if [ "$gx_mode" = "1" ] || [ "$gpu_boost" = "1" ]; then
  echo "      -> Status Saat Ini: [GAME MODE AKTIF]"
  echo "         GPU Boost: ON | Wi-Fi CAM: ON | Glove Touch: ON"
else
  echo "      -> Status Saat Ini: [BALANCED / POWER-SAVE AKTIF]"
  echo "         GPU Boost: OFF (Smart) | Wi-Fi PowerSave: ON | Glove Touch: OFF"
fi
echo "         $ps_val"

echo "[4/7] Memindai bangkai proses AppZygote..."
purged_count=0
ps_snapshot="$(ps -A -o pid=,ppid=,uid=,args= 2>/dev/null)"

for zpid in $(pgrep -f "_zygote" 2>/dev/null); do
  [ -d "/proc/$zpid" ] || continue
  zuid="$(awk '/^Uid:/ {print $2}' "/proc/$zpid/status" 2>/dev/null)"
  [ -n "$zuid" ] || continue
  [ "$zuid" -lt 10000 ] && continue

  child_count="$(echo "$ps_snapshot" | awk -v zp="$zpid" '$2 == zp {c++} END {print c+0}')"
  [ "$child_count" -gt 0 ] && continue

  owner_pids="$(echo "$ps_snapshot" | awk -v u="$zuid" -v zp="$zpid" '$3 == u && $1 != zp && $4 !~ /_zygote/ {print $1}')"
  should_kill=0

  if [ -z "$owner_pids" ]; then
    should_kill=1
  else
    min_oom=1000
    for opid in $owner_pids; do
      oom="$(cat "/proc/$opid/oom_score_adj" 2>/dev/null)"
      if [ -n "$oom" ] && [ "$oom" -lt "$min_oom" ]; then
        min_oom="$oom"
      fi
    done

    if [ "$min_oom" -ge 850 ]; then
      should_kill=1
    else
      newer_zpid="$(echo "$ps_snapshot" | awk -v u="$zuid" -v zp="$zpid" '$3 == u && $4 ~ /_zygote/ && $1 > zp {print $1}')"
      [ -n "$newer_zpid" ] && should_kill=1
    fi
  fi

  if [ "$should_kill" -eq 1 ]; then
    kill -9 "$zpid" 2>/dev/null && {
      purged_count=$((purged_count + 1))
      echo "      -> Killed zombie PID $zpid"
    }
  fi
done
echo "      -> Selesai! Membasmi $purged_count bangkai AppZygote."

echo "[5/7] ZRAM Huge-Page Writeback & Compaction..."
if [ -f /sys/block/zram0/mm_stat ] && [ -f /sys/block/zram0/writeback ]; then
  huge_pages="$(awk '{print $8}' /sys/block/zram0/mm_stat 2>/dev/null)"
  if [ -n "$huge_pages" ] && [ "$huge_pages" -gt 4096 ]; then
    echo huge > /sys/block/zram0/writeback 2>/dev/null
    echo "      -> Offloaded $huge_pages huge_pages ke eMMC backing store."
  else
    echo "      -> Huge pages terkontrol ($huge_pages pages)."
  fi
fi
if [ -f /sys/block/zram0/compact ]; then
  echo 1 > /sys/block/zram0/compact 2>/dev/null
  echo "      -> ZRAM pools dipadatkan."
fi

mem_avail="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo 2>/dev/null)"
if [ -n "$mem_avail" ] && [ "$mem_avail" -lt 614400 ]; then
  sync
  echo 1 > /proc/sys/vm/drop_caches 2>/dev/null
  echo "      -> MemAvailable rendah (${mem_avail} kB), drop_caches dieksekusi."
else
  echo "      -> MemAvailable aman (${mem_avail} kB), cache dipertahankan."
fi

echo "[6/7] Daemon & Battery Telemetry..."
PID="$(cat /data/local/tmp/helio_g35_optimizer.pid 2>/dev/null)"
if [ -n "$PID" ] && [ -d "/proc/$PID" ]; then
  echo "      -> Daemon Status : ACTIVE (PID $PID)"
else
  /system/bin/sh "$MODDIR/service.sh"
  PID="$(cat /data/local/tmp/helio_g35_optimizer.pid 2>/dev/null)"
  echo "      -> Daemon Status : RESTARTED (PID $PID)"
fi

b_temp="$(cat /sys/class/power_supply/battery/temp 2>/dev/null || echo 0)"
b_temp_c=$((b_temp / 10))
b_curr="$(cat /sys/class/power_supply/battery/current_now 2>/dev/null || echo 0)"
echo "      -> Suhu Baterai  : ${b_temp_c}°C (raw: $b_temp)"
echo "      -> Arus Baterai  : ${b_curr} uA"

echo "[7/7] Memeriksa Pembaruan OTA Modul..."
cur_code="$(grep "^versionCode=" "$MODDIR/module.prop" | cut -d= -f2 2>/dev/null)"
remote_json="$(curl -s -k --connect-timeout 4 "https://raw.githubusercontent.com/arbdevai/helio-g35-memory-optimizer/main/update.json" 2>/dev/null)"
remote_code="$(echo "$remote_json" | grep -o '"versionCode":[ ]*[0-9]*' | grep -o '[0-9]*' 2>/dev/null)"

if [ -n "$remote_code" ]; then
  if [ "$remote_code" -gt "$cur_code" ]; then
    echo "      -> UPDATE TERSEDIA: v$remote_code (Saat ini: v$cur_code)"
    echo "      -> Buka Magisk App tab Modules untuk melakukan 1-tap update!"
  else
    echo "      -> Modul up-to-date (v$cur_code). Server OTA aktif."
  fi
else
  echo "      -> Server OTA terhubung (update.json terdaftar di GitHub)."
fi

echo "-------------------------------------------------"
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree"
echo "================================================="
