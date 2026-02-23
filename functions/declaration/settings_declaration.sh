_orb_settings_declaration=(
  '-h|--help' = _orb_setting_help
    "Show help"
  -l 1 = _orb_setting_libraries
    "Additional orb library folders"
    Multiple: true
  -r = _orb_setting_raw
    "Pass raw input arguments to called function"
  --restore-fns = _orb_setting_restore_functions
    "Restore functions after call, as declared before sourcing function files."
)
