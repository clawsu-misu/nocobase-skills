#!/usr/bin/env bash
#
# nocobase-skills — 官方 nocobase/skills 查找 + 校验 + 软链
#
# 为什么多这一步「查找」？
#   官方技能的真实落点随安装方式而变（nb skills install / npm / 手动克隆），
#   而且 ~/.claude/skills 下往往只是指向 ~/.agents/skills 的相对软链。
#   路径写死，目标一挪就成坏链 —— 结果就是「装上了但运行不了」。
#   所以本脚本坚持：先查找、再校验、最后才软链。
#
# 兼容 macOS 自带 bash 3.2 与 Linux bash。
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${WORKBUDDY_SKILLS_DIR:-$HOME/.workbuddy/skills}"
ACTION="link"
MODE="symlink"
DRY=0
FORCE=0
CHECK_UPSTREAM=0
EXPLICIT_SRC="${NOCOBASE_SKILLS_SRC:-}"

if [ -t 1 ]; then
  C_RST=$(printf '\033[0m');  C_DIM=$(printf '\033[2m')
  C_OK=$(printf '\033[32m');  C_WARN=$(printf '\033[33m');  C_ERR=$(printf '\033[31m')
  C_BOLD=$(printf '\033[1m')
else
  C_RST=''; C_DIM=''; C_OK=''; C_WARN=''; C_ERR=''; C_BOLD=''
fi

info() { printf '%s\n' "$*"; }
dim()  { printf '%s%s%s\n' "$C_DIM" "$*" "$C_RST"; }
head_() { printf '\n%s%s%s\n' "$C_BOLD" "$*" "$C_RST"; }
ok()   { printf '%s✓%s %s\n' "$C_OK" "$C_RST" "$*"; }
warn() { printf '%s!%s %s\n' "$C_WARN" "$C_RST" "$*"; }
die()  { printf '%s✗%s %s\n' "$C_ERR" "$C_RST" "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
nocobase-skills — 官方 Skills 查找 + 软链

用法:
  ./link-official.sh [选项]

选项:
  --src DIR          直接指定官方技能真身目录（跳过自动查找）
  -t, --target DIR   装到哪个目录（默认 $HOME/.workbuddy/skills）
  -m, --mode MODE    安装方式：symlink（默认，已实测 WorkBuddy 可识别）| copy
  -l, --list         只查找 + 校验，列出结果，不落盘
  -n, --dry-run      预演：完整查找与校验，但不落盘
  --check-upstream   额外从 npm 拉 @nocobase/skills 官方包做内容指纹核对，
                     报告真身中哪些技能已被本地改动（需联网）
  --unlink           卸载本脚本装过的条目（只删软链，绝不碰真身目录）
  -f, --force        覆盖同名条目（同名真实目录一律拒绝覆盖）
  -h, --help         显示本帮助

环境变量:
  NOCOBASE_SKILLS_SRC    等价于 --src
  WORKBUDDY_SKILLS_DIR   等价于 --target

查找顺序（命中即停；同一真身会被去重）:
  1. --src / $NOCOBASE_SKILLS_SRC   显式指定
  2. ~/.agents/skills               nb skills install 的全局落点（通常为真身）
  3. ~/.claude/skills               常见为指向 .agents 的相对软链
  4. ~/.codex/skills
  5. ~/.nocobase/cache/skills/node_modules/@nocobase/skills/skills
  6. ./node_modules/@nocobase/skills/skills
  7. ~/node_modules/@nocobase/skills/skills

示例:
  ./link-official.sh --list              # 先看能不能找到、校验过不过
  ./link-official.sh --dry-run           # 预演
  ./link-official.sh                     # 执行软链
  ./link-official.sh --check-upstream    # 顺带核对内容是否被本地改过
  ./link-official.sh --unlink            # 撤销
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --src)      [ $# -ge 2 ] || die "--src 需要一个目录参数"; EXPLICIT_SRC="$2"; shift 2 ;;
    -t|--target) [ $# -ge 2 ] || die "--target 需要一个目录参数"; TARGET="$2"; shift 2 ;;
    -m|--mode)  [ $# -ge 2 ] || die "--mode 需要 symlink 或 copy"; MODE="$2"; shift 2 ;;
    -l|--list)  ACTION="list"; shift ;;
    -n|--dry-run) DRY=1; shift ;;
    --check-upstream) CHECK_UPSTREAM=1; shift ;;
    --unlink)   ACTION="unlink"; shift ;;
    -f|--force) FORCE=1; shift ;;
    -h|--help)  usage; exit 0 ;;
    *)          die "未知参数：$1（用 --help 看用法）" ;;
  esac
