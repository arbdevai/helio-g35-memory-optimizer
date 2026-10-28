#!/system/bin/sh
# ==============================================================================
# Helio G35 Memory & Multitask Optimizer - Production Engine v3.1 (Dynamic)
# Target Device: Xiaomi Redmi 9C (blossom / angelica) | RisingOS Android 14
# Target SoC: MediaTek Helio G35 (MT6765G) | 8x Cortex-A53 | 4GB LPDDR4x
# Architecture: Solusi A - Dynamic Foreground Game Listener & Power-Saving Engine
# ==============================================================================

export PATH="/data/adb/magisk:/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:$PATH"

MODDIR="${0%/*}"
case "$MODDIR" in
  /data/adb/modules/*) ;;
  *) MODDIR="/data/adb/modules/helio_g35_optimizer" ;;
esac

LOGFILE="$MODDIR/optimizer.log"
PIDFILE="/data/local/tmp/helio_g35_optimizer.pid"
GAMELIST="$MODDIR/game_list.txt"
MAX_LOG_SIZE=30720 # 30 KB

# --- 1. Launcher Mode: Detach via setsid & Exit Non-Blocking ---
if [ "$1" != "--daemon" ]; then
  if [ -f "$PIDFILE" ]; then
    OLD_PID="$(cat "$PIDFILE" 2>/dev/null)"
    if [ -n "$OLD_PID" ] && [ -d "/proc/$OLD_PID" ]; then
      if grep -q "helio_g35_optimizer.*--daemon" "/proc/$OLD_PID/cmdline" 2>/dev/null; then
        exit 0
      fi
    fi
    rm -f "$PIDFILE" 2>/dev/null
  fi

  /system/bin/setsid /system/bin/sh "$MODDIR/service.sh" --daemon </dev/null >/dev/null 2>&1 &
  sleep 1
  exit 0
fi

# --- 2. Detached Session Leader Daemon (--daemon) ---
trap '' HUP
DAEMON_PID="$$"
echo "$DAEMON_PID" > "$PIDFILE"

cleanup() {
  local cur_pid
  cur_pid="$(cat "$PIDFILE" 2>/dev/null)"
  [ "$cur_pid" = "$DAEMON_PID" ] && rm -f "$PIDFILE" 2>/dev/null
}
trap cleanup EXIT INT TERM

log_msg() {
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$ts] $1" >> "$LOGFILE"
}

rotate_log() {
  if [ -f "$LOGFILE" ]; then
    local sz
    sz="$(wc -c < "$LOGFILE" 2>/dev/null || echo 0)"
    if [ "$sz" -gt "$MAX_LOG_SIZE" ]; then
      tail -n 100 "$LOGFILE" > "$LOGFILE.tmp" 2>/dev/null
      mv -f "$LOGFILE.tmp" "$LOGFILE" 2>/dev/null
    fi
  fi
}

# Wait until Android boot completes
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 3
done

# Allow post-boot init scripts to settle
sleep 5
log_msg "Boot verified (Daemon PID=$DAEMON_PID). Initializing v3.1 Dynamic Engine..."

# --- 3. Resolve RisingOS RAMBoost Conflict & Tune Cgroups/VM ---
apply_vm_and_cgroup_tuning() {
  if [ "$(getprop persist.sys.ramboost_enabled)" = "true" ]; then
    resetprop -n persist.sys.ramboost_enabled false 2>/dev/null || setprop persist.sys.ramboost_enabled false 2>/dev/null
  fi

  [ -f /proc/sys/vm/swappiness ] && echo 160 > /proc/sys/vm/swappiness 2>/dev/null
  [ -f /proc/sys/vm/vfs_cache_pressure ] && echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
  [ -f /proc/sys/vm/watermark_scale_factor ] && echo 20 > /proc/sys/vm/watermark_scale_factor 2>/dev/null
  [ -f /proc/sys/vm/dirty_background_ratio ] && echo 5 > /proc/sys/vm/dirty_background_ratio 2>/dev/null
  [ -f /proc/sys/vm/dirty_ratio ] && echo 15 > /proc/sys/vm/dirty_ratio 2>/dev/null
  [ -f /proc/sys/vm/page-cluster ] && echo 0 > /proc/sys/vm/page-cluster 2>/dev/null

  [ -f /dev/memcg/apps/memory.swappiness ] && echo 160 > /dev/memcg/apps/memory.swappiness 2>/dev/null
  [ -f /dev/memcg/system/memory.swappiness ] && echo 100 > /dev/memcg/system/memory.swappiness 2>/dev/null
}

# --- 4. eMMC 5.1 Storage I/O Optimization ---
apply_storage_tuning() {
  if [ -d /sys/block/mmcblk0/queue ]; then
    echo 512 > /sys/block/mmcblk0/queue/read_ahead_kb 2>/dev/null
    echo 2 > /sys/block/mmcblk0/queue/rq_affinity 2>/dev/null
    echo 256 > /sys/block/mmcblk0/queue/nr_requests 2>/dev/null
    echo 0 > /sys/block/mmcblk0/queue/iostats 2>/dev/null
  fi
  for b in /sys/block/mmcblk0boot*/queue /sys/block/mmcblk0rpmb/queue; do
    [ -d "$b" ] && echo 512 > "$b/read_ahead_kb" 2>/dev/null
  done
}

