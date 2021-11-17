# _raise_error
declare -A _raise_error_args=(
  ['1']='error_message;'
  ['-d arg']='descriptor; DEFAULT: $_orb_caller_function_descriptor|$_orb_function_descriptor;'
  ['-k']='kill script instead of exit; DEFAULT: true'
  ['-t']='trace; DEFAULT: true'
); function _raise_error() { # raise pretty error msg and kills execution
  source orb

  local _cmd=()
  _args_to -a _cmd _print_error -- -d 1 # not using -x as would change caller_info
  "${_cmd[@]}"
  ${_args[-t]} && _print_stack_trace >&2
  if ${_args[-k]}; then 
    _kill_script 
  else
    exit 1
  fi
}


# _print_error
declare -A _print_error_args=(
	['1']='message; CATCH_ANY;'
  ['-d arg']='descriptor; DEFAULT: $_orb_caller_function_descriptor|$_orb_function_descriptor'
); function _print_error() { # print pretty error
  source orb

	msg=(
    "$(_red)$(_bold)Error:$(_normal)"
    "${_args[-d arg]}"
    "${_args[1]}"
  )

	echo -e "${msg[*]}" >&2
};

# _kill_script
# https://stackoverflow.com/a/14152313
function _kill_script() { # kill script
  kill -PIPE 0
}

# _print_stack_trace
function _print_stack_trace() {
  local _i=0
  local _line_no
  local _orb_function
  local _file_name
  echo
  while caller $_i; do ((_i++)); done | while read _line_no _orb_function _file_name; do
    echo -e "$_file_name:$_line_no\t$_orb_function"
  done
}