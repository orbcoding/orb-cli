# Declaration checkers
_orb_has_declared_param() {
	# Accepts short/long aliases and normalized +flag forms.
	local param=$(_orb_get_declared_param_key "$1")
	orb_in_arr "$param" "_orb_declared_params$_orb_variable_suffix"
}

_orb_has_declared_boolean_flag() { # $1 param
	local param=$(_orb_get_declared_param_key "$1")
	! (_orb_has_declared_param $param && orb_is_flag $param) && return 1
	declare -n suffixes="_orb_declared_param_suffixes$_orb_variable_suffix"
  [[ -z ${suffixes[$param]} ]]
}

_orb_has_declared_value_flag() { # $1 param
	local param=$(_orb_get_declared_param_key "$1")
	! _orb_has_declared_param $param && return 1
	
	declare -n suffixes="_orb_declared_param_suffixes$_orb_variable_suffix"
	[[ -n ${suffixes[$param]} ]]
}

_orb_has_declared_array_flag_param() {
	local param=$(_orb_get_declared_param_key "$1")
	
	declare -n suffixes="_orb_declared_param_suffixes$_orb_variable_suffix"
	local suffix=${suffixes[$param]}
	
	if orb_is_flag $param && [[ -n $suffix ]] && (( $suffix > 1 )); then 
		return 0
	fi

	return 1
}

_orb_has_declared_array_param() {
	local param=$1

	_orb_has_declared_array_flag_param $param || _orb_param_option_value_is $param Multiple: true || \
	orb_is_dash $param || orb_is_rest $param || orb_is_block $param
}

_orb_param_option_value_is() {
	local param=$1
	local opt=$2
	_orb_get_param_option_value $param $opt value
	[[ "${value[*]}" == $3 ]]
}

_orb_param_catches() { # $1 param
	local param=$1
	local value=$2
	local param_catch; _orb_get_param_option_value $param "Catch:" param_catch

	orb_in_arr any param_catch && return

	if orb_is_input_flag $value; then
		! orb_in_arr flag param_catch && return 1
	elif orb_is_block $value; then
		! orb_in_arr block param_catch && return 1
	elif orb_is_dash $value; then
		! orb_in_arr dash param_catch && return 1
	fi
	
	return 0
}