# --- 5. CPU & Bus Overhead Elimination ---
apply_cpu_and_bus_tuning() {
  [ -f /proc/sys/kernel/sched_schedstats ] && echo 0 > /proc/sys/kernel/sched_schedstats 2>/dev/null
  [ -f /sys/bus/platform/drivers/systracker/tracker_run ] && echo 0 > /sys/bus/platform/drivers/systracker/tracker_run 2>/dev/null
}

# --- 6. Network Base Tuning (Wi-Fi Scan Throttling Re-enabled for Battery) ---
apply_network_base_tuning() {
  [ -f /proc/sys/net/ipv4/tcp_congestion_control ] && echo cubic > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
  [ -f /proc/sys/net/ipv4/tcp_keepalive_time ] && echo 300 > /proc/sys/net/ipv4/tcp_keepalive_time 2>/dev/null
  [ -f /proc/sys/net/ipv4/tcp_keepalive_intvl ] && echo 15 > /proc/sys/net/ipv4/tcp_keepalive_intvl 2>/dev/null
  [ -f /proc/sys/net/ipv4/tcp_keepalive_probes ] && echo 4 > /proc/sys/net/ipv4/tcp_keepalive_probes 2>/dev/null
  [ -f /proc/sys/net/ipv4/tcp_fin_timeout ] && echo 20 > /proc/sys/net/ipv4/tcp_fin_timeout 2>/dev/null

  [ -f /proc/sys/net/core/somaxconn ] && echo 1024 > /proc/sys/net/core/somaxconn 2>/dev/null
  [ -f /proc/sys/net/core/netdev_max_backlog ] && echo 2500 > /proc/sys/net/core/netdev_max_backlog 2>/dev/null

  iptables -t mangle -C POSTROUTING -j TTL --ttl-set 64 2>/dev/null || iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64 2>/dev/null
  # Re-enable Wi-Fi scan throttling to prevent background apps from spamming Wi-Fi scans
  settings put global wifi_scan_throttle_enabled 1 2>/dev/null
}

# --- 7. UI Responsiveness & GameSpace Config ---
apply_ui_tuning() {
  settings put global window_animation_scale 0.5 2>/dev/null
  settings put global transition_animation_scale 0.5 2>/dev/null
  settings put global animator_duration_scale 0.5 2>/dev/null

  local cur_games
  cur_games="$(settings get system gamespace_game_list 2>/dev/null)"
  case "$cur_games" in
    *com.roblox.client*) ;;
    *) settings put system gamespace_game_list "${cur_games};com.roblox.client=2" 2>/dev/null ;;
  esac
}

