source "$MODPATH/common.sh"

remove_package_updates google

echo
echo "[P] Processing files to remove..."
echo "-------------------------------------------"
echo "[M] FILE/DIR                         STATUS"
echo "-------------------------------------------"
for file in $remove_files; do
	printf "%-40s %s\n" "[I] .../$(basename "$file")" "OK"
	mknod "$MODPATH/$file" c 0 0
done
echo "-------------------------------------------"
echo '[I] Done processing files.'

echo
echo "[P] Extracting libraries..."
unzip -q -o "$MODPATH/$gms_path" 'lib/*' -d "$MODPATH/$gms_dir"
mv "$MODPATH/$gms_dir/lib/arm64-v8a" "$MODPATH/$gms_dir/lib/arm64"
mv "$MODPATH/$gms_dir/lib/armeabi-v7a" "$MODPATH/$gms_dir/lib/arm"
# mv "$MODPATH/$gms_dir/lib/x86" "$MODPATH/$gms_dir/lib/x86"
# mv "$MODPATH/$gms_dir/lib/x86_64" "$MODPATH/$gms_dir/lib/x64"
echo "-------------------------------------------"
echo "[M] FILE                             STATUS"
echo "-------------------------------------------"

for file in $(find "$MODPATH/$gms_dir/lib/$ARCH" -type f); do
	printf "%-40s %s\n" "[I] $(basename $file)" "OK"
done
echo "-------------------------------------------"
echo '[I] Done extracting libraries.'
echo
echo "============================================"
echo "[W] If this is fresh installation (not update),"
echo "after reboot, click Action to grant permissions."
echo "============================================"
