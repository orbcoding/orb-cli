#!/bin/bash
#
# Function arguments collector
#
# Arguments are checked against the functions orb declaration
# _orb_parse_function_declaration should have been called before
#
# Main function
_orb_collect_function_args() {
	local args_count=1
	local args_remaining=( "$@" ) # array of input args each quoted
	
	if [[ ${#_orb_declared_params[@]} == 0 ]]; then
		if [[ ${#args_remaining[@]} != 0 ]]; then
			_orb_raise_error "does not accept arguments"
		else # no args to parse
			return 0
		fi
	fi

	_orb_collect_args
	_orb_set_default_arg_values
	_orb_post_validate_args
}

_orb_collect_args() {
	# Start collecting from first input arg onwards
	while [[ "${#args_remaining[@]}" > 0 ]]; do
		local arg="${args_remaining[0]}"

		if orb_is_input_flag "$arg"; then 
			_orb_collect_flag_arg "$arg"
		elif orb_is_block "$arg"; then
			_orb_collect_block_arg "$arg"
		else
			_orb_collect_inline_arg "$arg"
		fi
	done

}

_orb_collect_flag_arg() { # $1 input_arg
	local arg=$1

	if _orb_has_declared_boolean_flag $arg; then
		_orb_store_boolean_flag "$arg"
	elif _orb_has_declared_value_flag "$arg"; then
		_orb_store_value_flag "$arg"
	else
		local invalid_flags=()
		_orb_try_collect_multiple_flags "$arg"

		if [[ $? == 1 ]]; then 
			_orb_try_inline_arg_fallback "$arg" "${invalid_flags[*]}"
		fi
	fi
}

_orb_collect_block_arg() {
	local arg=$1

	if _orb_has_declared_param "$arg"; then
		_orb_store_block "$arg"
	else
		_orb_try_inline_arg_fallback "$arg" "$arg"
	fi
}

_orb_collect_inline_arg() {
	local arg=$1
	# add numbered args to args and _args_nrs
	if [[ "$arg" == '--' ]] && _orb_has_declared_param $arg; then
		_orb_store_dash
	elif _orb_has_declared_param "$args_count" && _orb_is_valid_arg "$args_count" "$arg"; then
		_orb_store_inline_arg "$arg"
	elif _orb_has_declared_param '...'; then
		_orb_store_rest
	else
		_orb_raise_invalid_arg "$args_count with value ${1:-\"\"}"
	fi
}

_orb_try_inline_arg_fallback() {
	# If failed to parse flags or block, fall back to inline args 
	local arg=$1
	local failed_arg=$2 # usually the same unless multiflag

	if _orb_has_declared_param "$args_count" && _orb_is_valid_arg "$args_count" "$arg" && _orb_param_catches "$args_count" "$arg"; then
		_orb_store_inline_arg "$arg"
	elif _orb_has_declared_param "..." && _orb_param_catches "..." "$arg"; then
		_orb_store_rest
	else
		_orb_raise_invalid_arg "$failed_arg"
	fi
}

_orb_try_collect_multiple_flags() { # $1 arg
	if [[ "$1" =~ ^(--|\+-).* ]]; then
		invalid_flags+=( "$1" )
		return 1 # only single boolean flags can be multi-flags
	fi

	# split to individual flags
	local flags=$(echo "${1:1}" | grep -o . | sed s/^/-/g )
	local valid_flags=()

	# collect all invalid flags for verbose error
	local flag; for flag in $flags; do
		if _orb_has_declared_param "$flag"; then
			valid_flags+=($flag)
		else
			invalid_flags+=($flag)
		fi
	done

	# assign flags only if no invalids
	[[ ${#invalid_flags} != 0 ]] && return 1

	local steps=1 # to shift

	local flag; for flag in "${valid_flags[@]}"; do
		local suffix=${_orb_declared_param_suffixes[$flag]}

		if [[ -z "$suffix" ]]; then 
			_orb_store_boolean_flag "$flag" 0
		else
			_orb_store_value_flag "$flag" 0
			# if declared eg: -f 2 = var - we need to shift 3 steps to pass -f + 2 
			(( $suffix >= $steps )) && steps=$((suffix + 1))
		fi
	done

	_orb_shift_args $steps 
}

# shift one = remove first arg from arg array
_orb_shift_args() {
	local steps=${1-1}
	args_remaining=("${args_remaining[@]:${steps}}")
}