# --- 8. Safe Google Pixel 9 Pro XL Identity Assertion ---
apply_pixel_identity() {
  local RP="resetprop"
  [ -x /data/adb/magisk/magisk ] && RP="/data/adb/magisk/magisk resetprop"

  $RP -n ro.boot.verifiedbootstate "green"
  $RP -n ro.boot.flash.locked "1"
  $RP -n ro.boot.veritymode "enforcing"
  $RP -n ro.boot.warranty_bit "0"
  $RP -n ro.warranty_bit "0"
  $RP -n ro.debuggable "0"
  $RP -n ro.secure "1"
  $RP -n ro.build.type "user"
  $RP -n ro.build.tags "release-keys"

  $RP -n ro.product.brand "google"
  $RP -n ro.product.manufacturer "Google"
  $RP -n ro.product.model "Pixel 9 Pro XL"
  $RP -n ro.product.marketname "Pixel 9 Pro XL"

  for part in system product odm system_ext bootimage; do
    $RP -n ro.product.${part}.brand "google"
    $RP -n ro.product.${part}.manufacturer "Google"
    $RP -n ro.product.${part}.model "Pixel 9 Pro XL"
  done
  log_msg "Pixel 9 Pro XL identity asserted (Modem preserved on blossom)."
}

# --- 9. Dynamic Mode Control: Game Mode vs Balanced Mode ---
apply_game_mode() {
  local game_pkg="$1"
  log_msg "[DYNAMIC] Game detected ($game_pkg) -> ACTIVATING Game Boost (GPU high, Wi-Fi CAM on, Glove touch on)"

  if [ -d /sys/module/ged/parameters ]; then
    echo 1 > /sys/module/ged/parameters/boost_gpu_enable 2>/dev/null
    echo 1 > /sys/module/ged/parameters/ged_smart_boost 2>/dev/null
    echo 1 > /sys/module/ged/parameters/enable_gpu_boost 2>/dev/null
    echo 1 > /sys/module/ged/parameters/gx_game_mode 2>/dev/null
  fi

  iw dev wlan0 set power_save off 2>/dev/null
  [ -f /proc/net/wlan/setCAM ] && echo 1 > /proc/net/wlan/setCAM 2>/dev/null
  [ -f /proc/net/wlan/autoPerfCfg ] && echo ForceEnable:1 > /proc/net/wlan/autoPerfCfg 2>/dev/null

  local fts_glove="/sys/devices/platform/11013000.spi/spi_master/spi3/spi3.0/fts_glove_mode"
  [ -f "$fts_glove" ] && echo 1 > "$fts_glove" 2>/dev/null
}

apply_balanced_mode() {
  log_msg "[DYNAMIC] Normal/Idle state -> RESTORING Balanced Mode (GPU idle/smart, Wi-Fi PowerSave on, CAM off, Touch normal)"

  if [ -d /sys/module/ged/parameters ]; then
    echo 0 > /sys/module/ged/parameters/boost_gpu_enable 2>/dev/null
    echo 1 > /sys/module/ged/parameters/ged_smart_boost 2>/dev/null
    echo 0 > /sys/module/ged/parameters/enable_gpu_boost 2>/dev/null
    echo 0 > /sys/module/ged/parameters/gx_game_mode 2>/dev/null
  fi

  iw dev wlan0 set power_save on 2>/dev/null
  [ -f /proc/net/wlan/setCAM ] && echo 0 > /proc/net/wlan/setCAM 2>/dev/null
  [ -f /proc/net/wlan/autoPerfCfg ] && echo ForceEnable:0 > /proc/net/wlan/autoPerfCfg 2>/dev/null

  local fts_glove="/sys/devices/platform/11013000.spi/spi_master/spi3/spi3.0/fts_glove_mode"
  [ -f "$fts_glove" ] && echo 0 > "$fts_glove" 2>/dev/null
}