done

case "$MODE" in
  symlink|copy) ;;
  *) die "--mode 只支持 symlink 或 copy（收到：$MODE）" ;;
esac

# ---------------------------------------------------------------- 工具函数

# 物理绝对路径（解引用软链）。失败返回空。
real_of() { ( cd "$1" 2>/dev/null && pwd -P ) || true; }

# 文件指纹（macOS 用 md5，Linux 用 md5sum）
md5_of() {
  if [ ! -f "$1" ]; then return 1; fi
  if command -v md5 >/dev/null 2>&1; then md5 -q "$1"
  else md5sum "$1" | awk '{print $1}'
  fi
}

# 数一个目录下「像官方技能」的子目录：nocobase-* 且含 SKILL.md
count_skills() {
  _c=0
  if [ -d "$1" ]; then
    for _d in "$1"/nocobase-*/; do
      [ -d "$_d" ] || continue
      [ -f "${_d}SKILL.md" ] || continue
      _c=$((_c + 1))
    done
  fi
  printf '%s' "$_c"
}

# 真身指纹：取一个基准子项的物理路径，返回其父目录。
# 这样 ~/.claude/skills 这种「目录本身是真目录、只有子项是软链」的布局，
# 也能被认出与 ~/.agents/skills 是同一真身。
sig_dir() {
  for _s in "$1"/nocobase-*/; do
    [ -d "$_s" ] || continue
    _p="$(real_of "$_s")"
    if [ -n "$_p" ]; then dirname "$_p"; return; fi
  done
}

# 列出合格技能名（一行一个）
list_skills_at() {
  for _d in "$1"/nocobase-*/; do
    [ -d "$_d" ] || continue
    [ -f "${_d}SKILL.md" ] || continue
    basename "$_d"
  done
}

# 读 frontmatter 某键（只扫前 20 行）
fm_get() {
  sed -n '1,20p' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1 | tr -d '\r' | sed 's/^"//; s/"$//'
}

# ---------------------------------------------------------------- 阶段 1 查找

head_ "阶段 1/4 · 查找官方技能真身"

CANDIDATES=""
if [ -n "$EXPLICIT_SRC" ]; then
  CANDIDATES="$EXPLICIT_SRC
$HOME/.agents/skills
$HOME/.claude/skills
$HOME/.codex/skills
$HOME/.nocobase/cache/skills/node_modules/@nocobase/skills/skills
node_modules/@nocobase/skills/skills
$HOME/node_modules/@nocobase/skills/skills"
else
  CANDIDATES="$HOME/.agents/skills
$HOME/.claude/skills
$HOME/.codex/skills
$HOME/.nocobase/cache/skills/node_modules/@nocobase/skills/skills
node_modules/@nocobase/skills/skills
$HOME/node_modules/@nocobase/skills/skills"
fi

SEEN_REAL=""
BEST_REAL=""
BEST_COUNT=0
HITS=0

