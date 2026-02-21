_orb_collect_orb_extensions() { # $1 = start path, $2 = stop path
  # Start collecting in order of priority
  orb_get_parents "_orb_extensions" "_orb&.orb" $1 $2

	if [[ -d "$HOME/.orb" ]] && ! orb_in_arr "$HOME/.orb" _orb_extensions; then 
		_orb_extensions+=( "$HOME/.orb" )
	fi

	orb_trim_uniq_realpaths "_orb_extensions" "_orb_extensions" 
}


_orb_parse_env_extensions() {
  local ext; for ext in "${_orb_extensions[@]}"; do
    if [[ -f "$ext/.env" ]]; then
      orb_parse_env "$ext/.env"
    fi
  done
}

