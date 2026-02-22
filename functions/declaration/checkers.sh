# Declaration checkers
_orb_has_declared_arg() {
	# Accepts short/long aliases and normalized +flag forms.
	local arg=$(_orb_get_declared_arg_key "$1")
	orb_in_arr "$arg" "_orb_declared_args$_orb_variable_suffix"
}

_orb_has_declared_boolean_flag() { # $1 arg
	local arg=$(_orb_get_declared_arg_key "$1")
	! (_orb_has_declared_arg $arg && orb_is_any_flag $arg) && return 1
	declare -n suffixes="_orb_declared_arg_suffixes$_orb_variable_suffix"
  [[ -z ${suffixes[$arg]} ]]
}

_orb_has_declared_flagged_arg() { # $1 arg
	local arg=$(_orb_get_declared_arg_key "$1")
	! _orb_has_declared_arg $arg && return 1
	
	declare -n suffixes="_orb_declared_arg_suffixes$_orb_variable_suffix"
	[[ -n ${suffixes[$arg]} ]]
}

_orb_has_declared_array_flag_arg() {
	local arg=$(_orb_get_declared_arg_key "$1")
	
	declare -n suffixes="_orb_declared_arg_suffixes$_orb_variable_suffix"
	local suffix=${suffixes[$arg]}
	
	if orb_is_any_flag $arg && [[ -n $suffix ]] && (( $suffix > 1 )); then 
		return 0
	fi

	return 1
}

_orb_has_declared_array_arg() {
	local arg=$1

	_orb_has_declared_array_flag_arg $arg || _orb_arg_option_value_is $arg Multiple: true || \
	orb_is_dash $arg || orb_is_rest $arg || orb_is_block $arg
}

_orb_arg_option_value_is() {
	local arg=$1
	local opt=$2
	_orb_get_arg_option_value $arg $opt value
	[[ "${value[@]}" == $3 ]]
}

_orb_arg_catches() { # $1 arg
	local arg=$1
	local value=$2
	local arg_catch; _orb_get_arg_option_value $arg "Catch:" arg_catch

	orb_in_arr any arg_catch && return

	if orb_is_flag $value; then
		! orb_in_arr flag arg_catch && return 1
	elif orb_is_block $value; then
		! orb_in_arr block arg_catch && return 1
	elif orb_is_dash $value; then
		! orb_in_arr dash arg_catch && return 1
	fi
	
	return 0
}
