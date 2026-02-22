_orb_has_orb_settings_arguments "$@" || return 0
_orb_parse_function_declaration _orb_settings_declaration
_orb_extract_orb_settings_arguments _orb_settings_args "$@"
_orb_collect_function_args ${_orb_settings_args[@]}
_orb_assign_stored_arg_values_to_declared_variables

# Add any collected libraries
if [[ -n "${_orb_setting_libraries[@]}" ]]; then
  _orb_libraries+=("${_orb_setting_libraries[@]}")
fi

# Store function dump if reload functions
$_orb_setting_restore_functions && local _orb_function_dump="$(declare -f)"

# Reset collection variables
source "$_orb_root/scripts/call/variables.sh" only_args_collection
