# Orb/global help functions
_orb_help_requested() {
	[[ $_orb_setting_help == true ]] || [[ $_orb_setting_tree == true ]]
}

_orb_handle_help() {
	_orb_help_requested || return 1

	if [[ $_orb_setting_tree == true ]]; then
		_orb_print_library_tree
	elif [[ -n "$_orb_function_name" ]]; then
		_orb_print_function_help
	elif [[ -n $_orb_namespace_name ]]; then
		_orb_print_namespace_help
	else
		_orb_print_orb_help
	fi

	return 0
}

_orb_print_orb_help() {
	local help_msg=""

	if [[ -n $ORB_DEFAULT_NAMESPACE ]]; then
		help_msg="Default namespace: $ORB_DEFAULT_NAMESPACE.\n\n"
	fi

	if [[ -z "${_orb_namespaces[*]}" ]]; then
		help_msg+="No namespaces found"
	else
		help_msg+="$(_orb_print_available_namespaces)\n"
		help_msg+="Use \`orb -h \"namespace\"\` for more info"
	fi

	echo -e "$help_msg"
}
