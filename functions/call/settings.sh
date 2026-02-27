_orb_extract_orb_settings_arguments() {
  declare -n assign_ref=$1
  local args=("${@:2}")

  local i=0 last_flag_i last_flag_suffix

  local arg; for arg in "${args[@]}"; do
    if orb_is_input_flag $arg; then
      if _orb_has_declared_param $arg; then
        last_flag_i=$i
        last_flag_suffix=${_orb_declared_param_suffixes[$arg]}
      else
        _orb_raise_invalid_orb_settings_arg ${args[$i]}
      fi
    else
      [[ -z $last_flag_suffix ]] || \
      (( $i - $last_flag_i > $last_flag_suffix )) && break
    fi
  
    ((i++))
  done

  assign_ref=("${args[@]:0:$i}")
}

_orb_has_orb_settings_arguments() {
  local args="$@"
  orb_is_input_flag ${args[0]}
}


_orb_raise_invalid_orb_settings_arg() {
  local invalid_arg="$1"
  local error_msg="invalid option: $invalid_arg\n\navailable options:\n\n"

  local settings
  local param; for param in "${_orb_declared_params[@]}"; do
    settings+="  $param; ${_orb_declared_comments[$param]}\n"
  done

  error_msg+=$(echo -e "$settings" | column -tes ';')
  _orb_raise_error "$error_msg" "orb"
}
