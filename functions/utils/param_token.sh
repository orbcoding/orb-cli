# orb_is_flag
declare -A orb_is_flag_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_flag() { # starts with single - or + and has no spaces (+ falsifies if default val true)
	[[ $1 =~ ^[-+]{1}[a-zA-ZwW]+$ ]]
}

# orb_is_verbose_flag
declare -A orb_is_verbose_flag_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_verbose_flag() { # starts with -- and has no spaces.
	[[ $1 =~ ^[+-]{1}[-]{1}[a-zA-ZwW0-9_][a-zA-ZwW0-9_-]*$ ]] && [[ "${1: -1}" != "-" ]]
}

declare -A orb_is_any_flag_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_any_flag() { # starts with single - or + and has no spaces (+ falsifies if default val true)
	orb_is_flag "$1" || orb_is_verbose_flag "$1"
}

# orb_is_nr
declare -A orb_is_nr_args=(
	['1']='number input'
); function orb_is_nr() { # check if is nr
	[[ "$1" =~ ^[0-9]+$ ]]
}

# orb_is_flag_with_nr
declare -A orb_is_flag_with_nr_args=(
	['1']='arg'
); function orb_is_flag_with_nr() { # starts with - and has substr ' arg'
	local arg=( $1 )
	local flag="${arg[0]}"
	[[ "${flag:0:1}" == - ]] && orb_is_any_flag "${arg[0]}" && orb_is_nr "${arg[1]}"
}

# orb_is_block
declare -A orb_is_block_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_block() { # like a flag that ends with -
	[[ $1 =~ ^[-]{1}[a-zA-ZwW0-9_-][a-zA-ZwW0-9_-]*-$ ]]
}

# orb_is_rest
declare -A orb_is_rest_args=(
	['1']='arg'
); function orb_is_rest() {
	[[ "$1" == "..." ]]
}

# orb_is_dash
declare -A orb_is_dash_args=(
	['1']='arg'
); function orb_is_dash() {
	[[ "$1" == "--" ]]
}

function orb_is_canonical_param() {
	orb_is_nr "$1" || orb_is_any_flag "$1" || orb_is_block "$1" || orb_is_rest "$1" || orb_is_dash "$1"
}

# Declaration-token validator.
# Accepts any standard input arg token (nr/flag/block/rest/dash)
# OR an alias flag token like "-f|--file".
function orb_is_param_token() {
	orb_is_canonical_param "$1" || orb_is_flag_or_alias_token "$1"
}

# Validate that every alias in a pipe token is a real flag token.
# Valid examples: "-f|--file", "+f|--file".
# Invalid examples: "1|--file", "-f|...", "-b-|--block".
function orb_is_flag_or_alias_token() {
	local token="$1"
	local aliases=()
	orb_split_flag_aliases "$token" aliases

	local alias
	for alias in "${aliases[@]}"; do
		orb_is_any_flag "$alias" || return 1
	done

	return 0
}

# Split a declaration token into flag aliases.
# Input token types:
# - single key: "-f" or "--file"
# - alias key:  "-f|--file"
# Output: writes array to assign_ref preserving order, where index 0 is canonical key.
function orb_split_flag_aliases() {
	local token="$1"
	declare -n assign_ref=$2

	if [[ "$token" == *"|"* ]]; then
		IFS='|' read -r -a assign_ref <<< "$token"
	else
		assign_ref=("$token")
	fi
}

function orb_is_valid_variable_name() {
	[[ "$1" =~ ^[a-zA-ZwW_][a-zA-Z0-9_wW]*$ ]]
}