# --- 10. Foreground Game Detector (/dev/cpuset/top-app/cgroup.procs) ---
GAME_REGEX="com\.roblox\.client|com\.mobile\.legends|com\.mobilelegends|com\.olzhas\.carparking|com\.maleo\.bussimulatorid|com\.hoyoverse|com\.miHoYo|com\.fingersoft\.hillclimb|com\.kiloo\.subwaysurf|com\.HeavyMental|com\.dts\.freefire|com\.tencent\.ig|com\.pubg|com\.mojang\.minecraftpe|com\.garena\.game|com\.activision\.callofduty|com\.riotgames|com\.kitkagames|com\.supercell|com\.levelinfinite|com\.axlebolt|com\.robtopx|com\.konami\.pes|com\.ea\.gp\.fifa|com\.neptune\.domino"

detect_foreground_game() {
  [ -f /dev/cpuset/top-app/cgroup.procs ] || return 1
  local p_list=""
  for p in $(cat /dev/cpuset/top-app/cgroup.procs 2>/dev/null); do
    [ -f "/proc/$p/cmdline" ] && p_list="$p_list /proc/$p/cmdline"
  done
  [ -z "$p_list" ] && return 1

  local matched
  matched="$(grep -a -m 1 -E -o "$GAME_REGEX" $p_list 2>/dev/null | head -n 1)"
  if [ -n "$matched" ]; then
    echo "$matched"
    return 0
  fi

  if [ -f "$GAMELIST" ]; then
    local custom_match
    custom_match="$(grep -a -m 1 -f "$GAMELIST" $p_list 2>/dev/null | head -n 1)"
    if [ -n "$custom_match" ]; then
      echo "$custom_match"
      return 0
    fi
  fi

  return 1
}

# --- 11. Forensic AppZygote Zombie Purger & Maintenance Cycle ---
run_maintenance_cycle() {
  local purged_count=0
  local zram_wb_msg="skipped"
  local cache_msg="retained"

  local ps_snapshot
  ps_snapshot="$(ps -A -o pid=,ppid=,uid=,args= 2>/dev/null)"

  for zpid in $(pgrep -f "_zygote" 2>/dev/null); do
    [ -d "/proc/$zpid" ] || continue

    local zuid
    zuid="$(awk '/^Uid:/ {print $2}' "/proc/$zpid/status" 2>/dev/null)"
    [ -n "$zuid" ] || continue
    [ "$zuid" -lt 10000 ] && continue

    local child_count
    child_count="$(echo "$ps_snapshot" | awk -v zp="$zpid" '$2 == zp {c++} END {print c+0}')"
    [ "$child_count" -gt 0 ] && continue

    local owner_pids
    owner_pids="$(echo "$ps_snapshot" | awk -v u="$zuid" -v zp="$zpid" '$3 == u && $1 != zp && $4 !~ /_zygote/ {print $1}')"

    local should_kill=0
    if [ -z "$owner_pids" ]; then
      should_kill=1
    else
      local min_oom=1000
      for opid in $owner_pids; do
        local oom
        oom="$(cat "/proc/$opid/oom_score_adj" 2>/dev/null)"
        if [ -n "$oom" ] && [ "$oom" -lt "$min_oom" ]; then
          min_oom="$oom"
        fi
      done

      if [ "$min_oom" -ge 850 ]; then
        should_kill=1
      else
        local newer_zpid
        newer_zpid="$(echo "$ps_snapshot" | awk -v u="$zuid" -v zp="$zpid" '$3 == u && $4 ~ /_zygote/ && $1 > zp {print $1}')"
        [ -n "$newer_zpid" ] && should_kill=1
      fi
    fi

    if [ "$should_kill" -eq 1 ]; then
      kill -9 "$zpid" 2>/dev/null && purged_count=$((purged_count + 1))
    fi
  done

  # Offload incompressible huge pages (>16MB) from RAM to loop35 backing dev
  if [ -f /sys/block/zram0/mm_stat ] && [ -f /sys/block/zram0/writeback ]; then
    local huge_pages
    huge_pages="$(awk '{print $8}' /sys/block/zram0/mm_stat 2>/dev/null)"
    if [ -n "$huge_pages" ] && [ "$huge_pages" -gt 4096 ]; then
      echo huge > /sys/block/zram0/writeback 2>/dev/null
      zram_wb_msg="offloaded ${huge_pages} huge_pages"
    fi
  fi

  # Compact ZRAM memory pools
  [ -f /sys/block/zram0/compact ] && echo 1 > /sys/block/zram0/compact 2>/dev/null

  # Conditional pagecache drop: ONLY if MemAvailable < 600 MB (614400 kB)
  local mem_avail
  mem_avail="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo 2>/dev/null)"
  if [ -n "$mem_avail" ] && [ "$mem_avail" -lt 614400 ]; then
    echo 1 > /proc/sys/vm/drop_caches 2>/dev/null
    cache_msg="dropped (MemAvail=${mem_avail}kB < 600MB)"
  fi

  rotate_log
  log_msg "Maintenance ok: purged=${purged_count} zombies | zram_wb=${zram_wb_msg} | cache=${cache_msg}"
}

