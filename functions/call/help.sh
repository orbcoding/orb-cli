# Internal help functions
_orb_handle_help() {
	$_orb_setting_help || return 1

	if [[ -n "$_orb_function_name" ]]; then
		_orb_print_function_help
	elif [[ -n $_orb_namespace ]]; then
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
	local msg=$(_orb_print_args_explanation)
	[[ -n "$msg" ]] && echo -e "\n$msg"
	return 0
}


_orb_print_orb_function_and_comment() {
	declare -n comments=_orb_declared_comments$_orb_variable_suffix
	declare -n function_descriptor=_orb_function_descriptor$_orb_variable_suffix
	local comment="${comments[function]}"
	echo "$(orb_bold "$function_descriptor") $([[ -n "$comment" ]] && echo "- $comment")"
}

_orb_print_args_explanation() {
	declare -n declared_args=_orb_declared_args$_orb_variable_suffix
	[[ ${#declared_args[@]} == 0 ]] && return 1

	OLD_IFS=$IFS
	IFS='§'; local msg="$(orb_bold '§')${_orb_available_arg_options_help[*]}$(orb_bold '§')\n"
	IFS=$OLD_IFS

	local arg; for arg in "${declared_args[@]}"; do
		local msg+="$arg"

	 	if _orb_has_declared_flagged_arg $arg; then
			declare -n declared_suffixes=_orb_declared_arg_suffixes$_orb_variable_suffix
			msg+=" ${declared_suffixes[$arg]}"
		fi

		local opt; for opt in "${_orb_available_arg_options_help[@]}"; do
			local value=()
			
			_orb_get_arg_option_declaration $arg $opt value

			msg+="§$([[ -n "${value[@]}" ]] && echo "${value[@]}" || echo '-')"
		done

		local comment; comment="$(_orb_get_arg_comment $arg)"
		if [[ $? == 1 ]]; then
			declare -n declared_vars=_orb_declared_vars$_orb_variable_suffix
			comment=${declared_vars[$arg]}
		fi

		msg+="§$comment\n"
	done

	echo -e "$msg" | sed 's/^/  /' | column -t -s '§'
}
