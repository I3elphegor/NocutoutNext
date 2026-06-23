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
        
        # Silent installation from a secure location
        # No logging:
        pm install --user 0 -r "$TMP_APK"
       
        # logging:
        # pm install --user 0 -r "$TMP_APK" > /data/local/tmp/nocutout_log.txt 2>&1
        
        # Deleting a temporary file (cleanup)
        rm "$TMP_APK"
    fi
fi