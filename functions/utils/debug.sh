# orb_ee
declare -A orb_ee_args=(
  ['*']='msg; CATCH_ANY'
); function orb_ee() { # echo to stderr, useful for debugging without polluting stdout
  echo "$@" >&2
}

# orb_print_args
function orb_print_args() { # print collected arguments, useful for debugging
  source "$_orb_bin"

  local _orb_history_index=$1

  if [[ -n $_orb_history_index ]]; then
    (( _orb_history_index-- ))
  else
    _orb_history_index=0
  fi

  _orb_variable_suffix=_history_$_orb_history_index

  declare -n _orb_declared_params_ref=_orb_declared_params$_orb_variable_suffix
  [[ -z "${_orb_declared_params_ref[*]}" ]] && return 1

	declare -n _orb_function_descriptor_ref=_orb_function_descriptor$_orb_variable_suffix
  declare -n _orb_declared_vars_ref=_orb_declared_vars$_orb_variable_suffix
  declare -n _orb_declared_comments_ref=_orb_declared_comments$_orb_variable_suffix
  declare -n _orb_declared_param_suffixes_ref=_orb_declared_param_suffixes$_orb_variable_suffix

  echo -e "$_orb_function_descriptor_ref: received arguments:\n"

  local _orb_msg="$(orb_bold "§Variable:§Value:")\n"

  local _orb_param; for _orb_param in "${_orb_declared_params_ref[@]}"; do
    if _orb_has_declared_value_flag $_orb_param; then
      _orb_print_arg="$_orb_param ${_orb_declared_param_suffixes_ref[$_orb_param]}"
    else
      _orb_print_arg=$_orb_param
    fi

    local _orb_value=(); _orb_get_arg_value $_orb_param _orb_value

    local _orb_var=${_orb_declared_vars_ref[$_orb_param]}
    local _orb_comment="${_orb_declared_comments_ref[$_orb_param]}"
    _orb_msg+="$_orb_print_arg§$_orb_var§${_orb_value[@]}\n"
  done

  echo -e "$_orb_msg" | sed 's/^/  /' | column -t -s '§'
}