for cand in $CANDIDATES; do
  if [ ! -e "$cand" ]; then
    dim "  · $cand  — 不存在"
    continue
  fi
  n="$(count_skills "$cand")"
  if [ "$n" -eq 0 ]; then
    dim "  · $cand  — 存在，但无 nocobase-* / SKILL.md"
    continue
  fi
  # 用子项物理路径做指纹，识别「同一真身的不同入口」
  sig="$(sig_dir "$cand")"
  [ -n "$sig" ] || sig="$(real_of "$cand")"
  tag=""
  case "$SEEN_REAL" in
    *"|$sig|"*) tag="  ←同一真身，不计" ;;
    *) SEEN_REAL="$SEEN_REAL|$sig|"; HITS=$((HITS + 1)) ;;
  esac
  ok "  · $cand  — ${n} 个技能，真身 ${sig}${tag}"
  if [ "$n" -gt "$BEST_COUNT" ]; then
    BEST_COUNT="$n"
    BEST_REAL="$sig"
  fi
done

if [ "$BEST_COUNT" -eq 0 ]; then
  head_ "查找失败"
  die "所有候选位置都没有找到 nocobase-* 技能。
   先安装官方技能：nb skills install -y
   或显式指定真身：./link-official.sh --src /path/to/skills
   装完可以用 nb skills check 确认（注意：该命令偶发超时，超时不代表没装）。"
fi

info ""
info "选定真身：${C_BOLD}${BEST_REAL}${C_RST}（${BEST_COUNT} 个技能）"

SRC="$BEST_REAL"
SKILL_NAMES="$(list_skills_at "$SRC")"
[ -n "$SKILL_NAMES" ] || die "选定目录里没有合格技能：$SRC"

# ---------------------------------------------------------------- 阶段 2 校验

head_ "阶段 2/4 · 校验真身完整性"

bad=0
for n in $SKILL_NAMES; do
  f="$SRC/$n/SKILL.md"
  if [ ! -f "$f" ]; then warn "  $n 缺 SKILL.md"; bad=$((bad + 1)); continue; fi
  nm="$(fm_get "$f" name)"
  ds="$(fm_get "$f" description)"
  if [ -z "$nm" ]; then warn "  $n 的 frontmatter 缺 name"; bad=$((bad + 1)); continue; fi
  if [ "$nm" != "$n" ]; then warn "  $n 的 name='$nm' 与目录名不一致"; bad=$((bad + 1)); continue; fi
  if [ -z "$ds" ]; then warn "  $n 缺 description（WorkBuddy 靠它做触发判定）"; bad=$((bad + 1)); continue; fi
done

if [ "$bad" -eq 0 ]; then
  ok "  ${BEST_COUNT} 个技能全部通过（目录名 / name / description 齐备）"
else
  warn "  有 ${bad} 处异常，见上"
fi

# 坏链自检：真身里若混有断链子目录，明确报出来
broken=0
for n in $SKILL_NAMES; do
  if [ -L "$SRC/$n" ] && [ ! -e "$SRC/$n" ]; then
    warn "  $n 是坏链"
    broken=$((broken + 1))
  fi
done
[ "$broken" -eq 0 ] && dim "  无坏链"

# ---------------------------------------------------------------- 版本交叉核对

head_ "阶段 2b · 版本交叉核对（只提示，不阻断）"

inst_ver=""
if [ -f "$HOME/.nocobase/skills.json" ]; then
  inst_ver="$(sed -n 's/.*"installedVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$HOME/.nocobase/skills.json" | head -1)"
fi
[ -n "$inst_ver" ] && info "  技能包版本   : @nocobase/skills ${inst_ver}" || dim "  技能包版本   : 未读到 ~/.nocobase/skills.json"

decl=""
for n in $SKILL_NAMES; do
  # 取 description 里第一个出现的「NocoBase <数字>」。
  # 不能用 sed 's/.*NocoBase \([0-9]\).*/\1/' —— .* 贪婪会一路吃到
  # "never use in a NocoBase 3 project" 里的 3，方向就反了。
  v="$(sed -n '1,10p' "$SRC/$n/SKILL.md" | grep -o -E 'NocoBase [0-9]' | head -1 | grep -o '[0-9]' || true)"
  [ -n "$v" ] && { decl="$v"; break; }
