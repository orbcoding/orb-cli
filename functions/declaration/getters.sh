# _orb_ prefix local vars to prevent shadowing
_orb_get_declared_number_params_in_order() {
    local _orb_internal_nrs=()
    declare -n _orb_assign_ref=$1

    local _orb_param; for _orb_param in "${_orb_declared_params[@]}"; do
      orb_is_nr $_orb_param && _orb_internal_nrs+=( $_orb_param )
    done

    IFS=$'\n' _orb_assign_ref=($(sort <<<"${_orb_internal_nrs[*]}")); unset IFS
}

# Resolve incoming runtime key to canonical declared param key.
# Input examples: "+f", "-f", "--file"
# Output examples: "-f" (if aliased), otherwise normalized input key.
_orb_get_declared_param_key() {
  local param=${1/+/-}
  local aliases_name="_orb_declared_param_aliases$_orb_variable_suffix"
  declare -n aliases="$aliases_name"

  if [[ -n ${aliases[$param]} ]]; then
    printf '%s\n' "${aliases[$param]}" # safe output for - prefixed keys
  else
    printf '%s\n' "$param"
  fi
}

_orb_get_param_comment() {
  # Alias-aware lookup: "--file" and "-f" return the same declaration comment.
  local param=$(_orb_get_declared_param_key "$1")
  declare -n declared_comments=_orb_declared_comments$_orb_variable_suffix
  if [[ -n "${declared_comments[$param]}" ]]; then
    echo "${declared_comments[$param]}"
  else
    return 1
  fi
}

# Default options values if not specified
# _orb_ prefix local vars to prevent shadowing
_orb_get_default_param_option_value() {
  # Alias-aware: option defaults are computed on canonical param key.
  local _orb_param=$(_orb_get_declared_param_key "$1")
  local _orb_opt=$2
	declare -n _orb_assign_ref=$3

	case $_orb_opt in
		'Required:')
			_orb_assign_ref=$(orb_is_any_flag $_orb_param || orb_is_block $_orb_param || orb_is_dash $_orb_param && echo false || echo true)
    ;;
    'Default:')
      _orb_has_declared_boolean_flag $_orb_param && _orb_assign_ref=false
    ;;
	esac
}

# As the option declaration may hold nested options, 
# This will give the final computed value with them taken into account
# As we are assigning to variable with uncertain name
# _orb_ prefix all local vars to prevent shadowing
_orb_get_param_option_value() {
  # Alias-aware: option values always come from canonical param declaration entry.
  local _orb_param=$(_orb_get_declared_param_key "$1")
  local _orb_opt=$2
  declare -n _orb_declaration_store=$3

  local _orb_declaration; _orb_get_param_option_declaration $_orb_param $_orb_opt _orb_declaration || return 1
  
  # Has no nested options
  if [[ "$_orb_opt" != Default: ]]; then
    _orb_declaration_store=(${_orb_declaration[@]})
    return
  fi

  # If finding present option with present value or plain default value
  if _orb_get_param_nested_option_declaration Default: IfPresent: _orb_declaration _orb_present_store && \
    orb_if_present _orb_default_value "${_orb_present_store[*]}" || \
    _orb_get_param_nested_option_declaration Default: false _orb_declaration _orb_default_value; then
    _orb_declaration_store=(${_orb_default_value[@]})
    return
  fi

  return 1
}

# If called without assignment param $3 will just check if has value
# _orb_ prefix local vars to prevent shadowing 
_orb_get_param_option_declaration() {
  # Alias-aware index lookup into mixed option-value storage arrays.
  local _orb_param=$(_orb_get_declared_param_key "$1")
  local _orb_opt=$2
  declare -n _orb_option_start_indexes=_orb_declared_option_start_indexes$_orb_variable_suffix

  local _orb_i=$(orb_index_of $_orb_param _orb_declared_params$_orb_variable_suffix)
  local _orb_start_is=(${_orb_option_start_indexes[$_orb_opt]})
  local _orb_start_i="${_orb_start_is[$_orb_i]}"

  # Should always be - if empty but adding -z for sanity when testing
  [[ $_orb_start_i == '-' ]] || [[ -z $_orb_start_i ]] && return 1
  [[ -z $3 ]] && return 0 

  declare -n _orb_option_declaration="$3"
  declare -n _orb_option_lengths=_orb_declared_option_lengths$_orb_variable_suffix
  declare -n _orb_option_values=_orb_declared_option_values$_orb_variable_suffix

  local _orb_lens=(${_orb_option_lengths[$_orb_opt]})
  local _orb_len=${_orb_lens[$_orb_i]}

  _orb_option_declaration=("${_orb_option_values[@]:$_orb_start_i:$_orb_len}")
}

# _orb_ prefix to prevent shadowing
_orb_get_param_nested_option_declaration() {
  local _orb_opt="$1"
  local _orb_nested_opt="$2"
  declare -n _orb_raw_opts="$3"
  declare -n _orb_store_ref="$4"
  local _orb_available_opts=(${_orb_available_param_nested_options[$_orb_opt]})
  local _orb_on_opt=false
  local _orb_tmp_store


  if [[ "$_orb_nested_opt" == false ]]; then
    # get option value without nested options which is defined at the start of the option value
    _orb_on_opt=true
  elif ! orb_in_arr "$_orb_nested_opt" _orb_available_opts; then
    _orb_raise_error "$_orb_nested_opt invalid nested option for $_orb_opt"
  fi

  for _orb_opt in "${_orb_raw_opts[@]}"; do
    if $_orb_on_opt; then
      if ! orb_in_arr "$_orb_opt" _orb_available_opts; then
        _orb_tmp_store+=($_orb_opt)
      else
        break
      fi
    fi

    [[ "$_orb_nested_opt" == false ]] && continue # Until we hit first option or end of loop
    [[ "$_orb_opt" == "$_orb_nested_opt" ]] && _orb_on_opt=true
  done

  if ! $_orb_on_opt; then
    return 1
  elif [[ "${#_orb_tmp_store[@]}" == 0 ]]; then 
    [[ "$_orb_nested_opt" == false ]] && return 1 || _orb_raise_invalid_declaration "$_orb_nested_opt missing value"
  fi

  _orb_store_ref=(${_orb_tmp_store[@]})
}


# _orb_get_function_option_value() {
#   local param=$1
#   local opt=$2
#   declare -n value=$3

#     case $opt in
#       'Raw:')
#         value="$_orb_declared_raw"
#         ;;
#     esac
# }
