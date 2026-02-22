_orb_parse_declared_args() {
	declare -n declaration=${1-"declared_args"}
	declare -A declared_args_start_indexes
	declare -A declared_args_lengths
	_orb_get_declared_args_and_start_indexes
	_orb_validate_declared_args
	_orb_get_declared_args_lengths
	_orb_parse_declared_args_options
}

_orb_get_declared_args_and_start_indexes() {
	local i=1
	# Skip first and last item, because we need neighbors around '='.
	local str; for str in "${declaration[@]:$i:$(( ${#declaration[@]}-2 ))}"; do
		if [[ "$str" == "=" ]]; then
			local arg_raw arg_start_i arg_keys=() arg var valid_var=false
			_orb_get_declared_arg_context "$i" arg_raw arg_start_i
			_orb_get_declared_arg_keys "$arg_raw" arg_keys arg

			var="${declaration[$i+1]}"
			orb_is_valid_variable_name "$var" && valid_var=true

			if orb_is_input_arg "$arg" && ($valid_var || $_orb_declared_raw); then
				_orb_store_declared_arg_suffix "$arg" "$arg_start_i" "$i"
				_orb_store_declared_arg_start_index "$arg" "$arg_start_i"
				_orb_declared_args+=("$arg")
				_orb_store_declared_arg_aliases "$arg" "${arg_keys[@]}"
				_orb_store_declared_arg_variable_or_comment "$arg" "$var" "$valid_var"
			fi
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
# - arg_raw_ref: key token (single or alias form)
# - arg_start_i_ref: index where the arg key starts in declaration
_orb_get_declared_arg_context() {
	local i=$1
	declare -n arg_raw_ref=$2
	declare -n arg_start_i_ref=$3

	arg_raw_ref=${declaration[$i-1]}
	arg_start_i_ref=$((i - 1))

	if [[ $i != 1 ]] && orb_is_nr ${declaration[$i-1]} && orb_is_flag_or_alias_token ${declaration[$i-2]}; then
		arg_raw_ref=${declaration[$i-2]}
		arg_start_i_ref=$((i - 2))
	fi
}

# Expand key token into aliases and select canonical key.
# Canonical key is always first alias in token, eg "-f|--file" => "-f".
_orb_get_declared_arg_keys() {
	local arg_raw=$1
	declare -n arg_keys_ref=$2
	declare -n arg_ref=$3

	orb_split_flag_aliases "$arg_raw" arg_keys_ref
	arg_ref="${arg_keys_ref[0]}"
}
# Store numeric suffix for flagged args.
# Example: "-f 2 = file" stores suffix 2 on canonical key "-f".
_orb_store_declared_arg_suffix() {
	local arg=$1
	local arg_start_i=$2
	local equals_i=$3

	if [[ $arg_start_i == $((equals_i - 2)) ]]; then
		_orb_declared_arg_suffixes[$arg]=${declaration[$equals_i-1]}
	fi
}

# Track where each canonical arg starts in declaration array.
# Used later for option/comment slicing.
_orb_store_declared_arg_start_index() {
	local arg=$1
	local arg_start_i=$2
	declared_args_start_indexes[$arg]=$arg_start_i
}

# Register all aliases to one canonical key.
# Example map entries:
# -f => -f
# --file => -f
# Raises on collisions, eg one alias reused by another arg.
_orb_store_declared_arg_aliases() {
	local arg=$1
	shift
	local aliases=("$@")

	local alias
	for alias in "${aliases[@]}"; do
		if [[ -n ${_orb_declared_arg_aliases[$alias]} ]] && [[ ${_orb_declared_arg_aliases[$alias]} != "$arg" ]]; then
			_orb_raise_invalid_declaration "$alias: multiple definitions"
		fi
		_orb_declared_arg_aliases[$alias]="$arg"
	done
}

# Store declared variable name or, in Raw mode, free-text comment.
# valid_var expected values: true|false.
_orb_store_declared_arg_variable_or_comment() {
	local arg=$1
	local var=$2
	local valid_var=$3

	if $valid_var; then
		_orb_declared_vars[$arg]="$var"
	elif $_orb_declared_raw; then
		_orb_declared_comments[$arg]="$var"
	else
		_orb_raise_invalid_declaration "$arg: invalid variable name '$var'."
	fi
}

_orb_get_declared_args_lengths() {
	local counter=1

	local arg; for arg in "${_orb_declared_args[@]}"; do
		if [[ $counter == ${#_orb_declared_args[@]} ]]; then
			# Last declared
			local ends_before=${#declaration[@]}
		else
			# Not last declared - Ends before next declared
			local ends_before=${declared_args_start_indexes[${_orb_declared_args[$counter]}]}
		fi

		declared_args_lengths[$arg]=$(( $ends_before - ${declared_args_start_indexes[$arg]} ))

		((counter++))
	done
}

