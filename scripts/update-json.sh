eval "$(cat src/module-microg/module.prop | sed 's/^/declare "/g;s/$/"/g;')"
cat << EOFEOF > update-microg.json
{
        "version": "${version}",
        "versionCode": ${versionCode},
        "zipUrl": "https://github.com/qr243vbi/noogle-magisk/releases/download/${version}/noogle-microg-${version}.zip",
        "changelog": "https://raw.githubusercontent.com/qr243vbi/noogle-magisk/refs/heads/master/CHANGELOG.md"
}
EOFEOF
