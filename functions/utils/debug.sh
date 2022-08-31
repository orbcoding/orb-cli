# orb_ee
declare -A orb_ee_args=(
  ['*']='msg; CATCH_ANY'
); function orb_ee() { # echo to stderr, useful for debugging without polluting stdout
  echo "$@" >&2
}

# orb_print_args
function orb_print_args() { # print collected arguments, useful for debugging
  source orb

	declare -A | grep 'A _orb_caller_args=' | cut -d '=' -f2-

  local _orb_blocks=( $(_orb_has_declared_args _orb_caller_args_declaration) )
  local _orb_block; for _orb_block in "${_orb_blocks[@]}"; do
    declare -n ref="$(_orb_block_to_arr_name "$_orb_block")"
    if [[ ${_orb_caller_args["$_orb_block"]} == true ]]; then
      echo "[$_orb_block]=${ref[*]}"
    fi
  done
  
  # | cut -d '=' -f2-
	if [[ ${_orb_caller_args["*"]} == true || ${_orb_caller_args["-- *"]} == true ]]; then
    echo "[*]=${_orb_caller_rest[*]}"
    echo "[-- *]=${_orb_caller_dash_rest[*]}"
  fi
}
