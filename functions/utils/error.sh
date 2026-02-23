# Public raise error function
orb_raise_error_orb=(
  1 = error_message "Error message"
  -d 1 = descriptor 
    Default: IfPresent: '$_orb_caller_function_descriptor || $_orb_function_descriptor'
  -k = kill_script "Kill script instead of exit, even if subshell"
    Default: true
  -t = trace "show stack trace"
    Default: true
)
function orb_raise_error() {
  source "$_orb_bin"

  _orb_raise_error "$error_message" "$descriptor" $trace $kill_script
}

# Internal raise error function
# Separated to avoid sourcing orb and getting stuck in a loop of bugs
_orb_raise_error() {
  local msg="$1"
  local descriptor="$2"
  
  # Setting descriptor to false will leave it at default
  # So we can go forward to next param without changing value
  [[ $descriptor == false ]] && descriptor=""
  local descriptor; orb_if_present descriptor '$descriptor || $_orb_function_descriptor'

  local print_trace=${3-true}
  local kill_script=${4-false}

  orb_print_error "$msg" "$descriptor"
  $print_trace && orb_print_stack_trace >&2

  orb_kill_script $kill_script
}


# orb_print_error
orb_print_error_orb=(
  Raw: true

  "Print pretty error"

  1 = "Error message"
    Catch: flag block dash
  2 = "Error descriptor"
    Default: IfPresent: '$_orb_function_descriptor_history_0 || $_orb_function_descriptor'
)
function orb_print_error() { # 
  local msg="$1"
  local descriptor="$2"
  orb_if_present descriptor '$descriptor || $_orb_function_descriptor_history_0 || $_orb_function_descriptor'

	error=(
    "${orb_red}${orb_bold}Error:${orb_normal}"
    "$descriptor"
    "$msg"
  )

	echo -e "${error[*]}" >&2
};

# orb_kill_script
# https://stackoverflow.com/a/14152313
function orb_kill_script() { # kill script
  local kill_script=${1-false}

  if [[ $kill_script == true || $ORB_KILL_SCRIPT_ON_ERROR == true ]]; then
    kill -PIPE 0
  else
    exit 1
  fi
}

# orb_print_stack_trace
function orb_print_stack_trace() {
  local _i=0
  local _line_no
  local _orb_function
  local _file_name
  echo
  while caller $_i; do ((_i++)); done | while read _line_no _orb_function _file_name; do
    echo -e "$_file_name:$_line_no\t$_orb_function"
  done

  # echo -e "$output"# | column -t -s '§'
}
