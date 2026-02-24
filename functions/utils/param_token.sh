# orb_is_flag
declare -A orb_is_flag_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_flag() {
	[[ $1 =~ ^-[a-zA-Z]{1}$ ]] || [[ $1 =~ ^--[a-zA-Z]+(-[a-zA-Z]+)*$ ]]
}

declare -A orb_is_input_flag_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_input_flag() {
    # Single-letter flags: -f or +f
    [[ "$1" =~ ^[-+][a-zA-Z]$ ]] || \
    # Multi-letter / hyphenated flags: --flag or +-flag
    [[ "$1" =~ ^(--|\+-)[a-zA-Z]+(-[a-zA-Z]+)*$ ]]
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
); function orb_is_flag_with_nr() { # starts with - and is followed
	local arg=( $1 )
	orb_is_flag "${arg[0]}" && orb_is_nr "${arg[1]}"
}

# orb_is_block
declare -A orb_is_block_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_block() {
	# Single-letter blocks: -b-
	[[ $1 =~ ^-[a-zA-Z]-$ ]] || \
	# Multi-letter / hyphenated blocks: --verbose-block--
	[[ $1 =~ ^--[a-zA-Z]+(-[a-zA-Z]+)*--$ ]]
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
	orb_is_nr "$1" || orb_is_flag "$1" || orb_is_block "$1" || orb_is_rest "$1" || orb_is_dash "$1"
}

# Declaration-token validator.
# Accepts any standard input arg token (nr/flag/block/rest/dash)
# OR an alias token like "-f|--file" / "-b-|--block--".
function orb_is_param_token() {
	orb_is_canonical_param "$1" || orb_is_alias_token "$1"
}

# Validate flag-alias token parts.
# Valid examples: "-f|--file".
# Invalid examples: "1|--file", "-f|...", "-f|-b-", "-b-|--block--".
function orb_is_flag_alias_token() {
	local token="$1"
	[[ "$token" == *"|"* ]] || return 1

	local aliases=()
	orb_split_flag_aliases "$token" aliases

	local alias
	for alias in "${aliases[@]}"; do
		orb_is_flag "$alias" || return 1
	done

	return 0
}

# Validate block-alias token parts.
# Valid examples: "-b-|--block--".
# Invalid examples: "-f|--file", "-f|-b-", "1|--block--".
function orb_is_block_alias_token() {
	local token="$1"
	[[ "$token" == *"|"* ]] || return 1

	local aliases=()
	orb_split_flag_aliases "$token" aliases

	local alias
	for alias in "${aliases[@]}"; do
		orb_is_block "$alias" || return 1
	done

	return 0
}

# Validate alias token parts.
# Accepts either all flag aliases OR all block aliases.
function orb_is_alias_token() {
	orb_is_flag_alias_token "$1" || orb_is_block_alias_token "$1"
}

# Validate any flag token, including alias form.
function orb_is_flag_token() {
	orb_is_flag "$1" || orb_is_flag_alias_token "$1"
}

# Validate any block token, including alias form.
function orb_is_block_token() {
	orb_is_block "$1" || orb_is_block_alias_token "$1"
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
