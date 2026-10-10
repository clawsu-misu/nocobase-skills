#!/usr/bin/env bash
#
# nocobase-skills — 项目级安装（把技能从用户级搬进当前项目）
#
# 为什么要这一步：
#   WorkBuddy 有两层技能目录（代码级证据，见 README）——
#     用户级  ~/.workbuddy/skills/      所有项目都加载
#     项目级  {项目}/.workbuddy/skills/  只在 cwd = 该项目时加载
#
#   这 28 个技能全是 NocoBase 专用。装在用户级意味着在任何项目里、
#   每次对话都要为它们付一遍 token。搬进项目级后就只在 NocoBase
#   项目里加载。
#
# 兼容 macOS 自带 bash 3.2 与 Linux bash。
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC_USER="${WORKBUDDY_SKILLS_DIR:-$HOME/.workbuddy/skills}"
AGENTS_DIR="$HOME/.agents/skills"

ACTION="install"
# 默认项目根 = 当前工作目录。但若用户在仓库目录里直接跑本脚本，
# 项目根应是仓库的父目录（仓库本身不是那个项目）。
if [ "$PWD" = "$HERE" ]; then
  PROJECT="$(dirname "$HERE")"
else
  PROJECT="$PWD"
fi
DRY=0
FORCE=0

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
head_() { printf '\n%s\n' "$*"; }

usage() {
  cat <<'EOF'
nocobase-skills 项目级安装器

作用：把本包的技能从用户级 ~/.workbuddy/skills/ 搬进当前项目的
      {项目}/.workbuddy/skills/，只在打开该项目时加载。

用法:
  ./project-scope.sh [选项]

选项:
  -p, --project DIR  项目根目录（默认：当前工作目录）
  --install          用户级 → 项目级（默认动作）
  --uninstall        项目级 → 用户级（回滚）
  --status           只看两侧现状，不做任何改动
  -n, --dry-run      预演，不落盘
  -f, --force        目标已存在且不是本脚本搬运的条目时，也覆盖
  -h, --help         显示本帮助

示例:
  cd ~/flowus/nocobase
  ./project-scope.sh --status      # 先看现状
  ./project-scope.sh --dry-run     # 预演
  ./project-scope.sh               # 执行
  ./project-scope.sh --uninstall   # 回滚回用户级
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -p|--project) [ $# -ge 2 ] || die "--project 需要一个目录参数"; PROJECT="$2"; shift 2 ;;
    --install)    ACTION="install"; shift ;;
    --uninstall)  ACTION="uninstall"; shift ;;
    --status)     ACTION="status"; shift ;;
    -n|--dry-run) DRY=1; shift ;;
    -f|--force)   FORCE=1; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            die "未知参数：$1（用 --help 看用法）" ;;
  esac
done

[ -d "$PROJECT" ] || die "项目目录不存在：$PROJECT"
PROJECT="$(cd "$PROJECT" && pwd -P)"
DST="$PROJECT/.workbuddy/skills"

# 技能清单 = 仓库内置的 8 个 + 所有 nocobase-* （官方 20 个）
# 三个来源取并集，因此在搬运前后都能算出同一份清单。
collect_names() {
  {
    if [ -d "$HERE/skills" ]; then
      find "$HERE/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sed 's|.*/||'
    fi
    for base in "$SRC_USER" "$DST" "$AGENTS_DIR"; do
      [ -d "$base" ] || continue
      find "$base" -mindepth 1 -maxdepth 1 -name 'nocobase-*' 2>/dev/null | sed 's|.*/||'
    done
  } | sort -u
}

NAMES="$(collect_names)"
[ -n "$NAMES" ] || die "没有找到任何 nocobase 技能，检查仓库是否完整"

count() { printf '%s\n' "$NAMES" | grep -c . || true; }
TOTAL="$(count)"

