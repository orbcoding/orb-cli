_orb_collect_orb_libraries() { # $1 = start path, $2 = stop path
  if [[ -n "$ORB_LIBRARIES" ]]; then
    local -a env_libraries
    local IFS=':'
    read -r -a env_libraries <<< "$ORB_LIBRARIES"

    local lib
    for lib in "${env_libraries[@]}"; do
      [[ -n "$lib" ]] && _orb_libraries+=( "$lib" )
    done
  fi

	orb_trim_uniq_realpaths "_orb_libraries" "_orb_libraries"
}
