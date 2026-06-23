#!/bin/sh
SKIPUNZIP=0

# Determine the environment cleanly using native variables
if [ "$KSU" = "true" ]; then
    ROOT_SOLUTION="KernelSU"
elif [ "$APATCH" = "true" ]; then
    ROOT_SOLUTION="APatch"
else
    ROOT_SOLUTION="Magisk"
fi

ui_print "********************************************"
ui_print "- Detected root environment: $ROOT_SOLUTION"
ui_print "********************************************"

# Execute specific logic and warnings based on the detected solution
if [ "$ROOT_SOLUTION" = "KernelSU" ]; then
    ui_print "- RRO overlay to remove cutout has been installed..."
    ui_print "- Notice: KernelSU may require an additional"
    ui_print "  metamodule (e.g., meta-overlayfs) installed!"
elif [ "$ROOT_SOLUTION" = "APatch" ]; then
    ui_print "- RRO overlay to remove cutout has been installed..."
    ui_print "- Notice: APatch may require an additional uMount plugin."
else
    ui_print "- Installing via native Magic Mount..."
    ui_print "- Everything will run automatically."
fi
ui_print "********************************************"

# Set secure permissions
set_perm_recursive $MODPATH/system 0 0 0755 0644