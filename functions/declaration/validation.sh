# Nothing here yet
# What should be validated is:

# - Required = true/false
# - Default value length <= flag_suffix_length or == 1 for non arrays

# - In is currently only for non arrays...
# - Comment should be able to array and then captured as single
_orb_prevalidate_declaration() {
	if [[ ${declaration[0]} == '=' ]]; then 
		raise_invalid_declaration 'Cannot start with ='
	fi
}

_orb_raise_invalid_declaration() {
	_orb_raise_error "Invalid declaration. $*" 
}

_orb_raise_undeclared() {
	declare -n _orb_fn_descriptor=_orb_function_descriptor$_orb_variable_suffix
	_orb_raise_error "'$1' not in $_orb_fn_descriptor params declaration\n\n$(_orb_print_params_explanation)"
}

_orb_validate_declared_param_assignment() {
	local param_raw=$1
	local param=$2
	local var=$3
	local valid_var=$4

	if [[ "$param_raw" == *"|"* ]] && ! orb_is_alias_token "$param_raw"; then
		_orb_raise_invalid_declaration "$param_raw: invalid alias declaration"
	fi

	if ! orb_is_canonical_param "$param"; then
		_orb_raise_invalid_declaration "$param_raw = $var: invalid param assignment"
	fi

	if ! $valid_var && ! $_orb_declared_raw; then
		_orb_raise_invalid_declaration "$param: invalid variable name '$var'."
	fi
}

_orb_postvalidate_declared_params_options() {
  _orb_postvalidate_declared_params_options_catchs
	_orb_postvalidate_declared_params_options_requireds
	_orb_postvalidate_declared_params_options_multiples
	# _orb_postvalidate_declared_params_incompatible_options
}

_orb_postvalidate_declared_params_options_catchs() {
	local param; for param in "${_orb_declared_params[@]}"; do
		local param_catch; _orb_get_param_option_declaration $param "Catch:" param_catch
		
		local value; for value in "${param_catch[@]}"; do
			if ! orb_in_arr $value _orb_available_param_option_catch_values; then
				_orb_raise_invalid_declaration "$param: Invalid Catch: value: $value. Available values: ${_orb_available_param_option_catch_values[*]}"
			fi
		done
	done
}

_orb_postvalidate_declared_params_options_requireds() {
	local param; for param in "${_orb_declared_params[@]}"; do
	 	local value; _orb_get_param_option_value $param "Required:" value

		if ! orb_in_arr $value _orb_available_param_option_required_values; then
			_orb_raise_invalid_declaration "$param: Invalid Required: value: $value. Available values: ${_orb_available_param_option_required_values[*]}"
		fi
	done
}

_orb_postvalidate_declared_params_options_multiples() {
	local param; for param in "${_orb_declared_params[@]}"; do
	 	local value; _orb_get_param_option_value $param "Multiple:" value
		if [[ -n $value ]] && ! orb_in_arr $value _orb_available_param_option_multiple_values; then
			_orb_raise_invalid_declaration "$param: Invalid Multiple: value: $value. Available values: ${_orb_available_param_option_multiple_values[*]}"
		fi
	done
}

# _orb_postvalidate_declared_params_incompatible_options() {
# 	local param; for param in ${_orb_declared_params[@]}; do
# 		if _orb_get_param_option_declaration $param "Default:" && _orb_get_param_option_declaration $param "DefaultHelp:"; then
# 			_orb_raise_invalid_declaration "$param: Incompatible options: Default:, DefaultHelp:"
# 		fi
# 	done
# }

_orb_is_valid_param_option() {
	local param=$1 
	local option=$2
	local raise=${3-false}
	local error

	if orb_is_nr $param && ! orb_in_arr "$option" _orb_available_param_options_number; then
		error="$param: Invalid option: $option. Available options for number params: ${_orb_available_param_options_number[*]}"
	elif _orb_has_declared_boolean_flag $param && ! orb_in_arr "$option" _orb_available_param_options_boolean_flag; then
		error="$param: Invalid option: $option. Available options for boolean flags: ${_orb_available_param_options_boolean_flag[*]}"
	elif _orb_has_declared_value_flag $param && ! orb_in_arr "$option" _orb_available_param_options_value_flag; then
		error="$param: Invalid option: $option. Available options for flag params: ${_orb_available_param_options_value_flag[*]}"
	elif _orb_has_declared_array_flag_param $param && ! orb_in_arr "$option" _orb_available_param_options_array_flag; then
		error="$param: Invalid option: $option. Available options for flag array params: ${_orb_available_param_options_array_flag[*]}"
	elif orb_is_block $param && ! orb_in_arr "$option" _orb_available_param_options_block; then
		error="$param: Invalid option: $option. Available options for blocks: ${_orb_available_param_options_block[*]}"
	elif orb_is_dash $param && ! orb_in_arr "$option" _orb_available_param_options_dash; then
		error="$param: Invalid option: $option. Available options for --: ${_orb_available_param_options_dash[*]}"
	elif orb_is_rest $param && ! orb_in_arr "$option" _orb_available_param_options_rest; then
		error="$param: Invalid option: $option. Available options for ...: ${_orb_available_param_options_rest[*]}"
	fi

	if [[ -n $error ]]; then
	 	[[ $raise == true ]] && _orb_raise_invalid_declaration "$error"
		return 1
	fi
}


_orb_postvalidate_declared_function_options() {
  _orb_postvalidate_declared_function_options_raw
}

_orb_postvalidate_declared_function_options_raw() {
	local value=$_orb_declared_raw
	if ! orb_in_arr "$value" _orb_available_function_option_raw_values; then
		_orb_raise_invalid_declaration "Function: Raw: $value. Available values: ${_orb_available_function_option_raw_values[*]}"
	fi
}

_orb_is_valid_function_option() {
	local option=$1
	local raise=${2-false}

	if ! orb_in_arr $1 _orb_available_function_options; then
		[[ $raise == true ]] && _orb_raise_invalid_declaration "Function: Invalid option: $option. Available function options ${_orb_available_function_options[*]}"
	fi
}

