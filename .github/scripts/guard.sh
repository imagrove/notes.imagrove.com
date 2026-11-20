#!/usr/bin/env bash
# 敏感信息扫描：CI 与本地跑的是同一份逻辑。
#
# 用法：
#   bash .github/scripts/guard.sh
#   GUARD_KEYWORDS="客户A,客户B" bash .github/scripts/guard.sh
#
# 只扫会被公开发布的内容（content/posts 下的 .md），
# 不扫 README / 模板 / 本脚本——它们必然含有规则示例。

set -uo pipefail

SCAN_DIR="${SCAN_DIR:-content/posts}"
HITS=0

if [ ! -d "$SCAN_DIR" ]; then
  echo "::error::$SCAN_DIR 不存在"
  exit 1
fi

# scan <说明> <正则> [排除正则]
scan() {
  local label="$1"
  local pattern="$2"
  local exclude="${3:-}"
  local out=""

  out=$(grep -rnE --include='*.md' -- "$pattern" "$SCAN_DIR" 2>/dev/null || true)

  # 行内豁免：guard-allow
  if [ -n "$out" ]; then
    out=$(printf '%s\n' "$out" | grep -v 'guard-allow' || true)
  fi

  # 占位符豁免（所有规则通用）：= <你的token>  /  = ***  /  = xxx
  if [ -n "$out" ]; then
    out=$(printf '%s\n' "$out" | grep -vE '[:=][[:space:]]*(<|\*\*\*|xxx|XXX)' || true)
  fi

  if [ -n "$out" ] && [ -n "$exclude" ]; then
    out=$(printf '%s\n' "$out" | grep -vE "$exclude" || true)
  fi

  if [ -n "$out" ]; then
    echo ""
    echo "❌ $label"
    printf '%s\n' "$out" | head -n 20
    HITS=$((HITS + $(printf '%s\n' "$out" | wc -l)))
  fi
}

echo "扫描目录：$SCAN_DIR"

# ── 1. 邮箱：排除公开域名与占位符
scan "邮箱地址" \
     '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
     '@(example\.(com|org)|imagrove\.com|github\.com|users\.noreply)'

# ── 2. 中国大陆手机号
scan "中国大陆手机号" \
     '(^|[^0-9])1[3-9][0-9]{9}([^0-9]|$)'

# ── 3. 国际电话号码
scan "国际电话号码" \
     '(^|[^0-9+])\+[1-9][0-9]{7,14}([^0-9]|$)'

# ── 4. 内网 / 私有网段
scan "内网 IP 地址" \
     '(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3})'

# ── 5. 凭据类赋值写法
scan "凭据关键词（password / token / secret / api_key）" \
     '(password|passwd|pwd|token|secret|api[_-]?key|access[_-]?key|app[_-]?secret)[[:space:]]*[:=]'

# ── 6. 私钥内容
scan "私钥内容" \
     'BEGIN (RSA |EC |OPENSSH |PGP |DSA )?PRIVATE KEY'

# ── 7. 客户名 / 项目代号词库（来自 Secrets 或本地环境变量）
# 词库走字面量匹配（-F）且忽略大小写（-i），不进 scan()：
# 客户名里的 . ( ) + & 若当正则解释会乱命中，而人名大小写混着写很常见。
if [ -n "${GUARD_KEYWORDS:-}" ]; then
  WORDS=$(printf '%s' "$GUARD_KEYWORDS" | sed 's/，/,/g')
  IFS=',' read -ra ARR <<< "$WORDS"
  for w in "${ARR[@]}"; do
    w=$(printf '%s' "$w" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    [ -z "$w" ] && continue
    out=$(grep -rniF --include='*.md' -- "$w" "$SCAN_DIR" 2>/dev/null | grep -v 'guard-allow' || true)
    if [ -n "$out" ]; then
      echo ""
      echo "❌ 客户/内部关键词（字面量）：$w"
      printf '%s\n' "$out" | head -n 20
      HITS=$((HITS + $(printf '%s\n' "$out" | wc -l)))
    fi
  done
else
  echo "::warning::GUARD_KEYWORDS 未配置，客户名库扫描已跳过"
fi

echo ""
echo "────────────────────────────────────────────"
if [ "$HITS" -gt 0 ]; then
  echo "::error::发现 $HITS 处疑似敏感信息。确属教学示例的，在该行末尾加 guard-allow 注释后重新提交。"
  exit 1
fi
echo "✅ 未发现敏感信息"
