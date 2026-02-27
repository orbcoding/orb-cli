# Orb/global help functions
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
		def_namespace_msg="Default namespace: $ORB_DEFAULT_NAMESPACE"
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
