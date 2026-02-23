# local variables in this function have to be _orb_ prefixed to not block assignment 
# to user declared value variables
_orb_assign_stored_arg_values_to_declared_variables() {
	local _orb_param; for _orb_param in "${_orb_declared_params[@]}"; do
    _orb_get_arg_value $_orb_param "${_orb_declared_vars[$_orb_param]}"
  done
}