# --- 12. Startup Initialization ---
apply_vm_and_cgroup_tuning
apply_storage_tuning
apply_cpu_and_bus_tuning
apply_network_base_tuning
apply_ui_tuning
apply_pixel_identity

# ZRAM Writeback Safety Limit (eMMC Wear Protection)
if [ -f /sys/block/zram0/writeback_limit_enable ] && [ -f /sys/block/zram0/writeback_limit ]; then
  echo 1 > /sys/block/zram0/writeback_limit_enable 2>/dev/null
  echo 65536 > /sys/block/zram0/writeback_limit 2>/dev/null
fi

# Initial State: Balanced Mode (Cool & Battery-friendly)
CURRENT_MODE="balanced"
apply_balanced_mode
run_maintenance_cycle
log_msg "v3.1 Dynamic Engine ready. Monitoring foreground games every 3s..."

# --- 13. Dynamic Foreground Game Listener & Maintenance Watchdog ---
TICK_COUNT=0
MAINTENANCE_TICKS=300 # 300 * 3s = 900s (~15 mins)

while true; do
  sleep 3
  TICK_COUNT=$((TICK_COUNT + 1))

  # 1. Periodic Maintenance (Zombie purge & ZRAM compact every ~15m)
  if [ "$TICK_COUNT" -ge "$MAINTENANCE_TICKS" ]; then
    TICK_COUNT=0
    apply_vm_and_cgroup_tuning
    apply_storage_tuning
    apply_cpu_and_bus_tuning
    apply_network_base_tuning
    # If currently gaming, skip heavy I/O maintenance to avoid frame drops
    if [ "$CURRENT_MODE" != "game" ]; then
      run_maintenance_cycle
    fi
  fi

  # 2. Ultra-fast Display Check (When screen is off, force balanced and deep sleep)
  bl_val="$(cat /sys/class/leds/lcd-backlight/brightness 2>/dev/null || echo 1)"
  if [ "$bl_val" = "0" ]; then
    if [ "$CURRENT_MODE" = "game" ]; then
      apply_balanced_mode
      CURRENT_MODE="balanced"
    fi
    # Extra sleep while screen is locked to minimize wakeups
    sleep 3
    continue
  fi

  # 3. Check Foreground App in top-app cpuset
  fg_game="$(detect_foreground_game)"

  if [ -n "$fg_game" ]; then
    if [ "$CURRENT_MODE" != "game" ]; then
      apply_game_mode "$fg_game"
      CURRENT_MODE="game"
    fi
  else
    if [ "$CURRENT_MODE" = "game" ]; then
      apply_balanced_mode
      CURRENT_MODE="balanced"
    fi
  fi
done
