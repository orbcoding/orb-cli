# ------------------------------
# Function Help Functions
# ------------------------------
_orb_print_function_help() {
  local output=$(_orb_build_function_help_output)
  [[ -n "$output" ]] && echo -e "$output"
  return 0
}

_orb_build_function_help_output() {
  local name_section=$(_orb_build_help_name_section)
  local synopsis_section=$(_orb_build_help_synopsis_section)
  local description_section=$(_orb_build_help_description_section)
  local parameters_section=$(_orb_print_params_explanation)

  local output="$name_section\n\n$synopsis_section"
  [[ -n "$description_section" ]] && output+="\n\n$description_section"
  [[ -n "$parameters_section" ]] && output+="\n\n$parameters_section"

  echo -e "$output"
}

# ------------------------------
# CLI Descriptor & Headers
# ------------------------------
_orb_help_get_cli_descriptor() {
  local descriptor="${_orb_function_descriptor// -> / }"
  echo "orb $descriptor"
}

_orb_help_format_header() {
  printf '%s%s%s%s' "$ORB_BOLD" "$ORB_BLUE" "$1" "$ORB_NORMAL"
}

_orb_help_get_title() {
  declare -n comments=_orb_declared_comments$_orb_variable_suffix
  local title="${comments[function]}"
  [[ -z "$title" ]] && return 1
  title="${title%%$'\n'*}"
  title="${title%%.}"
  echo "$title"
}

_orb_build_help_name_section() {
  local cli_descriptor=$(_orb_help_get_cli_descriptor)
  local title=$(_orb_help_get_title)
  local header=$(_orb_help_format_header 'NAME')

  if [[ -n "$title" ]]; then
    echo -e "$header\n    $cli_descriptor - $title"
  else
    echo -e "$header\n    $cli_descriptor"
  fi
}

# ------------------------------
# Parameter Helpers
# ------------------------------
_orb_help_get_param_primary_token() {
  local param="$1"
  printf '%s\n' "$param"
}

_orb_help_get_param_placeholder() {
  local param="$1"
  declare -n declared_vars=_orb_declared_vars$_orb_variable_suffix
  declare -n declared_suffixes=_orb_declared_param_suffixes$_orb_variable_suffix
  local value_name="${declared_vars[$param]}"

  local suffix_count="${declared_suffixes[$param]}"
  if [[ "$suffix_count" =~ ^[0-9]+$ ]] && (( suffix_count > 1 )); then
    printf '<%s>{%s}\n' "$value_name" "$suffix_count"
  else
    printf '<%s>\n' "$value_name"
  fi
}

_orb_help_get_param_required() {
  local param="$1"
  local required=false
  if _orb_get_param_option_value "$param" Required: required && [[ "$required" == true ]]; then
    echo true
  else
    echo false
  fi
}

_orb_help_append_param_by_required() {
  local param="$1"
  declare -n required_ref="$2"
  declare -n optional_ref="$3"
  if [[ "$(_orb_help_get_param_required "$param")" == true ]]; then
    required_ref+=("$param")
  else
    optional_ref+=("$param")
  fi
}

_orb_help_get_ordered_params() {
  declare -n out_ref="$1"
  declare -n declared_params=_orb_declared_params$_orb_variable_suffix

  local positional_required=()
  local positional_optional=()
  local boolean_required=()
  local boolean_optional=()
  local value_required=()
  local value_optional=()
  local block_required=()
  local block_optional=()
  local dash_required=()
  local dash_optional=()
  local rest_required=()
  local rest_optional=()

  local param
  for param in "${declared_params[@]}"; do
    if orb_is_nr "$param"; then
      _orb_help_append_param_by_required "$param" positional_required positional_optional
    elif _orb_has_declared_boolean_flag "$param"; then
      _orb_help_append_param_by_required "$param" boolean_required boolean_optional
    elif _orb_has_declared_value_flag "$param" || _orb_has_declared_array_flag_param "$param"; then
      _orb_help_append_param_by_required "$param" value_required value_optional
    elif orb_is_block "$param"; then
      _orb_help_append_param_by_required "$param" block_required block_optional
    elif orb_is_dash "$param"; then
      _orb_help_append_param_by_required "$param" dash_required dash_optional
    elif orb_is_rest "$param"; then
      _orb_help_append_param_by_required "$param" rest_required rest_optional
    fi
  done

  out_ref=(
    "${positional_required[@]}" "${positional_optional[@]}"
    "${boolean_required[@]}" "${boolean_optional[@]}"
    "${value_required[@]}" "${value_optional[@]}"
    "${block_required[@]}" "${block_optional[@]}"
    "${rest_required[@]}" "${rest_optional[@]}"
    "${dash_required[@]}" "${dash_optional[@]}"
  )
}

