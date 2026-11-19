#!/usr/bin/env python3
"""`flutter create` yaratgan android/ papkasini lock-screen uchun moslaydi."""
import glob
import pathlib

# 1) Manifest: ruxsatlar + qulf ekrani ustida ko'rinish
mf = pathlib.Path('android/app/src/main/AndroidManifest.xml')
s = mf.read_text()
perms = [
    'android.permission.CAMERA',
    'android.permission.USE_BIOMETRIC',
    'android.permission.USE_FINGERPRINT',
    'android.permission.VIBRATE',
    'android.permission.WAKE_LOCK',
    'android.permission.DISABLE_KEYGUARD',
]
add = ''.join(f'    <uses-permission android:name="{p}"/>\n'
              for p in perms if p not in s)
add += '    <uses-feature android:name="android.hardware.camera" android:required="false"/>\n'
if 'android.permission.CAMERA' not in s:
    s = s.replace('<application', add + '    <application', 1)
if 'showWhenLocked' not in s:
    s = s.replace('<activity',
                  '<activity\n            android:showWhenLocked="true"\n'
                  '            android:turnScreenOn="true"', 1)
s = s.replace('android:label="flux_lock"', 'android:label="Flux Lock"')
mf.write_text(s)

# 2) minSdk 24 (ML Kit, secure storage, local_auth uchun)
for g in glob.glob('android/app/build.gradle*'):
    p = pathlib.Path(g)
    t = p.read_text().replace('flutter.minSdkVersion', '24')
    p.write_text(t)

# 3) local_auth FragmentActivity talab qiladi
for k in glob.glob('android/app/src/main/**/MainActivity.*', recursive=True):
    p = pathlib.Path(k)
    t = p.read_text()
    if 'FlutterFragmentActivity' not in t:
        p.write_text(t.replace('FlutterActivity', 'FlutterFragmentActivity'))

print('Android patch OK')
