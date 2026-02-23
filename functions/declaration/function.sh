_orb_parse_function_declaration() {
	declare -n declaration=${1-"_orb_function_declaration"}
	local parse_params=${2-true}

	_orb_prevalidate_declaration
	
	declare -a declared_function_options
	declare -a declared_params
	_orb_get_declared_function_options
	_orb_get_declared_params

	_orb_parse_declared_function_options
	$parse_params && _orb_parse_declared_params
	 
	return 0
}

_orb_get_declared_function_options() {
	# Skip iterating last 3 because in: param = var 
	# param has to be followed by 2 entries and indexes are len - 1 
	local fn_start_i=0 fn_len
	local i; for i in $(seq 0 $((${#declaration[@]} - 3))); do

		if [[ ${declaration[$i+1]} == "=" ]] && orb_is_param_token ${declaration[$i]}; then 
			if orb_is_nr ${declaration[$i]} && orb_is_flag_or_alias_token ${declaration[$i-1]}; then 
				# step back if flagged param
				fn_len=$(($i - 1))
			else
				fn_len=$i
			fi
			break
		fi
	done

	[[ -z $fn_len ]] && fn_len=${#declaration[@]}
	declared_function_options=( "${declaration[@]:$fn_start_i:$fn_len}" )
}

_orb_get_declared_params() {
	local start_i=0
	local opt_len=${#declared_function_options[@]}
	local len=$(( ${#declaration[@]} - $opt_len ))

	if [[ $opt_len != 0 ]]; then
		start_i=$(( $opt_len ))
	fi

	declared_params=( "${declaration[@]:$start_i:$len}" )
}

