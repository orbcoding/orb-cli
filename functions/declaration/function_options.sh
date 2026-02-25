
_orb_parse_declared_function_options() {
  declare -n declaration=${1-"declared_function_options"}
	_orb_extract_function_comment

	declare -a declared_function_options_start_indexes
	declare -a declared_function_options_lengths
	_orb_prevalidate_declared_function_options
	_orb_get_function_options_start_indexes
	_orb_get_function_options_lengths
	_orb_store_function_options
	_orb_postvalidate_declared_function_options
}

_orb_prevalidate_declared_function_options() {
	_orb_is_valid_function_option ${declaration[0]} true
}

_orb_extract_function_comment() {
	local comment="${declaration[0]}"
	if [[ -n "$comment" ]] && ! orb_in_arr "$comment" _orb_available_function_options; then
		_orb_declared_comments["function"]="$comment"
		declaration=( "${declaration[@]:1}" )
	else
		return 1
	fi
}

_orb_get_function_options_start_indexes() {
	local options_i; for options_i in $(seq 0 $((${#declaration[@]} - 1))); do
		if _orb_is_function_options_start_index $options_i; then
			declared_function_options_start_indexes+=( $options_i )
		fi
	done
}

_orb_is_function_options_start_index() {
  local options_i=$1
	local current_option="${declaration[$options_i]}"

	if orb_in_arr $current_option _orb_available_function_options; then
		# Is valid option
		if [[ -n ${declared_function_options_start_indexes[0]} ]]; then
			local prev_start_i="${declared_function_options_start_indexes[-1]}"
			local prev_option="${declaration[$prev_start_i]}"
		fi

		if [[ -n $prev_start_i ]] && (( $prev_start_i == $options_i - 1 )); then
			# option is value for previous option
			_orb_raise_invalid_declaration "invalid value for option $prev_option; got: $current_option"
		elif [[ $options_i == $((${#declaration[@]} - 1)) ]]; then
			# option is last str
			_orb_raise_invalid_declaration "missing value for option $current_option"
		else
			return 0
		fi
	fi

	return 1
}

_orb_get_function_options_lengths() {
	local options_length=${#declaration[@]}
	local counter=1

	local i; for i in "${declared_function_options_start_indexes[@]}"; do
		if [[ $counter == ${#declared_function_options_start_indexes[@]} ]]; then
			# Is last declared - Ends at options end
			local ends_before=$options_length
		else
			# Not last declared - Ends before next declared
			local ends_before=${declared_function_options_start_indexes[$counter]}
		fi

		declared_function_options_lengths+=( $(( $ends_before - $i )) )

		((counter++))
	done
}


_orb_store_function_options() {
  local options_i=0

  local i; for i in "${declared_function_options_start_indexes[@]}"; do
    local option=${declaration[$i]}
    local value_start_i=$(( $i + 1 )) # first is option itself
    local value_len=$(( ${declared_function_options_lengths[$options_i]} - 1 )) # hence one shorter
    local value=( "${declaration[@]:$value_start_i:$value_len}" )


    case $option in
      'Raw:')
        _orb_declared_raw="${value[@]}"
        ;;
    esac

    ((options_i++))
  done

	return 0
}
