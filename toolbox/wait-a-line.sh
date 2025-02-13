#!/usr/bin/env bash

set -eu

# ANSIエスケープシーケンスを使用して色を設定
GRAY='\033[90m'
BLUE='\033[94m'
RESET='\033[0m'

# 初期化
FILE=""
REGEX=""

# ヘルプメッセージ
function usage {
  echo "Usage: $0 [-f FILE] <regex>"
  echo "  -f FILE   Specify a file to monitor for new lines"
  echo ""
  echo 'This script listens for standard input and waits for a line that matches <regex>. If it matches, prints that line and exits.'
  exit 1
}

# コマンドライン引数を解析
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -f)
      FILE="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option: $1"
      usage
      ;;
    *)
      REGEX="$1"
      shift
      ;;
  esac
done

# 正規表現が指定されていない場合はエラー
if [[ -z "$REGEX" ]]; then
  usage
fi

# ファイルが指定されている場合、存在を確認する
if [[ -n "$FILE" && ! -f "$FILE" ]]; then
  echo "Error: File '$FILE' does not exist."
  exit 1
fi

# [wait] をグレーで表示
echo -e "${GRAY}[wait]${RESET} waiting for a line that matches '$REGEX'..."

# 標準入力またはファイルの監視
if [[ -n "$FILE" ]]; then
  # ファイルの末尾を監視
  tail -n0 -F "$FILE" 2> /dev/null | while IFS= read -r LINE; do
    if [[ "$LINE" =~ $REGEX ]]; then
      # マッチした場合、[wait] を消して [OK] を青で表示
      echo -en "\033[1A\033[2K" # カーソルを1行上に戻し、その行をクリア
      echo -e "${BLUE}[ OK ]${RESET} $LINE"
      exit 0
    fi
  done
else
  # 標準入力を監視
  while IFS= read -r LINE; do
    if [[ "$LINE" =~ $REGEX ]]; then
      # マッチした場合、[wait] を消して [OK] を青で表示
      echo -en "\033[1A\033[2K" # カーソルを1行上に戻し、その行をクリア
      echo -e "${BLUE}[ OK ]${RESET} $LINE"
      exit 0
    fi
  done
fi
