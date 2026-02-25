# Internal help functions
_orb_handle_help() {
	$_orb_setting_help || return 1

	if [[ -n "$_orb_function_name" ]]; then
		_orb_print_function_help
	elif [[ -n $_orb_namespace_name ]]; then
		_orb_print_namespace_help
	else
		_orb_print_orb_help
	fi

	return 0
}

_orb_print_orb_help() {
	local def_namespace_msg

	if [[ -n $ORB_DEFAULT_NAMESPACE ]]; then
		def_namespace_msg="Default namespace: $(orb_bold "$ORB_DEFAULT_NAMESPACE")"
	else
		def_namespace_msg="Default namespace \$ORB_DEFAULT_NAMESPACE not set"
	fi

	local help_msg="$def_namespace_msg.\n\n"

	if [[ -z "${_orb_namespaces[*]}" ]]; then
		help_msg+="No namespaces found"
	else
		help_msg+="$(_orb_print_available_namespaces)\n"
		help_msg+="To show information about a namespace, use \`orb --help \"namespace\"\`"
	fi

	echo -e "$help_msg"
}

_orb_print_namespace_help() {
	local i=0 file current_dir output

	local file; for file in "${_orb_namespace_files[@]}"; do
		local dir="${_orb_namespace_files_orb_dir_tracker[$i]}"

		if [[ "$dir" != "$current_dir" ]]; then
			current_dir="$dir"
			output+="-----------------  $(orb_italic "$current_dir")\n"
		fi

		output+="$(orb_bold "$(basename $file)")\n"
		source "$file"
		local fns; orb_get_public_functions "$file" fns

		local fn; for fn in "${fns[@]}"; do
			declare -A _orb_declared_comments=()
			_orb_parse_function_declaration "${fn}_orb" false
			output+="  $fn§"
			output+="${_orb_declared_comments[function]}\n"
		done

		((i++))

		output+='§\n'
	done

	# remove last newline chars §\n
	echo -e "${output::-3}" | column -tes '§'

	echo -e "\nTo show information about a function, use \`orb --help \"namespace\" \"function\"\`"
}

_orb_print_function_help() {
	_orb_print_orb_function_and_comment
	local msg=$(_orb_print_params_explanation)
	[[ -n "$msg" ]] && echo -e "\n$msg"
	return 0
}


_orb_print_orb_function_and_comment() {
	declare -n comments=_orb_declared_comments$_orb_variable_suffix
	declare -n function_descriptor=_orb_function_descriptor$_orb_variable_suffix
	local comment="${comments[function]}"
	echo "$(orb_bold "$function_descriptor") $([[ -n "$comment" ]] && echo "- $comment")"
}

_orb_print_params_explanation() {
	declare -n declared_params=_orb_declared_params$_orb_variable_suffix
	[[ ${#declared_params[@]} == 0 ]] && return 1

	declare -n declared_vars=_orb_declared_vars$_orb_variable_suffix
	declare -n declared_suffixes=_orb_declared_param_suffixes$_orb_variable_suffix

	local labels=()
	local descriptions=()
	local meta_suffixes=()
	local max_label_len=0
	local param; for param in "${declared_params[@]}"; do
		local label="$param"

		if _orb_has_declared_value_flag "$param"; then
			label+=" ${declared_suffixes[$param]}"
		fi

		local desc
		desc="$(_orb_get_param_comment "$param")"
		if [[ $? == 1 ]]; then
			desc="${declared_vars[$param]}"
		fi

		local meta=()
		local required=false
		if _orb_get_param_option_value "$param" Required: required && [[ "$required" == true ]]; then
			meta+=("required")
		fi

		local multiple=false
		if _orb_get_param_option_value "$param" Multiple: multiple && [[ "$multiple" == true ]]; then
			meta+=("multiple")
		fi

		local default=()
		if _orb_get_param_option_value "$param" Default: default; then
			if [[ -n "${default[*]}" ]]; then
				if _orb_has_declared_boolean_flag "$param" && [[ "${default[*]}" == false ]]; then
					:
				else
					meta+=("default: ${default[*]}")
				fi
			fi
		fi

		local meta_suffix=""
		if [[ ${#meta[@]} -gt 0 ]]; then
			local meta_joined="${meta[0]}"
			local meta_i
			for meta_i in "${meta[@]:1}"; do
				meta_joined+=", $meta_i"
			done
			meta_suffix=" ($meta_joined)"
		fi

		labels+=("$label")
		descriptions+=("$desc")
		meta_suffixes+=("$meta_suffix")

		(( ${#label} > max_label_len )) && max_label_len=${#label}
	done

	local label_width=$((max_label_len + 2))
	local i
	for i in "${!labels[@]}"; do
		printf '  %-'"$label_width"'s %s%s\n' "${labels[$i]}" "${descriptions[$i]}" "${meta_suffixes[$i]}"
	done
}