_orb_help_get_positional_name() {
  local param="$1"
  declare -n declared_vars=_orb_declared_vars$_orb_variable_suffix
  local positional_name="${declared_vars[$param]:-$param}"
  echo "$positional_name"
}

_orb_help_get_synopsis_segment_for_param() {
  local param="$1"
  local token=$(_orb_help_get_param_primary_token "$param")
  local required=$(_orb_help_get_param_required "$param")
  local segment=''
  local block_multiple=false

  if _orb_has_declared_boolean_flag "$param"; then
    segment="$token"
  elif _orb_has_declared_value_flag "$param"; then
    local placeholder=$(_orb_help_get_param_placeholder "$param")
    local multiple=false
    _orb_get_param_option_value "$param" Multiple: multiple >/dev/null 2>&1 || true
    if [[ "$multiple" == true ]]; then
      segment="$token ${placeholder}..."
    else
      segment="$token $placeholder"
    fi
  elif orb_is_dash "$param"; then
    segment="-- $(_orb_help_get_param_placeholder "$param")"
  elif orb_is_rest "$param"; then
    segment="[args...]"
  elif orb_is_block "$param"; then
    local placeholder=$(_orb_help_get_param_placeholder "$param")
    segment="$token ${placeholder}... $token"
    _orb_get_param_option_value "$param" Multiple: block_multiple >/dev/null 2>&1 || true
  else
    segment="$(_orb_help_get_positional_name "$param")"
  fi

  if orb_is_block "$param" && [[ "$block_multiple" == true ]]; then
    if [[ "$required" == true ]]; then
      printf '%s...\n' "$segment"
    else
      printf '[%s]...\n' "$segment"
    fi
    return
  fi

  if [[ "$required" == true ]]; then
    printf '%s\n' "$segment"
  else
    if [[ "$segment" == "[args...]" ]]; then
      printf '%s\n' "$segment"
    else
      printf '[%s]\n' "$segment"
    fi
  fi
}

