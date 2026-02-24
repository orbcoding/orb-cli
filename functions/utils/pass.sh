# orb_pass

# As we are passing args to array with uncertain name
# All variables have to be _orb_ prefixed to prevent shadowing
#
orb_pass_orb=(
  "Pass commands to array eg: cmd=(my_cmd); orb_pass md_cmd -- -fa 1 2 --"

  -a 1 = _orb_arr_name "Array name where args are appended"
  -v = _orb_only_val "Only pass values: ignore flag before value flag, block marks and --"
  -x = _orb_execute "exec array after adding args to -a arg array"
  -h = _orb_history_index "which caller history index to pass from"
    Default: 0
  ... = _orb_arr_els "array/cmd elements"
    Required: false
    Catch: any
  -- = _orb_pass 
)
function orb_pass() {
  source "$_orb_bin"

  # This will redirect any argument/declaration queries to check our caller history data
  local _orb_variable_suffix=_history_$_orb_history_index

  if [[ -n $_orb_arr_name ]]; then
    declare -n _orb_arr=$_orb_arr_name
    [[ -n "${_orb_arr_els[*]}" ]] && _orb_arr+=("${_orb_arr_els[@]}")
  elif [[ -n "${_orb_arr_els[*]}" ]]; then
    # rests to be executed
    declare -n _orb_arr=_orb_arr_els
  else
    _orb_raise_error '-a or ... required'
  fi

  [[ -z $_orb_function_name_history_0 ]] && _orb_raise_error 'no parent orb function to pass args from'
  [[ -z "${_orb_declared_params_history_0[*]}" ]] && _orb_raise_error "$_orb_function_descriptor_history_0 has no arguments to pass"

  local _orb_arg; for _orb_arg in "${_orb_pass[@]}"; do
    if orb_is_input_flag "$_orb_arg"; then
      _orb_pass_flag "$_orb_arg"
    elif orb_is_block "$_orb_arg"; then
      _orb_pass_block "$_orb_arg"
    elif orb_is_nr "$_orb_arg"; then
      _orb_pass_nr "$_orb_arg"
    elif orb_is_rest $_orb_arg; then
      _orb_pass_rest
    elif orb_is_dash $_orb_arg; then
      _orb_pass_dash
    else
      _orb_raise_error "Invalid argument: $_orb_arg. Not flag, block, nr, ... or --"
    fi
  done

  if [[ -n "$_orb_arr_name" ]]; then
    # With -a arg -x has to be explicitly added to exec
    $_orb_execute && "${_orb_arr[@]}"
  else
    # Without -a arg always exec
    "${_orb_arr[@]}"
  fi

  return 0
}

_orb_pass_flag() { # $1 = flag arg/args
  local _orb_flag_arg=$1
  local _orb_flags=()

  if [[ "$_orb_flag_arg" == --* ]] || [[ "$_orb_flag_arg" == "+-"* ]]; then
    _orb_flags+=( "$_orb_flag_arg" )
  else
    # Split any combined flags eg -far into -f -a -r
    _orb_flags+=( $(echo "${_orb_flag_arg:1}" | grep -o . | sed  s/^/-/g) )
  fi

  local _orb_flag; for _orb_flag in ${_orb_flags[@]}; do
    if _orb_has_declared_boolean_flag "$_orb_flag"; then
      # Only pass if true
      _orb_pass_arg $_orb_flag "" "" true
    elif _orb_has_declared_value_flag "$_orb_flag"; then
      # Add flag prefix unless only val
      $_orb_only_val && _orb_pass_arg $_orb_flag || _orb_pass_arg $_orb_flag $_orb_flag 
    fi
  done
}

# TODO continue
_orb_pass_block() {
  $_orb_only_val && _orb_pass_arg $1 || _orb_pass_arg $1 $1 $1
}

_orb_pass_nr() {
  _orb_pass_arg $1
}

_orb_pass_rest() {
  _orb_pass_arg ...
}

_orb_pass_dash() {
  $_orb_only_val && _orb_pass_arg -- || _orb_pass_arg -- --
}

_orb_pass_arg() {
  local _orb_arg=$1
  local _orb_prefix=$2
  local _orb_suffix=$3
  local _orb_pass_self_if_eq="$4"

  _orb_has_declared_param "$_orb_arg" || _orb_raise_undeclared "$_orb_arg"
  _orb_has_arg_value $_orb_arg || return 1
  local _orb_value; _orb_get_arg_value $_orb_arg _orb_value

  if [[ -n "$_orb_pass_self_if_eq" ]]; then 
    [[ "${_orb_value[*]}" != "$_orb_pass_self_if_eq" ]] && return 1 
    _orb_value=("$_orb_arg")
  fi

  [[ -n $_orb_prefix ]] && _orb_arr+=( $_orb_prefix )
  _orb_arr+=("${_orb_value[@]}")
  [[ -n $_orb_suffix ]] && _orb_arr+=( $_orb_suffix )
  
  return 0
}