# ---------------------------------------------------------------- status
if [ "$ACTION" = "status" ]; then
  head_ "项目级安装现状"
  info "  项目根  : $PROJECT"
  info "  项目级  : $DST"
  info "  用户级  : $SRC_USER"
  info "  技能清单: $TOTAL 个"
  info ""
  u=0; p=0; other=0
  for n in $NAMES; do
    if   [ -e "$SRC_USER/$n" ]; then u=$((u + 1))
    elif [ -e "$DST/$n" ];      then p=$((p + 1))
    else                             other=$((other + 1))
    fi
  done
  info "  在用户级: $u"
  info "  在项目级: $p"
  [ "$other" -eq 0 ] || warn "  两侧都找不到: $other 个"
  info ""
  if [ "$p" -eq "$TOTAL" ]; then
    ok "全部 $TOTAL 个已在项目级"
  elif [ "$u" -eq "$TOTAL" ]; then
    dim "全部 $TOTAL 个仍在用户级（跑 ./project-scope.sh 搬过来）"
  else
    warn "两侧都有，处于中间状态（跑 ./project-scope.sh 补齐）"
  fi
  exit 0
fi

mkdir -p "$DST" 2>/dev/null || true
[ -d "$DST" ] || die "无法创建目标目录：$DST"

[ "$DRY" -eq 1 ] && head_ "预演（不落盘）"

moved=0; skipped=0; failed=0

if [ "$ACTION" = "install" ]; then
  head_ "阶段 · 用户级 → 项目级"
  FROM="$SRC_USER"; TO="$DST"
else
  head_ "阶段 · 项目级 → 用户级"
  FROM="$DST";      TO="$SRC_USER"
  mkdir -p "$TO" 2>/dev/null || true
  [ -d "$TO" ] || die "无法创建用户级目录：$TO"
fi

for n in $NAMES; do
  src="$FROM/$n"
  dst="$TO/$n"

  if [ ! -e "$src" ] && [ ! -L "$src" ]; then
    dim "  · ${n} —— 源侧不存在，跳过"
    skipped=$((skipped + 1))
    continue
  fi
  if [ ! -r "$src/SKILL.md" ]; then
    warn "  ! ${n} —— 源侧缺 SKILL.md，跳过"
    skipped=$((skipped + 1))
    continue
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$FORCE" -eq 0 ]; then
      dim "  = ${n} —— 目标已存在，跳过（--force 可覆盖）"
      skipped=$((skipped + 1))
      continue
    fi
    [ "$DRY" -eq 1 ] || rm -rf "$dst"
  fi

  if [ "$DRY" -eq 1 ]; then
    dim "  → mv $src  →  $dst"
    moved=$((moved + 1))
    continue
  fi

  if mv "$src" "$dst" 2>/dev/null && [ -r "$dst/SKILL.md" ]; then
    ok "  ${n}"
    moved=$((moved + 1))
  else
    warn "  ✗ ${n} —— 搬运失败"
    failed=$((failed + 1))
  fi
done

head_ "结果"
info "  搬运 ${moved} · 跳过 ${skipped} · 失败 ${failed}"

if [ "$failed" -ne 0 ]; then
  warn "有失败项，请先处理再继续"
  exit 1
fi

if [ "$DRY" -eq 1 ]; then
  info "  预演结束。去掉 --dry-run 即执行。"
  exit 0
fi

# ---------------------------------------------------------------- 复验
head_ "复验"
u=0; p=0
for n in $NAMES; do
  if   [ -e "$SRC_USER/$n" ]; then u=$((u + 1))
  elif [ -e "$DST/$n" ];      then p=$((p + 1))
  fi
done
info "  用户级剩 ${u} · 项目级有 ${p} / ${TOTAL}"

if [ "$ACTION" = "install" ] && [ "$p" -eq "$TOTAL" ]; then
  ok "已全部落到项目级：$DST"
  info ""
  dim "  生效时机：WorkBuddy 在【新建对话】时按 cwd 解析项目级技能目录。"
  dim "  当前这个对话是技能还挂在用户级时开的，看不到变化——新开一个对话即可。"
  dim "  回滚：./project-scope.sh --uninstall"
fi
