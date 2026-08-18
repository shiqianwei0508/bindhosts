#!/usr/bin/env bash
#
# build-module.sh - 本地打包 bindhosts 模块 zip（替代 GitHub Action release）
#
# 适用场景：GitHub 账号无 release 权限时，在本地/CI 手动构建并产出 zip。
# 复刻 .github/workflows/release.yml 中「build webroot + zip module」的逻辑。
#
# 用法：
#   bash build-module.sh            # 默认读 update.json 的 version 作为包名版本
#   ZIP_PREFIX=bindhosts-josepth bash build-module.sh
#
# 依赖：node(pnpm) + zip（Git Bash / WSL / macOS 自带 zip；Windows 可用 Git Bash）
#
set -euo pipefail

# ---- 路径 ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ---- 配置（与 release.yml 保持一致）----
MODULE_NAME='bindhosts'
ZIP_PREFIX="${ZIP_PREFIX:-bindhosts-josepth}"

# ---- 取版本号（来自 update.json 的 version 字段，如 v2.1.4）----
if ! command -v jq >/dev/null 2>&1; then
  # 无 jq 时用 grep/sed 兜底
  VERSION="$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' update.json | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/')"
else
  VERSION="$(jq -r .version update.json)"
fi

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  echo "[build] ERROR: 无法从 update.json 读取 version" >&2
  exit 1
fi

ZIP_NAME="${ZIP_PREFIX}-${VERSION}.zip"
echo "[build] 目标包名: $ZIP_NAME (version=$VERSION)"

# ---- 1. 构建 webroot ----
echo "[build] 步骤1: 构建 webui -> module/webroot"
cd webui
if command -v pnpm >/dev/null 2>&1; then
  pnpm install --frozen-lockfile
  pnpm build
else
  echo "[build] ERROR: 未找到 pnpm，请先安装 (npm i -g pnpm)" >&2
  exit 1
fi
cd "$SCRIPT_DIR"

# ---- 2. 打包整个 module/ 目录为 zip ----
echo "[build] 步骤2: 打包 module/ -> $ZIP_NAME"
rm -f "$ZIP_NAME"

cd module
MODULE_DIR="$(pwd)" python3 - "$SCRIPT_DIR/$ZIP_NAME" <<'PY'
import os, sys, zipfile
out = sys.argv[1]
root = os.environ['MODULE_DIR']
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for base, dirs, files in os.walk(root):
        for f in files:
            full = os.path.join(base, f)
            rel = os.path.relpath(full, root)
            if rel.startswith('.git') or '/.git' in rel:
                continue
            z.write(full, rel)
print('  zipped', len(z.namelist()), 'entries')
PY
cd "$SCRIPT_DIR"

echo "[build] 完成: $(pwd)/$ZIP_NAME"
ls -lh "$ZIP_NAME"
