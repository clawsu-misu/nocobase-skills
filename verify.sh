#!/usr/bin/env bash
#
# nocobase-skills — 产物完整性校验
#
# 比对 skills/ 下每个文件与 BUILD_MANIFEST.json 记录的 published_hashes。
# 用途：确认编译产物没有被手工改动过（改内容请改事实源 Bundle 再重编译）。
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
exec python3 - "$HERE" "$@" <<'PY'
import hashlib
import json
import sys
import pathlib

here = pathlib.Path(sys.argv[1])
manifest = here / "BUILD_MANIFEST.json"
skills = here / "skills"

if not manifest.is_file():
    sys.exit("✗ 找不到 BUILD_MANIFEST.json")
if not skills.is_dir():
    sys.exit("✗ 找不到 skills/ 目录")

man = json.loads(manifest.read_text(encoding="utf-8"))
published = man.get("published_hashes", {})

# manifest 里的路径相对「编译产物根」。本仓库布局把 8 个 Skill 放在 skills/ 下，
# 构建清单类文件（capability-destinations.json）放在仓库根，故两个根都试。
ROOTS = [skills, here]

NOISE = {".DS_Store", "Thumbs.db"}


def resolve(rel):
    for root in ROOTS:
        p = root / rel
        if p.is_file():
            return p
    return None


def sha256(p):
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


ok, changed, missing = [], [], []
for rel, want in sorted(published.items()):
    p = resolve(rel)
    if p is None:
        missing.append(rel)
    elif "/" not in rel:
        # 根级构建清单（capability-destinations.json 等）：只确认在位，不校验哈希
        ok.append(rel)
    elif sha256(p) != want:
        changed.append(rel)
    else:
        ok.append(rel)

# skills/ 下存在但清单里没有的文件
extra = []
for p in sorted(skills.rglob("*")):
    if not p.is_file():
        continue
    name = p.name
    if name in NOISE or ".bak-" in name:
        continue
    rel = p.relative_to(skills).as_posix()
    if rel not in published:
        extra.append(rel)

print("事实源   bundle=%s  run=%s" % (man.get("bundle_id", "?"), man.get("run_id", "?")))
print("清单记录 %d 个文件 | 已核对 %d 个" % (len(published), len(ok)))
print()

if changed:
    print("✗ 被手改（与清单哈希不一致）：")
    for r in changed:
        print("    %s" % r)
if missing:
    print("✗ 缺失：")
    for r in missing:
        print("    %s" % r)
if extra:
    print("! 清单外的多余文件：")
    for r in extra:
        print("    %s" % r)

if not (changed or missing or extra):
    print("✓ skills/ 与构建清单完全一致，未被手工改动。")
elif changed or missing:
    print()
    print("→ 若这些改动是有意为之，请改事实源 Bundle 后重编译，不要手改 skills/。")
    sys.exit(1)
PY
