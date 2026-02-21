_orb_collect_namespaces() {
  local ext; for ext in "${_orb_extensions[@]}"; do
		[ -d "$ext/namespaces" ] || continue

    local file; for file in $(ls "$ext/namespaces"); do
      local namespace=$(basename $file)
			namespace="${namespace/\.*/}"

      if ! orb_in_arr $namespace _orb_namespaces; then
        _orb_namespaces+=( $namespace )
      fi
    done
  done
}

_orb_collect_namespace_files() {
 	local ext; for ext in "${_orb_extensions[@]}"; do
		local dir="$ext/namespaces/$_orb_namespace"

		if [[ -d "$dir" ]]; then
	 		local files
			readarray -d '' files < <(find $dir -maxdepth 1 -type f -name "*.sh" ! -name '.*' -print0 | sort -z)

			local from=${#_orb_namespace_files[@]}
			local to=$(( $from + ${#files[@]} - 1 ))

			local i; for i in $(seq $from $to ); do
				_orb_namespace_files_orb_dir_tracker[$i]="$ext"
			done

			_orb_namespace_files+=( "${files[@]}" )

		elif [[ -f "${dir}.sh" ]]; then
			_orb_namespace_files_orb_dir_tracker[${#_orb_namespace_files[@]}]="$ext"
			_orb_namespace_files+=( "${dir}.sh" )
		fi
	done
}

# Return success => shift away namespace argument from positional args
_orb_get_current_namespace() {
	if [[ $_orb_sourced == true ]]; then
		_orb_get_current_namespace_from_file_structure
		return 2 # no shift
	else
		_orb_get_current_namespace_from_args "$@"
		return $?
	fi
}

_orb_get_current_namespace_from_args() {
  local ns="$1"

	if [[ -n "$ns" ]] && orb_in_arr "$ns" _orb_namespaces; then
		_orb_namespace="$ns"
	elif ! $_orb_setting_help; then
		if [[ -n $ORB_DEFAULT_NAMESPACE ]]; then
			_orb_namespace="$ORB_DEFAULT_NAMESPACE"
			return 2
		else
			local error="not a valid namespace and \$ORB_DEFAULT_NAMESPACE not set. \n\n"
			error+="$(_orb_print_available_namespaces)"
			_orb_raise_error "$error" "$(orb_bold "${1-\"\"}")" false
		fi
	fi
}

_orb_print_available_namespaces() {
	local msg=()
	msg+=("$(orb_bold 'Available namespaces:')\n")

	local ns; for ns in "${_orb_namespaces[@]}"; do
		msg+=("  $ns\n")
	done

	echo "${msg[@]}"
}

_orb_get_current_namespace_from_file_structure() {
  local ns_file="$(_orb_get_current_sourcer_file_path)"
  local ns_file_dir="$(dirname $ns_file)"
  
  if [[ "$(basename "$ns_file_dir")" != namespaces ]]; then
    ns_file="$ns_file_dir"
    ns_file_dir="$(dirname "$ns_file_dir")"
  fi

  if [[ "$(basename "$ns_file_dir")" == namespaces ]]; then
    _orb_namespace="$(basename "${ns_file%.*}")"
		orb_is_valid_variable_name $_orb_namespace || _orb_raise_error "not a valid namespace name"
	else
		return 1
  fi
}

_orb_get_current_sourcer_file_path() {
	local i=0
	local file; for file in "${_orb_source_trace[@]}"; do
		if [[ "$file" == "$_orb_root/bin/orb" ]]; then
			echo "${_orb_source_trace[$i+1]}" 
			return
		fi
		(( i++ ))
	done
}

_orb_validate_current_namespace() {
	[[ -n $_orb_namespace ]] && ! orb_is_valid_variable_name $_orb_namespace && _orb_raise_error "not a valid namespace name"
	return 0
}