# ------------------------------
# Synopsis & Description
# ------------------------------
_orb_build_help_synopsis_section() {
  local cli_descriptor=$(_orb_help_get_cli_descriptor)
  local header=$(_orb_help_format_header 'SYNOPSIS')
  local ordered_params=()
  _orb_help_get_ordered_params ordered_params

  local required_boolean_group=''
  local optional_boolean_group=''
  declare -A grouped_boolean_params=()
  local emitted_boolean_groups=false

  local param
  for param in "${ordered_params[@]}"; do
    if _orb_has_declared_boolean_flag "$param" && [[ "$param" =~ ^-[[:alnum:]]$ ]]; then
      local required=$(_orb_help_get_param_required "$param")
      local letter="${param:1:1}"
      if [[ "$required" == true ]]; then
        required_boolean_group+="$letter"
      else
        optional_boolean_group+="$letter"
      fi
      grouped_boolean_params[$param]=true
    fi
  done

  local synopsis_parts=()
  for param in "${ordered_params[@]}"; do
    if [[ -n "${grouped_boolean_params[$param]}" ]]; then
      if ! $emitted_boolean_groups; then
        [[ -n "$required_boolean_group" ]] && synopsis_parts+=("-$required_boolean_group")
        [[ -n "$optional_boolean_group" ]] && synopsis_parts+=("[-$optional_boolean_group]")
        emitted_boolean_groups=true
      fi
      continue
    fi
    synopsis_parts+=("$(_orb_help_get_synopsis_segment_for_param "$param")")
  done

  local synopsis_line="$cli_descriptor"
  if [[ ${#synopsis_parts[@]} -gt 0 ]]; then
    synopsis_line+=" ${synopsis_parts[*]}"
  fi

  echo -e "$header\n    $synopsis_line"
}

_orb_build_help_description_section() {
  declare -n comments=_orb_declared_comments$_orb_variable_suffix
  local description="${comments[description]}"
  [[ -z "$description" ]] && return 1

  local terminal_width=$(_orb_help_get_terminal_width)
  local description_width=$((terminal_width - 8))
  (( description_width < 20 )) && description_width=20
  local wrapped
  _orb_wrap_help_text "$description" "$description_width" wrapped

  local body=''
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "$body" ]] && body+=$'\n'
    body+="    $line"
  done <<< "$wrapped"

  local header=$(_orb_help_format_header 'DESCRIPTION')
  echo -e "$header\n$body"
}

_orb_print_orb_function_and_comment() {
  _orb_build_help_name_section
}

# ------------------------------
# Text Wrapping
# ------------------------------
_orb_wrap_help_text() {
  local text="$1"
  local max_width=$2
  declare -n out_ref=$3

  if [[ -z "$text" ]] || [[ $max_width -le 0 ]]; then
    out_ref="$text"
    return
  fi

  out_ref=""
  local first_output_line=true
  local input_line
  while IFS= read -r input_line || [[ -n "$input_line" ]]; do
    if [[ -z "$input_line" ]]; then
      if ! $first_output_line; then
        out_ref+=$'\n'
      fi
      first_output_line=false
      continue
    fi

    local words=()
    read -r -a words <<< "$input_line"

    if (( ${#words[@]} == 0 )); then
      if ! $first_output_line; then
        out_ref+=$'\n'
      fi
      first_output_line=false
      continue
    fi

    local line=""
    local word
    for word in "${words[@]}"; do
      if [[ -z "$line" ]]; then
        line="$word"
      elif (( ${#line} + 1 + ${#word} <= max_width )); then
        line+=" $word"
      else
        if ! $first_output_line; then
          out_ref+=$'\n'
        fi
        out_ref+="$line"
        first_output_line=false
        line="$word"
      fi
    done

    if [[ -n "$line" ]]; then
      if ! $first_output_line; then
        out_ref+=$'\n'
      fi
      out_ref+="$line"
      first_output_line=false
    fi
  done <<< "$text"
}

# ------------------------------
# Parameter Display Helpers
# ------------------------------
_orb_print_wrapped_help_field() {
  local label="$1"
  local value="$2"
  local value_width=$3
  local label_width=$4
  local field_indent="${5:-        }"

  [[ -z "$label_width" ]] && label_width=${#label}
  local prefix_plain
  printf -v prefix_plain "${field_indent}%-${label_width}s  " "$label"
  local prefix="$prefix_plain"
  local label_colored="${ORB_BOLD}${ORB_BLUE}${label}${ORB_NORMAL}"
  [[ -z "$ORB_BLUE" ]] && label_colored="$label"
  prefix="${prefix/$label/$label_colored}"

  local continuation_prefix
  printf -v continuation_prefix "%*s" "${#prefix_plain}" ""

  local wrapped_value
  _orb_wrap_help_text "$value" "$value_width" wrapped_value
  local value_colored_prefix="${ORB_BOLD}${ORB_BLUE}"
  local value_colored_suffix="$ORB_NORMAL"
  [[ -z "$ORB_BLUE" ]] && value_colored_prefix="" && value_colored_suffix=""

  if [[ -z "$wrapped_value" ]]; then
    printf '%s\n' "$prefix"
    return
  fi

  local first_line=true
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    if $first_line; then
      printf '%s%s%s%s\n' "$prefix" "$value_colored_prefix" "$line" "$value_colored_suffix"
      first_line=false
    else
      printf '%s%s%s%s\n' "$continuation_prefix" "$value_colored_prefix" "$line" "$value_colored_suffix"
    fi
  done <<< "$wrapped_value"
}

_orb_print_wrapped_help_description() {
  local value="$1"
  local value_width=$2
  local field_indent="${3:-        }"

  local wrapped_value
  _orb_wrap_help_text "$value" "$value_width" wrapped_value

  if [[ -z "$wrapped_value" ]]; then
    printf '%s\n' "$field_indent"
    return
  fi

  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    printf '%s%s\n' "$field_indent" "$line"
  done <<< "$wrapped_value"
}

# ------------------------------
# Terminal Width
# ------------------------------
_orb_help_get_terminal_width() {
  local terminal_width=80
  if [[ "$COLUMNS" =~ ^[0-9]+$ ]] && (( COLUMNS > 0 )); then
    terminal_width=$COLUMNS
  elif command -v tput >/dev/null 2>&1; then
    local tput_cols
    tput_cols=$(tput cols 2>/dev/null)
    if [[ "$tput_cols" =~ ^[0-9]+$ ]] && (( tput_cols > 0 )); then
      terminal_width=$tput_cols
    fi
  fi
  echo "$terminal_width"
}

# ------------------------------
# Param Info Helpers
# ------------------------------
_orb_help_get_param_token_for_help() {
  local param="$1"
  declare -n declared_display_tokens=_orb_declared_param_display_tokens$_orb_variable_suffix
  declare -n declared_vars=_orb_declared_vars$_orb_variable_suffix
  declare -n declared_suffixes=_orb_declared_param_suffixes$_orb_variable_suffix
  local raw_token="${declared_display_tokens[$param]:-$param}"
  local token="$raw_token"

  if orb_is_nr "$param"; then
    token="$(_orb_help_get_positional_name "$param")"
  fi

  if [[ "$raw_token" == *"|"* ]]; then
    local token_parts=()
    IFS='|' read -r -a token_parts <<< "$raw_token"
    local normalized_parts=()
    local token_part
    for token_part in "${token_parts[@]}"; do
      normalized_parts+=("$token_part")
    done
    token="${normalized_parts[0]}"
    local alias_part
    for alias_part in "${normalized_parts[@]:1}"; do
      token+=", $alias_part"
    done
  fi

  if _orb_has_declared_value_flag "$param"; then
    local value_name="${declared_vars[$param]}"
    [[ -z "$value_name" ]] && value_name='value'
    if [[ "$value_name" == *s ]] && [[ ${#value_name} -gt 1 ]]; then
      value_name="${value_name%s}"
    fi
    local value_count="${declared_suffixes[$param]}"
    if [[ "$value_count" =~ ^[0-9]+$ ]] && (( value_count > 1 )); then
      token+=" <${value_name}>{${value_count}}"
    else
      token+=" <${value_name}>"
    fi
  elif orb_is_block "$param"; then
    token="$token $(_orb_help_get_param_placeholder "$param") $param"
  fi

  echo "$token"
}

_orb_help_get_colored_param_token() {
  local token="$1"
  local placeholder_pattern='^<[^>]+>(\{[0-9]+\})?$'

  if [[ -z "$ORB_BLUE" ]]; then
    printf '%s\n' "$token"
    return
  fi

  local color_prefix="${ORB_BOLD}${ORB_BLUE}"
  local out=''
  local part
  for part in $token; do
    local rendered="$part"
    if [[ "$part" =~ $placeholder_pattern ]]; then
      rendered="${ORB_NORMAL}${part}${color_prefix}"
    fi
    [[ -n "$out" ]] && out+=" "
    out+="$rendered"
  done

  printf '%s%s%s\n' "$color_prefix" "$out" "$ORB_NORMAL"
}

_orb_help_get_param_description() {
  local param="$1"
  declare -n declared_vars=_orb_declared_vars$_orb_variable_suffix
  declare -n declared_comments=_orb_declared_comments$_orb_variable_suffix
  local description="${declared_comments[$param]}"
  if [[ -z "$description" ]] && ! _orb_has_declared_value_flag "$param" && ! orb_is_block "$param"; then
    description="${declared_vars[$param]}"
  fi
  echo "$description"
}

_orb_help_get_param_default_details() {
  local param="$1"
  declare -n default_value_ref="$2"
  declare -n default_resolve_ref="$3"

  default_value_ref=''
  default_resolve_ref=''

  local default=()
  if _orb_get_param_option_value "$param" Default: default && [[ -n "${default[*]}" ]]; then
    local cleaned_default=()
    local default_part
    for default_part in "${default[@]}"; do
      case "$default_part" in
        Required:|Default:|In:|Multiple:|Catch:)
          break
          ;;
      esac
      cleaned_default+=("$default_part")
    done
    default=("${cleaned_default[@]}")

    if ! (_orb_has_declared_boolean_flag "$param" && [[ "${default[*]}" == false ]]); then
      default_value_ref="${default[*]}"
    fi
  fi

  local default_decl=()
  if _orb_get_param_option_declaration "$param" Default: default_decl; then
    local resolve_values=()
    if _orb_get_param_nested_option_declaration Default: IfPresent: default_decl resolve_values; then
      default_resolve_ref="${resolve_values[*]}"
      [[ "$default_resolve_ref" == "'"*"'" ]] && default_resolve_ref="${default_resolve_ref:1:${#default_resolve_ref}-2}"
      [[ "$default_resolve_ref" == '"'*'"' ]] && default_resolve_ref="${default_resolve_ref:1:${#default_resolve_ref}-2}"
    fi
  fi
}

_orb_help_get_param_in_value() {
  local param="$1"
  local in_value=''
  local in_values=()
  if _orb_get_param_option_value "$param" In: in_values; then
    local cleaned_in_values=()
    local in_part
    for in_part in "${in_values[@]}"; do
      case "$in_part" in
        Required:|Default:|In:|Multiple:|Catch:)
          break
          ;;
        or|'|')
          continue
          ;;
        '')
          continue
          ;;
        *)
          cleaned_in_values+=("$in_part")
          ;;
      esac
    done

    if (( ${#cleaned_in_values[@]} > 0 )); then
      local in_i
      for in_i in "${!cleaned_in_values[@]}"; do
        (( in_i > 0 )) && in_value+=" | "
        in_value+="${cleaned_in_values[$in_i]}"
      done
    fi
  fi
  echo "$in_value"
}

_orb_help_get_option_label_width() {
  local required="$1"
  local default_value="$2"
  local in_value="$3"
  local multiple="$4"
  local option_label_width=0
  [[ -n "$required" ]] && (( option_label_width < 9 )) && option_label_width=9
  [[ -n "$default_value" ]] && (( option_label_width < 8 )) && option_label_width=8
  [[ -n "$in_value" ]] && (( option_label_width < 3 )) && option_label_width=3
  [[ -n "$multiple" ]] && (( option_label_width < 9 )) && option_label_width=9
  echo "$option_label_width"
}

_orb_help_print_param_options() {
  local required="$1"
  local default_value="$2"
  local default_resolve="$3"
  local in_value="$4"
  local multiple="$5"
  local terminal_width=$6
  local max_value_width=$7
  local value_width=$8
  local option_label_width=$9

  [[ -n "$required" ]] && _orb_print_wrapped_help_field 'Required:' "$required" "$value_width" "$option_label_width" "        "
  [[ -n "$default_value" ]] && _orb_print_wrapped_help_field 'Default:' "$default_value" "$value_width" "$option_label_width" "        "
  [[ -n "$default_resolve" ]] && _orb_print_wrapped_help_field 'Resolve:' "$default_resolve" "$value_width" "$option_label_width" "        "
  [[ -n "$in_value" ]] && _orb_print_wrapped_help_field 'In:' "$in_value" "$value_width" "$option_label_width" "        "
  [[ -n "$multiple" ]] && _orb_print_wrapped_help_field 'Multiple:' "$multiple" "$value_width" "$option_label_width" "        "
}

# ------------------------------
# Print Parameters Explanation
# ------------------------------
_orb_print_params_explanation() {
  declare -n declared_params=_orb_declared_params$_orb_variable_suffix
  [[ ${#declared_params[@]} == 0 ]] && return 1

  local terminal_width=$(_orb_help_get_terminal_width)
  local label_width=12
  local field_prefix_len=$((6 + label_width + 2))
  local value_width=$((terminal_width - field_prefix_len))
  local description_width=$((terminal_width - 8))
  (( description_width < 20 )) && description_width=20
  (( value_width < 20 )) && value_width=20
  local max_value_width=56
  if [[ "$ORB_HELP_DESC_WIDTH" =~ ^[0-9]+$ ]] && (( ORB_HELP_DESC_WIDTH > 0 )); then
    max_value_width=$ORB_HELP_DESC_WIDTH
    (( description_width > ORB_HELP_DESC_WIDTH )) && description_width=$ORB_HELP_DESC_WIDTH
  fi
  (( value_width > max_value_width )) && value_width=$max_value_width

  printf '%s%sPARAMETERS%s\n' "$ORB_BOLD" "$ORB_BLUE" "$ORB_NORMAL"

  local ordered_params=()
  _orb_help_get_ordered_params ordered_params
  local param_i
  for param_i in "${!ordered_params[@]}"; do
    local param="${ordered_params[$param_i]}"
    local token=$(_orb_help_get_param_token_for_help "$param")
    local description=$(_orb_help_get_param_description "$param")

    local required=''
    local required_flag=false
    if _orb_get_param_option_value "$param" Required: required_flag && [[ "$required_flag" == true ]]; then
      required='yes'
    fi

    local multiple=''
    local multiple_flag=false
    if _orb_get_param_option_value "$param" Multiple: multiple_flag && [[ "$multiple_flag" == true ]]; then
      multiple='yes'
    fi

    local default_value=''
    local default_resolve=''
    _orb_help_get_param_default_details "$param" default_value default_resolve
    local in_value=$(_orb_help_get_param_in_value "$param")
    local option_label_width=$(_orb_help_get_option_label_width "$required" "$default_value" "$in_value" "$multiple")

    local colored_token=$(_orb_help_get_colored_param_token "$token")
    printf '    %s\n' "$colored_token"
    [[ -n "$description" ]] && _orb_print_wrapped_help_description "$description" "$description_width"

    (( option_label_width > 0 )) && _orb_help_print_param_options "$required" "$default_value" "$default_resolve" "$in_value" "$multiple" "$terminal_width" "$max_value_width" "$value_width" "$option_label_width"

    (( param_i < ${#ordered_params[@]} - 1 )) && printf '\n'
  done
}