done
[ -n "$decl" ] && info "  技能声明适用 : NocoBase ${decl}" || dim "  技能声明适用 : 未在 description 中发现代次声明"

env_line=""
if command -v nb >/dev/null 2>&1 || [ -x /opt/homebrew/bin/nb ]; then
  NB_BIN="$(command -v nb 2>/dev/null || echo /opt/homebrew/bin/nb)"
  if command -v perl >/dev/null 2>&1; then
    env_line="$(perl -e 'alarm shift; exec @ARGV' 10 "$NB_BIN" env list 2>/dev/null | awk '/^\*/{print; exit}' || true)"
  else
    env_line="$("$NB_BIN" env list 2>/dev/null | awk '/^\*/{print; exit}' || true)"
  fi
fi
cur_ver=""
if [ -n "$env_line" ]; then
  cur_ver="$(printf '%s' "$env_line" | awk '{print $NF}')"
  cur_name="$(printf '%s' "$env_line" | awk '{print $2}')"
  info "  当前环境     : ${cur_name} = NocoBase ${cur_ver}"
else
  dim "  当前环境     : 未取到（nb env list 超时或未配置环境，不影响软链）"
fi

if [ -n "$decl" ] && [ -n "$cur_ver" ]; then
  cur_major="$(printf '%s' "$cur_ver" | sed -n 's/^\([0-9]*\).*/\1/p')"
  if [ "$cur_major" = "$decl" ]; then
    ok "  代次匹配：技能声明 NocoBase ${decl}，当前环境 ${cur_ver}"
  else
    warn "  代次不匹配：技能声明 NocoBase ${decl}，当前环境 ${cur_ver}"
    warn "            这批技能在 description 里官方自述仅适用于 NocoBase ${decl}，"
    warn "            切环境（nb env use）时请对照，必要时先 --unlink。"
  fi
fi

info ""
dim "  注：官方 ${BEST_COUNT} 个技能均在 description 里写明版本适用范围，切环境（nb env use）前请对照。"

