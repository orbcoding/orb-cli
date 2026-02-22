$_orb_settings_help || return 1

if [[ -n "$_orb_function_name" ]]; then
  _orb_print_function_help
elif [[ -n $_orb_namespace_name ]]; then
  _orb_print_namespace_help
else
  _orb_print_orb_help
fi

source "$_orb_root/scripts/call/cleanup.sh" 

return 0
