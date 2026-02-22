_orb_collect_orb_libraries() { # $1 = start path, $2 = stop path
  # Start collecting in order of priority
  orb_get_parents "_orb_libraries" "_orb&.orb" $1 $2

	if [[ -d "$HOME/.orb" ]] && ! orb_in_arr "$HOME/.orb" _orb_libraries; then 
		_orb_libraries+=( "$HOME/.orb" )
	fi

	orb_trim_uniq_realpaths "_orb_libraries" "_orb_libraries" 
}


_orb_parse_libraries_dotenv() {
  local lib; for lib in "${_orb_libraries[@]}"; do
    if [[ -f "$lib/.env" ]]; then
      orb_parse_env "$lib/.env"
    fi
  done
}

