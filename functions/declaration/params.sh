_orb_parse_declared_params() {
	declare -n declaration=${1-"declared_params"}
	declare -A declared_params_start_indexes
	declare -A declared_params_lengths
	_orb_get_declared_params_and_start_indexes
	_orb_get_declared_params_lengths
	_orb_parse_declared_params_options
}

_orb_get_declared_params_and_start_indexes() {
	local i=1
	# Skip first and last item, because we need neighbors around '='.
	local str; for str in "${declaration[@]:$i:$(( ${#declaration[@]}-2 ))}"; do
		if [[ "$str" == "=" ]]; then
			[[ ${declaration[$i-1]} == "Default:" ]] && ((i++)) && continue

			local param_raw param_start_i param_keys=() param var valid_var=false
			_orb_get_declared_param_context "$i" param_raw param_start_i
			_orb_get_declared_param_keys "$param_raw" param_keys param

			var="${declaration[$i+1]}"
			orb_is_valid_variable_name "$var" && valid_var=true
			_orb_validate_declared_param_assignment "$param_raw" "$param" "$var" "$valid_var"

			_orb_store_declared_param_suffix "$param" "$param_start_i" "$i"
			_orb_store_declared_param_start_index "$param" "$param_start_i"
			_orb_declared_params+=("$param")
			_orb_store_declared_param_aliases "$param" "${param_keys[@]}"
			_orb_store_declared_param_variable_or_comment "$param" "$var" "$valid_var"
		fi

		((i++))
	done
}
# Resolve token position for declarations like:
#   -f = var
#   -f 2 = var
#   -f|--file 2 = var
# Inputs:
# - i: index of "=" in declaration array
# Outputs:
# - param_raw_ref: key token (single or alias form)
# - param_start_i_ref: index where the param key starts in declaration
_orb_get_declared_param_context() {
	local i=$1
	declare -n param_raw_ref=$2
	declare -n param_start_i_ref=$3

	param_raw_ref=${declaration[$i-1]}
	param_start_i_ref=$((i - 1))

	if [[ $i != 1 ]] && orb_is_nr ${declaration[$i-1]} && orb_is_flag_token ${declaration[$i-2]}; then
		param_raw_ref=${declaration[$i-2]}
		param_start_i_ref=$((i - 2))
	fi
}

# Expand key token into aliases and select canonical key.
# Canonical key is always first alias in token, eg "-f|--file" => "-f".
_orb_get_declared_param_keys() {
	local param_raw=$1
	declare -n param_keys_ref=$2
	declare -n param_ref=$3

	orb_split_flag_aliases "$param_raw" param_keys_ref
	param_ref="${param_keys_ref[0]}"
}
# Store numeric suffix for value flags.
# Example: "-f 2 = file" stores suffix 2 on canonical key "-f".
_orb_store_declared_param_suffix() {
	local param=$1
	local param_start_i=$2
	local equals_i=$3

	if [[ $param_start_i == $((equals_i - 2)) ]]; then
		_orb_declared_param_suffixes[$param]=${declaration[$equals_i-1]}
	fi
}

# Track where each canonical param starts in declaration array.
# Used later for option/comment slicing.
_orb_store_declared_param_start_index() {
	local param=$1
	local param_start_i=$2
	if [[ -n ${declared_params_start_indexes[$param]} ]]; then
		_orb_raise_invalid_declaration "$param: multiple definitions"
	fi
	declared_params_start_indexes[$param]=$param_start_i
}

# Register all aliases to one canonical key.
# Example map entries:
# -f => -f
# --file => -f
# Raises on collisions, eg one alias reused by another param.
_orb_store_declared_param_aliases() {
	local param=$1
	shift
	local aliases=("$@")

	local alias
	for alias in "${aliases[@]}"; do
		if orb_is_flag "$param" && ! orb_is_flag "$alias"; then
			_orb_raise_invalid_declaration "Alias type mismatch $param|$alias"
		fi
		if orb_is_block "$param" && ! orb_is_block "$alias"; then
			_orb_raise_invalid_declaration "Alias type mismatch $param|$alias"
		fi

		if [[ -n ${_orb_declared_param_aliases[$alias]} ]] && [[ ${_orb_declared_param_aliases[$alias]} != "$param" ]]; then
			_orb_raise_invalid_declaration "$alias: multiple definitions"
		fi
		_orb_declared_param_aliases[$alias]="$param"
	done
}

# Store declared variable name or, in Raw mode, free-text comment.
# valid_var expected values: true|false.
_orb_store_declared_param_variable_or_comment() {
	local param=$1
	local var=$2
	local valid_var=$3

	if $valid_var; then
		_orb_declared_vars[$param]="$var"
	elif $_orb_declared_raw; then
		_orb_declared_comments[$param]="$var"
	else
		_orb_raise_invalid_declaration "$param: invalid variable name '$var'."
	fi
}

_orb_get_declared_params_lengths() {
	local counter=1

	local param; for param in "${_orb_declared_params[@]}"; do
		if [[ $counter == ${#_orb_declared_params[@]} ]]; then
			# Last declared
			local ends_before=${#declaration[@]}
		else
			# Not last declared - Ends before next declared
			local ends_before=${declared_params_start_indexes[${_orb_declared_params[$counter]}]}
		fi

		declared_params_lengths[$param]=$(( $ends_before - ${declared_params_start_indexes[$param]} ))

		((counter++))
	done
}

