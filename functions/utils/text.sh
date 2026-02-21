function orb_bold() { # $(orb_bold)text$(orb_normal)
	echo '\033[1m'
}

function orb_italic() { # $(orb_italic)text$(orb_normal)
	echo '\e[3m'
}

function orb_underline() { # $(orb_underline)text$(orb_normal)
	echo '\e[4m'
}

function orb_red() { # $(orb_red)redtext...
	echo '\033[0;91m'
}

function orb_green() { # $(orb_green)greentext...
	echo '\033[0;32m'
}

function orb_blue() {
	echo '\033[0;34m'
}

function orb_normal() { # $(orb_bold)text$(orb_normal)
	echo '\033[0m'
}

function orb_nocolor() { # $(orb_nocolor)text...
 	echo '\033[0m'
}

function orb_upcase() { # upcase all characters in text
	echo "$1" | tr a-z A-Z
}

function orb_success() {
	echo -e "$(orb_green)"$@"$(orb_normal)"
}
