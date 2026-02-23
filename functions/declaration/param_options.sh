_orb_parse_declared_params_options() {
	local param; for param in "${_orb_declared_params[@]}"; do
		local param_options_declaration=()
		_orb_get_param_options_declaration $param

		_orb_prevalidate_declared_param_options $param
		_orb_parse_declared_param_options $param
	done
	
	_orb_postvalidate_declared_params_options
}


_orb_get_param_options_declaration() {
	local param=$1
	local i_offset=3
	[[ -n ${_orb_declared_param_suffixes[$param]} ]] && (( i_offset++ ))
	_orb_store_declared_param_comment $param $i_offset && (( i_offset++ )) 

	local options_i=$(( ${declared_params_start_indexes[$param]} + $i_offset ))
	local options_len=$(( ${declared_params_lengths[$param]} - $i_offset ))

	[[ $options_len == 0 ]] && return

	param_options_declaration=("${declaration[@]:$options_i:$options_len}")
}

_orb_store_declared_param_comment() {
	local param=$1
	local i_offset=$2
	(( ${declared_params_lengths[$param]} == $i_offset )) && return 1 # no comment available 

	local comment_i=$(( ${declared_params_start_indexes[$param]} + $i_offset ))

	if ! _orb_is_valid_param_option $param "${declaration[$comment_i]}"; then
		_orb_declared_comments[$param]="${declaration[$comment_i]}"
	else
		return 1
	fi
}

_orb_prevalidate_declared_param_options() {
	local param=$1
	[[ -z ${param_options_declaration[@]} ]] || \
	_orb_is_valid_param_option $param "${param_options_declaration[0]}" true
}

_orb_parse_declared_param_options() {
	local param=$1
	local declared_param_options_start_indexes=()
	local declared_param_options_lengths=()
	local declared_param_option_names=()
	_orb_get_declared_param_options_start_indexes $param
	_orb_get_declared_param_options_lengths $param
	_orb_get_declared_param_option_names $param
	_orb_store_declared_param_option_values $param
}

_orb_get_declared_param_options_start_indexes() {
	local param=$1

	local options_i; for options_i in $(seq 0 $((${#param_options_declaration[@]} - 1))); do
		if _orb_is_declared_param_options_start_index $param $options_i; then
			declared_param_options_start_indexes+=( $options_i )
		fi
	done
}

_orb_is_declared_param_options_start_index() {
	local param=$1 
  local options_i=$2
	local current_option="${param_options_declaration[$options_i]}"

	if _orb_is_valid_param_option $param "$current_option"; then
		if [[ -n ${declared_param_options_start_indexes[0]} ]]; then
			local prev_start_i="${declared_param_options_start_indexes[-1]}"
			local prev_option="${param_options_declaration[$prev_start_i]}"
		fi

		if [[ -n $prev_start_i ]] && (( $prev_start_i == $options_i - 1 )); then
			_orb_raise_invalid_declaration "$prev_option invalid value: $current_option"
		elif [[ $options_i == $((${#param_options_declaration[@]} - 1)) ]]; then
			# option is last str
			_orb_raise_invalid_declaration "$current_option missing value"
		else
			return 0
		fi
	fi

	return 1
}

_orb_get_declared_param_options_lengths() {
	local options_length=${#param_options_declaration[@]}
	local counter=1

	local i; for i in "${declared_param_options_start_indexes[@]}"; do
		if [[ $counter == ${#declared_param_options_start_indexes[@]} ]]; then
			# Is last declared - Ends at options end
			local ends_before=$options_length
		else
			# Not last declared - Ends before next declared
			local ends_before=${declared_param_options_start_indexes[$counter]}
		fi

		declared_param_options_lengths+=( $(( $ends_before - $i )) )

		((counter++))
	done
}

_orb_get_declared_param_option_names() {
	local i; for i in "${declared_param_options_start_indexes[@]}"; do
    declared_param_option_names+=(${param_options_declaration[$i]})
	done
}

_orb_store_declared_param_option_values() {
	local param=$1
	local prefix; [[ $param == "${_orb_declared_params[0]}" ]] && prefix="" || prefix=" "

	local option; for option in "${_orb_available_param_options[@]}"; do
		local i value=() value_start_i value_len

		if i=$(orb_index_of $option declared_param_option_names); then
			value_start_i=$(( ${declared_param_options_start_indexes[$i]} + 1))
			value_len=$(( ${declared_param_options_lengths[$i]} - 1))
			value=("${param_options_declaration[@]:$value_start_i:$value_len}")
		else
			_orb_get_default_param_option_value $param $option value
		fi

		if [[ -n "${value[@]}" ]]; then
			_orb_declared_option_start_indexes[$option]+="$prefix${#_orb_declared_option_values[@]}"
			_orb_declared_option_values+=("${value[@]}")
			_orb_declared_option_lengths[$option]+="$prefix${#value[@]}"
		else
			_orb_declared_option_start_indexes[$option]+="${prefix}-"
			_orb_declared_option_lengths[$option]+="${prefix}-"
		fi
	done

	return 0
}

