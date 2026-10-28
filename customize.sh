SKIPUNZIP=0

ui_print "***********************************************"
ui_print "*   Helio G35 Dynamic Optimizer v3.1          *"
ui_print "***********************************************"
ui_print "- Author: Antigravity"
ui_print "- Target: Redmi 9C (blossom) | Helio G35 MT6765G"
ui_print "- Mode: Dynamic Foreground Game Listener"
ui_print "- Power: Auto-Switch Game Boost vs Balanced"
ui_print "- Storage: eMMC 5.1 512KB queue & I/O priority"
ui_print "- VM: Swappiness 160 + ZRAM Writeback Guard"
ui_print "-----------------------------------------------"

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/action.sh 0 0 0755

ui_print "- Instalasi modul Magisk berhasil!"
