import os
import zipfile

module_dir = "/home/coder/projects/helio-g35-memory-optimizer"
out_zips = [
    os.path.join(module_dir, "HelioG35-Optimizer-v3.1-dynamic.zip"),
    "/mnt/sdcard/HelioG35-Optimizer-v3.1-dynamic.zip",
    os.path.join(module_dir, "HelioG35-Optimizer-v3.0-prod.zip"),
    "/mnt/sdcard/HelioG35-Optimizer-v3.0-prod.zip",
]

files_to_pack = [
    "module.prop",
    "service.sh",
    "action.sh",
    "customize.sh",
    "game_list.txt",
    "update.json",
    "changelog.md",
]

def build_zip(zip_path):
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        for fname in files_to_pack:
            fpath = os.path.join(module_dir, fname)
            if os.path.exists(fpath):
                with open(fpath, 'rb') as f:
                    content = f.read().replace(b'\r\n', b'\n')
                zinfo = zipfile.ZipInfo(fname)
                zinfo.external_attr = 0o755 << 16 if fname.endswith('.sh') else 0o644 << 16
                zf.writestr(zinfo, content)
    print(f"Created: {zip_path}")

for zp in out_zips:
    try:
        build_zip(zp)
    except Exception as e:
        print(f"Could not write {zp}: {e}")