if [ "$CHECK_UPSTREAM" -eq 1 ]; then
  head_ "阶段 2c · 上游内容核对（--check-upstream）"
  ver="$inst_ver"
  if [ -z "$ver" ]; then
    ver="$(curl -s --max-time 20 https://registry.npmjs.org/@nocobase/skills 2>/dev/null \
           | sed -n 's/.*"latest":"\([^"]*\)".*/\1/p' | head -1)"
  fi
  if [ -z "$ver" ]; then
    warn "  拿不到上游版本号（无网络？），跳过核对"
  elif ! command -v tar >/dev/null 2>&1; then
    warn "  没有 tar，跳过核对"
  else
    tmp="$(mktemp -d 2>/dev/null || echo /tmp/nbup.$$)"
    mkdir -p "$tmp"
    url="https://registry.npmjs.org/@nocobase/skills/-/skills-${ver}.tgz"
    info "  上游版本：${ver}"
    if curl -sL --max-time 150 "$url" -o "$tmp/pkg.tgz" 2>/dev/null \
       && tar xzf "$tmp/pkg.tgz" -C "$tmp" 2>/dev/null; then
      ref="$tmp/package/skills"
      if [ ! -d "$ref" ]; then
        warn "  上游包结构异常（无 skills/），跳过核对"
      else
        same=0; away=0; AWAY=""
        for n in $SKILL_NAMES; do
          a="$(md5_of "$SRC/$n/SKILL.md" 2>/dev/null)"
          b="$(md5_of "$ref/$n/SKILL.md" 2>/dev/null)"
          if [ -z "$b" ]; then
            away=$((away + 1)); AWAY="${AWAY}    · ${n}（上游无此技能）\n"
          elif [ "$a" = "$b" ]; then
            same=$((same + 1))
          else
            away=$((away + 1)); AWAY="${AWAY}    · ${n}（内容已偏离官方）\n"
          fi
        done
        if [ "$away" -eq 0 ]; then
          ok "  ${same}/${BEST_COUNT} 与官方 ${ver} 逐字节一致"
        else
          warn "  ${same}/${BEST_COUNT} 与官方一致，${away} 个已偏离："
          printf "%b" "$AWAY"
          dim "  偏离多为 nb 的技能自学习/本地修订；若你要的是官方原味，"
          dim "  可改用 --src 指向 npm 解包目录，或先跑 nb skills update。"
        fi
      fi
    else
      warn "  下载或解包失败，跳过核对"
    fi
    rm -rf "$tmp" 2>/dev/null || true
  fi
fi

if [ "$ACTION" = "list" ]; then
  head_ "只查不装（--list）"
  info "共 ${BEST_COUNT} 个技能可安装："
  for n in $SKILL_NAMES; do printf '  - %s\n' "$n"; done
  info ""
  info "去掉 --list 即执行（默认 --mode symlink）。"
  exit 0
fi

# ---------------------------------------------------------------- 卸载分支

if [ "$ACTION" = "unlink" ]; then
  head_ "卸载官方技能"
  [ -d "$TARGET" ] || die "目标目录不存在：$TARGET"
  info "目标目录：$TARGET"
  [ "$DRY" -eq 1 ] && dim "  （dry-run，不落盘）"
  gone=0; kept=0; nomatch=0
  for n in $SKILL_NAMES; do
    dest="$TARGET/$n"
    if [ -L "$dest" ]; then
      # 只删指向本次真身的软链，避免误伤链到别处的技能
      cur="$(real_of "$dest")"
      if [ "$cur" != "$SRC/$n" ]; then
        warn "  ~ ${n} 指向 ${cur:-（坏链）}，非本次真身，保留不动"; kept=$((kept + 1)); continue
      fi
      if [ "$DRY" -eq 1 ]; then dim "  将删除软链 ${dest}"
      else rm -f "$dest"; ok "  - ${n}"; fi
      gone=$((gone + 1))
    elif [ -d "$dest" ]; then
      # 副本模式卸载：只删「与真身逐字节一致」的副本。
      # 内容被改过的目录一律保留 —— 那可能是用户自己的东西。
      if [ "$(md5_of "$dest/SKILL.md" 2>/dev/null)" = "$(md5_of "$SRC/$n/SKILL.md" 2>/dev/null)" ]; then
        if [ "$DRY" -eq 1 ]; then dim "  将删除副本 ${dest}"
        else rm -rf "$dest"; ok "  - ${n}（副本）"; fi
        gone=$((gone + 1))
      else
        warn "  ~ ${n} 副本内容与真身不同，保留不动（可能是本地改动）"; kept=$((kept + 1))
      fi
    else
      nomatch=$((nomatch + 1))
    fi
  done
  info ""
  info "完成：移除 ${gone} 个，保留 ${kept} 个，不存在 ${nomatch} 个。真身目录未做任何改动。"
  exit 0
fi

# ---------------------------------------------------------------- 阶段 3 冲突检查

head_ "阶段 3/4 · 目标目录冲突检查"

[ "$DRY" -eq 1 ] || mkdir -p "$TARGET"
info "目标目录：$TARGET"

n_new=0; n_dup=0; n_conf=0
CONFLICT_LIST=""
for n in $SKILL_NAMES; do
  dest="$TARGET/$n"
  [ -e "$dest" ] || [ -L "$dest" ] || { n_new=$((n_new + 1)); continue; }
  if [ -L "$dest" ]; then
    cur="$(real_of "$dest")"
    if [ "$cur" = "$SRC/$n" ]; then
      n_dup=$((n_dup + 1))
    else
      n_conf=$((n_conf + 1)); CONFLICT_LIST="$CONFLICT_LIST $n"
    fi
  else
    n_conf=$((n_conf + 1)); CONFLICT_LIST="$CONFLICT_LIST $n"
  fi
done
info "  待新建 ${n_new} · 已正确软链 ${n_dup} · 冲突 ${n_conf}"
if [ "$n_conf" -gt 0 ]; then
  for n in $CONFLICT_LIST; do
    if [ -L "$TARGET/$n" ]; then
      warn "  ${n} 已是软链但指向别处：$(real_of "$TARGET/$n" 2>/dev/null || echo '(坏链)')"
    else
      warn "  ${n} 是真实目录（本地技能），不会被覆盖"
    fi
  done
fi

# ---------------------------------------------------------------- 阶段 4 软链

head_ "阶段 4/4 · 落盘（模式：${MODE}）"

[ "$DRY" -eq 1 ] && dim "  （dry-run，不落盘）"
[ "$MODE" = "symlink" ] && info "  软链用绝对路径，真身移动/删除时会立刻暴露为坏链，不会静默失效"

made=0; skipped=0; failed=0
for n in $SKILL_NAMES; do
  dest="$TARGET/$n"
  exists=0
  if [ -e "$dest" ] || [ -L "$dest" ]; then exists=1; fi

  if [ "$exists" -eq 1 ]; then
    # 幂等：已经是正确形态，直接跳过
    if [ "$MODE" = "symlink" ] && [ -L "$dest" ] && [ "$(real_of "$dest")" = "$SRC/$n" ]; then
      dim "  = ${n}（已是正确软链，跳过）"; skipped=$((skipped + 1)); continue
    fi
    if [ "$MODE" = "copy" ] && [ -d "$dest" ] && [ ! -L "$dest" ] \
       && [ "$(md5_of "$dest/SKILL.md" 2>/dev/null)" = "$(md5_of "$SRC/$n/SKILL.md" 2>/dev/null)" ]; then
      dim "  = ${n}（副本与真身一致，跳过）"; skipped=$((skipped + 1)); continue
    fi
    # 冲突处理
    if [ -d "$dest" ] && [ ! -L "$dest" ]; then
      warn "  ! ${n} 是真实目录（可能是本地技能），拒绝覆盖"; skipped=$((skipped + 1)); continue
    fi
    if [ "$FORCE" -eq 0 ]; then
      warn "  ! ${n} 已存在且非本脚本所建，跳过（--force 可强制替换）"
      skipped=$((skipped + 1)); continue
    fi
    if [ "$DRY" -eq 1 ]; then
      dim "  ~ 将替换既有 ${n}"
    else
      rm -f "$dest"
    fi
  fi

  if [ "$DRY" -eq 1 ]; then
    if [ "$MODE" = "symlink" ]; then
      dim "  + ln -s $SRC/$n  →  $dest"
    else
      dim "  + cp -R $SRC/$n  →  $dest"
    fi
    made=$((made + 1)); continue
  fi

  if [ "$MODE" = "symlink" ]; then
    ln -s "$SRC/$n" "$dest"
  else
    cp -R "$SRC/$n" "$dest"
  fi

  # 落盘后复验：这是整套「先查找再安装」的最后一道闸
  if [ -r "$dest/SKILL.md" ] && [ "$(fm_get "$dest/SKILL.md" name)" = "$n" ]; then
    ok "  + ${n}"
    made=$((made + 1))
  else
    warn "  ✗ ${n} 落盘后复验失败，已回滚"
    [ "$MODE" = "symlink" ] && [ -L "$dest" ] && rm -f "$dest"
    [ "$MODE" = "copy" ] && [ -d "$dest" ] && rm -rf "$dest"
    failed=$((failed + 1))
  fi
done

# ---------------------------------------------------------------- 收尾

head_ "完成"
info "模式 ${MODE} · 新建 ${made} · 跳过 ${skipped} · 失败 ${failed}（冲突提示 ${n_conf}）"
if [ "$DRY" -eq 1 ]; then
  info "预演结束。去掉 --dry-run 即执行。"
else
  info "撤销：./link-official.sh --unlink"
  info "真身：${SRC}"
fi
[ "$failed" -eq 0 ] || exit 1
