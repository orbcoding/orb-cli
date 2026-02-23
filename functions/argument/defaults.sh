_orb_set_default_arg_values() {
  local param; for param in "${_orb_declared_params[@]}"; do
    _orb_has_arg_value $param || _orb_set_default_from_declaration $param
  done
}

_orb_set_default_from_declaration() {
  local param="$1"
  local default; _orb_get_param_option_value $param "Default:" default || return 1
  _orb_store_arg_value "$param" "${default[@]}"
}
