orb_bold=$(printf '\033[1m')
orb_italic=$(printf '\033[3m')
orb_underline=$(printf '\033[4m')
orb_red=$(printf '\033[0;91m')
orb_green=$(printf '\033[0;32m')
orb_blue=$(printf '\033[0;34m')
orb_normal=$(printf '\033[0m')
orb_nocolor=$(printf '\033[0m')

# Keep this as a function to process $1
function orb_upcase() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Formatting Functions
orb_bold()      { echo "${orb_bold}$*${orb_normal}"; }
orb_italic()    { echo "${orb_italic}$*${orb_normal}"; }
orb_underline() { echo "${orb_underline}$*${orb_normal}"; }

# Color Functions
orb_red()       { echo "${orb_red}$*${orb_normal}"; }
orb_green()     { echo "${orb_green}$*${orb_normal}"; }
orb_blue()      { echo "${orb_blue}$*${orb_normal}"; }
