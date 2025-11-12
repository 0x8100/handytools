#!/usr/bin/env bash
set -eu

#  wait-a-line.sh
#  --------------
#  
# 標準入力（または指定されたファイル）の追記を監視し、指定された正規表現にマッチする行を待機します。
# マッチする行が追記された場合、それを `[ OK ]` と共に表示して終了します。
# 「ログが流れているか」という（ありがちな）確認作業に利用することができます。
# 
# The latest code and license terms are available at:
#   https://github.com/0x8100/handytools


# ANSI Escape Sequence 色指定
GRAY='\033[90m'
BLUE='\033[94m'
RESET='\033[0m'

# 初期化
FILE=""
REGEX=""

function usage {
  echo "Usage: $0 [-f FILE] <regex>"
  echo "  -f FILE   Specify a file to monitor for new lines"
  echo ""
  echo 'This script listens for standard input (or file) and waits for a line that matches <regex>. If it matches, prints that line and exits.'
}

# コマンドライン引数解析
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -f)
      FILE="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
    *)
      REGEX="$1"
      shift
      ;;
  esac
done

if [[ -z "$REGEX" ]]; then
  usage > /dev/stderr
  exit 1
fi

if [[ -n "$FILE" && ! -f "$FILE" ]]; then
  echo "Error: File '$FILE' does not exist." > /dev/stderr
  exit 1
fi

# [wait] をグレーで表示
echo -e "${GRAY}[wait]${RESET} waiting for a line that matches '$REGEX'..."

# 標準入力 or ファイルの末尾を監視
if [[ -n "$FILE" ]]; then
  tail -n0 -F "$FILE" 2> /dev/null | while IFS= read -r LINE; do
    if [[ "$LINE" =~ $REGEX ]]; then
      # マッチした場合、[wait] を消して [OK] を青で表示
      echo -en "\033[1A\033[2K" # カーソルを1行上に戻し、その行をクリア
      echo -e "${BLUE}[ OK ]${RESET} $LINE"
      exit 0
    fi
  done
else
  while IFS= read -r LINE; do
    if [[ "$LINE" =~ $REGEX ]]; then
      # マッチした場合、[wait] を消して [OK] を青で表示
      echo -en "\033[1A\033[2K" # カーソルを1行上に戻し、その行をクリア
      echo -e "${BLUE}[ OK ]${RESET} $LINE"
      exit 0
    fi
  done
fi
