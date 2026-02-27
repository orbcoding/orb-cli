# Only use colors for interactive shells
if [[ -t 1 ]] && [[ "$ORB_SHELLSPEC" != true ]]; then
  ORB_BOLD=$'\033[1m'
  ORB_ITALIC=$'\033[3m'
  ORB_UNDERLINE=$'\033[4m'
  ORB_RED=$'\033[91m'
  ORB_GREEN=$'\033[32m'
  ORB_BLUE=$'\033[34m'
  ORB_WHITE=$'\033[37m'
  ORB_NORMAL=$'\033[0m'
else
  ORB_BOLD=''
  ORB_ITALIC=''
  ORB_UNDERLINE=''
  ORB_DIM=''

  ORB_RED=''
  ORB_GREEN=''
  ORB_BLUE=''
  ORB_WHITE=''

  ORB_NORMAL=''
fi

# Keep this as a function to process $1
orb_upcase() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Formatting Functions
orb_bold()      { printf '%s%s%s\n' "$ORB_BOLD" "$*" "$ORB_NORMAL"; }
orb_italic()    { printf '%s%s%s\n' "$ORB_ITALIC" "$*" "$ORB_NORMAL"; }
orb_underline() { printf '%s%s%s\n' "$ORB_UNDERLINE" "$*" "$ORB_NORMAL"; }
orb_dim()       { printf '%s%s%s\n' "$ORB_DIM" "$*" "$ORB_NORMAL"; }

# Color Functions
orb_red()   { printf '%s%s%s\n' "$ORB_RED" "$*" "$ORB_NORMAL"; }
orb_green() { printf '%s%s%s\n' "$ORB_GREEN" "$*" "$ORB_NORMAL"; }
orb_blue()  { printf '%s%s%s\n' "$ORB_BLUE" "$*" "$ORB_NORMAL"; }
orb_white() { printf '%s%s%s\n' "$ORB_WHITE" "$*" "$ORB_NORMAL"; }
