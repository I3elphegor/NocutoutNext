#!/system/bin/sh

# Determining the absolute path to this module's folder
MODDIR="${0%/*}"

# Wait til the system indicates that the basic boot process is complete
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Wait til the Package Manager (application manager) is fully responsive
while ! pm path android >/dev/null 2>&1; do
    sleep 2
done

# Checkin the Android API (runs on API level 34 and higher)
API_LEVEL=$(getprop ro.build.version.sdk)

if [ "$API_LEVEL" -ge 34 ]; then
    # Path to the source APK within your module
    ORIG_APK="$MODDIR/system/product/overlay/DisplayCutoutEmulationNone/DisplayCutoutEmulationNoneOverlay.apk"
    # A temporary secure path to which the system installer has full access
    TMP_APK="/data/local/tmp/DisplayCutoutEmulationNoneOverlay.apk"  
    if [ -f "$ORIG_APK" ]; then
        # Copying to a temporary directory
        cp "$ORIG_APK" "$TMP_APK"
        chmod 644 "$TMP_APK"
        
        # Silent installation from a secure location without logging
        pm install --user 0 -r "$TMP_APK"
        # With logging
        # pm install --user 0 -r "$TMP_APK" > /data/local/tmp/nocutout_log.txt 2>&1
        
        # Deleting a temporary file (cleanup)
        rm "$TMP_APK"
    fi
fi

# DYNAMIC UPDATE OF MODULE DESCRIPTION 
# Wait until the overlay service actually starts working after boot
while ! cmd overlay list --user 0 2>/dev/null | grep -q "android"; do
    sleep 1
done
# Get ONLY the active package
ACTIVE_PKG=$(cmd overlay list --user 0 2>/dev/null | grep -F '[x]' | grep 'cutout' | head -n 1 | sed 's/.*\[x\][[:space:]]*//' | tr -d '\r')

# Find which package containing "cutout" is marked with [x] (active)
# ACTIVE_PKG=$(cmd overlay list | grep '\[x\]' | grep 'cutout' | head -n 1 | sed -E 's/^\[x\]\s+//')

# Translate the package name into human-readable text
if [ -z "$ACTIVE_PKG" ]; then
    STATUS="System Default"
elif [ "$ACTIVE_PKG" = "com.android.internal.display.cutout.emulation.none" ]; then
    STATUS="No cutout Next ✅"
else
    # Strips the long "com.android.internal..." prefix and leaves only the cutout name (e.g., hole, corner)
    STATUS=$(echo "$ACTIVE_PKG" | sed -E 's/.*\.//')
fi

# Define your base static module description
# BASE_DESC="Remove the cutout/notch and with it that black bar on top on your phone's display."

# Use 'sed' to rewrite the description line in module.prop
if [ -f "$MODDIR/module.prop" ]; then
    sed -i "s|^description=.*|description=Active overlay: $STATUS|" "$MODDIR/module.prop"
fi