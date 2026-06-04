MODDIR="${0%/*}"
source "$MODDIR/common.sh"

log_path=/data/adb/noogle-microg.log
echo "[I] Starting noogle-microg boot script." > "$log_path"

# Wait for system to be ready
until [ "$(getprop sys.boot_completed)" = "1" ]; do
	sleep 1
done

# Ensure Google updates are not installed
# remove_package_updates google >> "$log_path" 2>&1

# Doesn't work for some reason, needs manual interaction
# grant_microg_permissions >> "$log_path" 2>&1

echo "[I] Finished noogle-microg boot script." >> "$log_path" 2>&1