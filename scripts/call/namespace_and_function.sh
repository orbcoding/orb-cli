_orb_get_current_namespace "$@" && \
shift "$(_orb_get_namespace_shift_steps)"

_orb_get_current_function "$@" && shift
_orb_get_current_function_descriptor "$_orb_function_name" "$_orb_namespace_chain_name"
_orb_validate_current_namespace
_orb_validate_current_function

if [[ -z $_orb_function_name ]]; then
  if ! $_orb_setting_raw && ! $_orb_setting_help; then
		_orb_raise_error "missing function for namespace: $_orb_namespace_chain_name\n\nUse \`orb --help $_orb_namespace_chain_name\` for list of functions" "$_orb_namespace_chain_name"
  fi
else
  declare -n _orb_function_declaration="${_orb_function_name}_orb"
fi

_orb_collect_namespace_files
