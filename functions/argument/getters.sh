# As we are assigning values to a variable with an uncertain name
# Local variables in this function have to be _orb_ prefixed to prevent shadowing
_orb_get_arg_value() {
	local _orb_arg=$1
	declare -n _orb_assign_ref=$2
	local _orb_val=()

	declare -n _orb_values=_orb_args_values$_orb_variable_suffix
	declare -n _orb_values_start_indexes=_orb_args_values_start_indexes$_orb_variable_suffix
	declare -n _orb_values_lengths=_orb_args_values_lengths$_orb_variable_suffix

	local _orb_start_is=(${_orb_values_start_indexes[$_orb_arg]})
	local _orb_lengths=(${_orb_values_lengths[$_orb_arg]})
	local _orb_start_i _orb_length

	local _orb_i; for _orb_i in $(seq 0 $(( ${#_orb_start_is[@]} - 1)) ); do
		_orb_start_i=${_orb_start_is[$_orb_i]}
		_orb_length=${_orb_lengths[$_orb_i]}
		_orb_val+=("${_orb_values[@]:${_orb_start_i}:${_orb_length}}")
	done

	if _orb_has_declared_array_param $_orb_arg; then
		_orb_assign_ref=("${_orb_val[@]}")
	else
		_orb_assign_ref="${_orb_val[*]}"
	fi
}

_orb_has_arg_value() {
	local arg=$1
	declare -n start_indexes=_orb_args_values_start_indexes$_orb_variable_suffix
  [[ -n ${start_indexes[$arg]} ]]
}
