# Store argument values in single values array
# With each argument specifying start index and length
# Input key may be runtime alias (eg: --file); for flags we canonicalize first.
_orb_store_arg_value() {
	local arg=$1 && shift
	orb_is_any_flag "$arg" && arg=$(_orb_get_declared_param_key "$arg")

	if _orb_has_arg_value $arg && _orb_param_option_value_is $arg Multiple: true; then
		_orb_args_values_start_indexes[$arg]+=" ${#_orb_args_values[@]}"
		_orb_args_values_lengths[$arg]+=" $#"
	else
		_orb_args_values_start_indexes[$arg]=${#_orb_args_values[@]}
		_orb_args_values_lengths[$arg]="$#"
	fi
	 
	_orb_args_values+=("$@")
}

_orb_store_boolean_flag() {
	# $1 can be short/long/+ alias flag token.
	# Value is derived from prefix of original token (- => true, + => false),
	# then stored on canonical key.
	local arg=$(_orb_get_declared_param_key "$1")
	local shift=${2-1}
	local value=$(_orb_flag_value "$1")
	_orb_store_arg_value $arg $value
	_orb_shift_args $shift
}

_orb_flag_value() {
	[[ ${1:0:1} == '-' ]] && echo true || echo false
}

_orb_store_flagged_arg() {
	# $1 can be alias token; suffix lookup always uses canonical key.
	local arg=$(_orb_get_declared_param_key "$1")
	local suffix=${_orb_declared_param_suffixes[$arg]}
	local shift=${2-$(($suffix + 1))}
	local value=("${args_remaining[@]:1:$suffix}")

	if _orb_is_valid_arg "$arg" "${value[@]}"; then
		_orb_store_arg_value $arg "${value[@]}"
	else
		_orb_raise_invalid_arg "$arg" "${value[@]}"
	fi

	_orb_shift_args $shift
}

_orb_store_block() {
	local arg=$1
	local value=()
	_orb_shift_args # shift away first block

	local a; for a in "${args_remaining[@]}"; do
		if [[ "$a" == "$arg" ]]; then
			# end of block
			_orb_shift_args
			_orb_store_arg_value $arg "${value[@]}"
			return 0
		else
			value+=("$a")
			_orb_shift_args
		fi 
	done

	_orb_raise_error "'$arg' missing block end"
}

_orb_store_inline_arg() {
	_orb_store_arg_value $args_count "$1"
	(( args_count++ ))
	_orb_shift_args
}

_orb_store_dash() {
	_orb_store_arg_value "${args_remaining[@]}"
	args_remaining=()
}

_orb_store_rest() {
	local rest=()

	local i_next=1
	local arg; for arg in "${args_remaining[@]}"; do
		rest+=("$arg")

		if [[ "${args_remaining[$i_next]}" == '--' ]]; then
			_orb_shift_args $i_next
			_orb_store_dash
			break
		fi

		((i_next++))
	done

	_orb_store_arg_value '...' "${rest[@]}"
 	args_remaining=()
}
