#!/bin/sh

apk_dir=apk
src_dir=src
dist_dir=dist
module_dir=module-microg
destination_dir=system/product
suffix=MG

show_help() {
	echo "Usage: $0 [options]"
	echo "Options:
	  -h          Show this help message
	  -d <dir>    Specify the destination partition [system|product|system_ext] (default: product)
	  -s <suffix>  Specify the suffix to add to the directories and APK names (default: MG)"
	exit 0
}

while getopts "hd:s:" opt; do
	case $opt in
		h)
			show_help
			;;
		d)
			case $OPTARG in
				system)
					destination_dir=system
					;;
				product)
					destination_dir=system/product
					;;
				system_ext)
					destination_dir=system/system_ext
					;;
				*)
					echo "[E] Invalid destination partition: $OPTARG"
					show_help
					;;
			esac
			;;
		s)
			suffix="$OPTARG"
			;;
		*)
			show_help
			;;
	esac
done

echo "[P] Building module noogle-microg..."

rm -rf "$module_dir"
mkdir -p "$module_dir"

echo "[P] Checking for APK files..."

for apk in "com.google.android.gms" "com.android.vending" "com.google.android.gsf"; do
	if ls "$apk_dir/$apk"* 1> /dev/null 2>&1; then
		echo "[I] $apk: PRESENT"
	else
		echo "[W] $apk: MISSING"
	fi
done

apk_count=$(ls "$apk_dir/com.google.android.gms"* "$apk_dir/com.android.vending"* "$apk_dir/com.google.android.gsf"* 2>/dev/null | wc -l)
if [ "$apk_count" -lt 3 ]; then
	echo "[E] Missing one or more required APKs in $apk_dir/, use ./download-apks.sh to download them or do it manually"
	exit 1
elif [ "$apk_count" -gt 3 ]; then
	echo "[E] Too many APKs, the $apk_dir/ directory must contain exactly 3 APK files"
	exit 1
fi

echo "[P] Re-signing GsfProxy with v1+v2..."

keystore="$apk_dir/.keystore"
key_alias="noogle"
key_pass="noogle"

if [ ! -f "$keystore" ]; then
	echo "[I] Generating keystore..."
	keytool -genkey -v -keystore "$keystore" -alias "$key_alias" \
		-keyalg RSA -keysize 2048 -validity 10000 \
		-storepass "$key_pass" -keypass "$key_pass" \
		-dname "CN=Noogle, OU=Dev, O=Dev, L=NA, ST=NA, C=US"
fi

gsf_apk=$(ls "$apk_dir"/com.google.android.gsf*.apk 2>/dev/null | head -1)
apksigner sign --v1-signing-enabled true --v2-signing-enabled true \
	--ks "$keystore" --ks-key-alias "$key_alias" \
	--ks-pass "pass:$key_pass" --key-pass "pass:$key_pass" \
	"$gsf_apk"

rm -f "$apk_dir"/*.idsig

echo "[P] Copying APKs to module directory..."
gms_dir="$destination_dir/priv-app/GmsCore$suffix"
mkdir -p "$module_dir/$gms_dir"
mkdir -p "$module_dir/$destination_dir/priv-app/Phonesky$suffix"
mkdir -p "$module_dir/$destination_dir/priv-app/GoogleServicesFramework$suffix"
mkdir -p "$module_dir/system/system_ext/priv-app"

gms_path="$gms_dir/GmsCore$suffix.apk"
cp "$apk_dir"/com.google.android.gms*.apk "$module_dir/$gms_path"
cp "$apk_dir"/com.android.vending*.apk "$module_dir/$destination_dir/priv-app/Phonesky$suffix/Phonesky$suffix.apk"
cp "$apk_dir"/com.google.android.gsf*.apk "$module_dir/$destination_dir/priv-app/GoogleServicesFramework$suffix/GoogleServicesFramework$suffix.apk"

echo "[P] Copying module files to module directory..."
cp -r "$src_dir/$module_dir"/* "$module_dir/"
mv "$module_dir/etc" "$module_dir/$destination_dir/"

echo "[P] Patching customize script..."
sed -i "1i gms_path=$gms_path" "$module_dir/customize.sh"
sed -i "1i gms_dir=$gms_dir" "$module_dir/customize.sh"

echo "[P] Removing service script... (doesn't work)"
rm -f "$module_dir/service.sh"

module_version="$(grep '^version=' "$src_dir/$module_dir/module.prop" | cut -d'=' -f2)"
echo "[I] Module version: $module_version"
module_filename="noogle-microg-$module_version.zip"

echo "[P] Compressing module archive..."
mkdir -p "$dist_dir"
rm -f "$dist_dir/$module_filename"
cd "$module_dir" || exit
zip -q -r "../$dist_dir/$module_filename" . -x **/.gitkeep
cd - || exit

echo "[I] Module noogle-microg built successfully!"   
