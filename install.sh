#!/usr/bin/env bash
#
# nocobase-skills — 安装 / 卸载
#
# 把 skills/ 下的 8 个 Skill 装到 WorkBuddy（或任意 Skills 目录）。
# 兼容 macOS 自带 bash 3.2 与 Linux bash。
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/skills"

ACTION="install"
TARGET="${WORKBUDDY_SKILLS_DIR:-$HOME/.workbuddy/skills}"
FORCE=0
DRY=0

if [ -t 1 ]; then
  C_RST=$(printf '\033[0m'); C_DIM=$(printf '\033[2m')
  C_OK=$(printf '\033[32m'); C_WARN=$(printf '\033[33m'); C_ERR=$(printf '\033[31m')
else
  C_RST=''; C_DIM=''; C_OK=''; C_WARN=''; C_ERR=''
fi

info() { printf '%s\n' "$*"; }
dim()  { printf '%s%s%s\n' "$C_DIM" "$*" "$C_RST"; }
ok()   { printf '%s✓%s %s\n' "$C_OK" "$C_RST" "$*"; }
warn() { printf '%s!%s %s\n' "$C_WARN" "$C_RST" "$*"; }
die()  { printf '%s✗%s %s\n' "$C_ERR" "$C_RST" "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
nocobase-skills 安装器

用法:
  ./install.sh [选项]

选项:
  -t, --target DIR   安装目标目录（默认 $HOME/.workbuddy/skills）
  -f, --force        覆盖已存在的同名 Skill（覆盖前自动备份为 <name>.bak-<时间戳>）
  -n, --dry-run      只打印将要做什么，不落盘
      --uninstall    卸载本仓库的 8 个 Skill（不动目标目录里的其它 Skill）
  -l, --list         列出本仓库包含的 Skill
  -h, --help         显示本帮助

环境变量:
  WORKBUDDY_SKILLS_DIR   等价于 --target

示例:
  ./install.sh                        # 安装到 ~/.workbuddy/skills
  ./install.sh --dry-run              # 先预演
  ./install.sh --force                # 覆盖已装版本（先备份）
  ./install.sh -t /tmp/skills-test    # 装到临时目录做验证
  ./install.sh --uninstall            # 卸载
EOF
}

# 列出仓库内的 Skill（含 SKILL.md 的一级子目录）。名字为无空格 slug。
list_skills() {
  for d in "$SRC"/*/; do
    [ -d "$d" ] || continue
    [ -f "${d}SKILL.md" ] || continue
    basename "$d"
  done
}

[ -d "$SRC" ] || die "找不到 skills 目录：$SRC"

while [ $# -gt 0 ]; do
  case "$1" in
    -t|--target)
      [ $# -ge 2 ] || die "--target 需要一个目录参数"
      TARGET="$2"; shift 2 ;;
    -f|--force)   FORCE=1; shift ;;
    -n|--dry-run) DRY=1; shift ;;
    --uninstall)  ACTION="uninstall"; shift ;;
    -l|--list)    ACTION="list"; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            die "未知参数：$1（用 --help 看用法）" ;;
  esac
done

NAMES="$(list_skills)"
[ -n "$NAMES" ] || die "skills/ 下没有找到任何含 SKILL.md 的目录"

if [ "$ACTION" = "list" ]; then
  info "本仓库包含以下 Skill（源：${SRC}）"
  for n in $NAMES; do
    printf '  - %s\n' "$n"
  done
  exit 0
fi

if [ "$ACTION" = "uninstall" ]; then
  [ -d "$TARGET" ] || die "目标目录不存在：$TARGET"
  info "从 $TARGET 卸载本仓库的 Skill"
  [ "$DRY" -eq 1 ] && dim "  （dry-run，不落盘）"
  gone=0; miss=0
  for n in $NAMES; do
    dest="$TARGET/$n"
    if [ -e "$dest" ]; then
      if [ "$DRY" -eq 1 ]; then
        dim "  将删除 $dest"
      else
        rm -rf "$dest"
        ok "已卸载 $n"
      fi
      gone=$((gone + 1))
    else
      warn "$n 未安装，跳过"
      miss=$((miss + 1))
    fi
  done
  info ""
  info "完成：卸载 $gone 个，未找到 $miss 个。"
  exit 0
fi

# ---------- 安装 ----------
info "源目录   $SRC"
info "目标目录 $TARGET"
[ "$DRY" -eq 1 ] && dim "（dry-run，不落盘）"
info ""

[ "$DRY" -eq 1 ] || mkdir -p "$TARGET"

n_new=0; n_over=0; n_skip=0

for n in $NAMES; do
  src="$SRC/$n"
  dest="$TARGET/$n"
  existed=0

  if [ -e "$dest" ]; then
    existed=1
    if [ "$FORCE" -eq 0 ]; then
      warn "跳过 ${n}：目标已存在（用 --force 覆盖，覆盖前会先备份）"
      n_skip=$((n_skip + 1))
      continue
    fi
    bak="$dest.bak-$(date +%Y%m%d-%H%M%S)"
    if [ "$DRY" -eq 1 ]; then
      dim "  备份 $dest → $(basename "$bak")"
    else
      cp -R "$dest" "$bak"
      rm -rf "$dest"
      ok "已备份原版本 → $(basename "$bak")"
    fi
    n_over=$((n_over + 1))
  else
    n_new=$((n_new + 1))
  fi

  if [ "$DRY" -eq 1 ]; then
    dim "  复制 $n"
    continue
  fi

  cp -R "$src" "$dest"
  [ -f "$dest/SKILL.md" ] || die "安装后缺少 SKILL.md：$dest/SKILL.md"
  ok "已安装 $n"
done

# ---------- 安装后校验 ----------
if [ "$DRY" -eq 0 ]; then
  info ""
  info "校验 frontmatter name 与目录名是否一致："
  bad=0
  for n in $NAMES; do
    f="$TARGET/$n/SKILL.md"
    if [ ! -f "$f" ]; then
      warn "  $n 未就位"
      bad=$((bad + 1))
      continue
    fi
    got=$(sed -n '1,15p' "$f" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d '\r')
    if [ "$got" = "$n" ]; then
      ok "  $n"
    else
      warn "  $n 的 frontmatter name='$got'，与目录名不一致"
      bad=$((bad + 1))
    fi
  done
  info ""
  if [ "$bad" -eq 0 ]; then
    info "完成：新装 $n_new 个，覆盖 $n_over 个，跳过 $n_skip 个；校验全部通过。"
  else
    info "完成：新装 $n_new 个，覆盖 $n_over 个，跳过 $n_skip 个；校验有 $bad 处异常。"
  fi
  info "想复原 skills/ 请对照 BUILD_MANIFEST.json，或运行 ./verify.sh"
else
  info ""
  info "预演结束：将新装 $n_new 个，覆盖 $n_over 个，跳过 $n_skip 个。去掉 --dry-run 即执行。"
fi
