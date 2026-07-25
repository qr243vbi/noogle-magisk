#!/bin/python3
from pathlib import Path
from androguard import util
from androguard.core.apk import APK
path = next(Path("apk").glob("com.android.vending-*.apk"), None)

if path is None:
    raise FileNotFoundError("APK not found")

util.set_log("CRITICAL")

def read_prop(filename):
    result = {}
    with open(filename) as f:
        for line in f:
            if "=" in line:
                k, v = line.rstrip("\n").split("=", 1)
                result[k] = v
    return result


def write_prop(filename, props):
    with open(filename, "w") as f:
        for k, v in props.items():
            f.write(f"{k}={v}\n")

apk = APK(str(path))
nums = apk.get_androidversion_name().split(".")
version = 'v' + nums[1] + '.' + nums[2]
versionCode = nums[1] + nums[2].zfill(2)

print (version)
print (versionCode)

prop = 'src/module-microg/module.prop'
dict = read_prop(prop)
dict['versionCode'] = versionCode
dict['version'] = version

print(dict)

write_prop(prop, dict)
