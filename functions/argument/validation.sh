_orb_is_valid_arg() { # $1 arg_key, $2 arg
	_orb_is_valid_in $1 ${@:2}
}

_orb_is_valid_in() {
	local arg=$1
	local val=(${@:2})
	local in_arr=(); _orb_get_param_option_value $arg "In:" in_arr || return 0

	orb_in_arr "$val" in_arr
}

_orb_raise_invalid_arg() { # $1 arg_key $2 arg_value/required
	local arg
	[[ ${1:0:1} == '-' ]] && ! orb_is_block "$1" && arg='flags' || arg='args'
	local msg="invalid $arg: $1"

	msg+="\n\n$(_orb_print_params_explanation)"

	_orb_raise_error "$msg"
}


_orb_post_validate_args() {
	local param; for param in "${_orb_declared_params[@]}"; do
		local required; _orb_get_param_option_value $param Required: required
		[[ $required == true ]] && ! _orb_has_arg_value "$param" && _orb_raise_error "$param is required"
	done
}

# _orb_validate_declaration() {
# 	orb_is_flag "$1" || \
# 	orb_is_flag_with_nr "$1" || \
# 	orb_is_nr "$1" || \
# 	orb_is_block "$1" || \
# 	_is_rest "$1" || \
# 	_orb_raise_invalid_arg "$1 invalid declaration"
# }

# _orb_validate_required() { # $1 arg, $2 optional args_declaration
# 	if ( \
# 		[[ "$1" == '*' && ${_args['*']} == false ]] || \
# 		[[ "$1" == '-- *' && ${_args['-- *']} == false ]] || \
# 		(! _is_rest "$1" && [[ -z ${_args["$1"]+x} ]]) \
# 	) \
# 	&& _orb_is_required "$1" $2; then
# 		_orb_raise_invalid_arg "$1 is required"
# 	fi
# }

# _orb_validate_empty() { # $1 arg_key
# 	if [[ -z "${_args["$1"]}" && -n ${_args["$1"]+x} ]]; then
# 		# is empty str
# 		if ! _orb_catches_empty "$1"; then
# 			_orb_raise_invalid_arg "$_arg with value \"\", add CATCH_ANY to allow empty string"
# 		fi
# 	fi
# }

# _orb_is_required() { # $1 arg, $2 optional args_declaration
# 	( orb_is_flag_with_nr "$1" && _orb_get_arg_prop "$1" 'REQUIRED' $2) || \
# 	( orb_is_block "$1" && _orb_get_arg_prop "$1" 'REQUIRED' $2) || \
# 	( (! orb_is_flag "$1" && ! orb_is_flag_with_nr "$1" && ! orb_is_block "$1" ) && ! _orb_get_arg_prop "$1" 'OPTIONAL' $2)
# }

