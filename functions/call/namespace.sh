# Return success => shift away namespace argument from positional args
_orb_get_current_namespace() {
	if [[ $_orb_sourced != true ]]; then
		_orb_get_current_namespace_from_args "$@"
		return $?
	else
		_orb_get_current_namespace_from_file_structure
		return 2 # no shift
	fi
}

_orb_get_current_namespace_from_args() {
  _orb_namespace_path=
	_orb_namespace_chain_name=
  _orb_namespace_chain=()
	_orb_collect_available_namespaces # Seed top-level _orb_namespaces

  local args=( "$@" )
	local ns="${args[0]}"
	local ns_i=0

	if [[ -n "$ns" ]] && orb_in_arr "$ns" _orb_namespaces; then
		while [[ -n "$ns" ]] && orb_in_arr "$ns" _orb_namespaces; do
			_orb_namespace_name="$ns"
			_orb_namespace_chain+=( "$ns" )

			if [[ -z "$_orb_namespace_path" ]]; then
				_orb_namespace_path="$ns"
			else
				_orb_namespace_path+="/namespaces/$ns"
			fi

			(( ns_i++ ))
			_orb_collect_available_namespaces "$_orb_namespace_path"
			ns="${args[$ns_i]}"
		done

		_orb_set_namespace_chain_name_from_chain
	elif ! $_orb_setting_help; then
		if [[ -n $ORB_DEFAULT_NAMESPACE ]]; then
			_orb_namespace_name="$ORB_DEFAULT_NAMESPACE"
			_orb_namespace_path="$ORB_DEFAULT_NAMESPACE"
			_orb_namespace_chain=( "$ORB_DEFAULT_NAMESPACE" )
			_orb_set_namespace_chain_name_from_chain
			return 2
		else
			local error="not a valid namespace and \$ORB_DEFAULT_NAMESPACE not set. \n\n"
			error+="$(_orb_print_available_namespaces)"
			_orb_raise_error "$error" "$(orb_bold "${1-\"\"}")" false
		fi
	fi
}

_orb_collect_available_namespaces() {
	# Optional path for nested lookup.
	# Empty => collect top-level namespaces from "$ext/namespaces".
	# Set (e.g. "a" or "a/namespaces/b") => collect only direct children
	# under that branch, used while resolving nested namespace args.
	local namespace_path="$1"
	_orb_namespaces=()

  local ext; for ext in "${_orb_extensions[@]}"; do
		local namespaces_dir="$ext/namespaces"
		[[ -n "$namespace_path" ]] && namespaces_dir+="/$namespace_path/namespaces"

		[ -d "$namespaces_dir" ] || continue

		local file; for file in "$namespaces_dir"/*; do
			[ -e "$file" ] || continue # handle no match without shopt -s nullglob

			local namespace=$(basename "$file")
			[[ "$namespace" == .* ]] && continue # skip hidden files
			namespace="${namespace/\.*/}" # rm extension

      if ! orb_in_arr $namespace _orb_namespaces; then
        _orb_namespaces+=( $namespace )
      fi
    done
  done
}

_orb_print_available_namespaces() {
	local msg=()
	msg+=("$(orb_bold 'Available namespaces:')\n")

	local ns; for ns in "${_orb_namespaces[@]}"; do
		msg+=("  $ns\n")
	done

	echo "${msg[@]}"
}

_orb_collect_namespace_files() {
	[[ -z "$_orb_namespace_path" ]] && return

 	local ext; for ext in "${_orb_extensions[@]}"; do
		local dir="$ext/namespaces/$_orb_namespace_path"

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

_orb_get_current_namespace_from_file_structure() {
  local ns_file="$(_orb_get_current_sourcer_file_path)"
  local ns_file_dir="$(dirname $ns_file)"
  
  if [[ "$(basename "$ns_file_dir")" != namespaces ]]; then
    ns_file="$ns_file_dir"
    ns_file_dir="$(dirname "$ns_file_dir")"
  fi

  if [[ "$(basename "$ns_file_dir")" == namespaces ]]; then
		_orb_namespace_path="${ns_file#*namespaces/}"
		_orb_namespace_path="${_orb_namespace_path%.*}"
		_orb_set_namespace_chain_from_path
		_orb_set_namespace_chain_name_from_chain
		local last_i=$(( ${#_orb_namespace_chain[@]} - 1 ))
		_orb_namespace_name="${_orb_namespace_chain[$last_i]}"
		orb_is_valid_variable_name $_orb_namespace_name || _orb_raise_error "not a valid namespace name"
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

_orb_set_namespace_chain_from_path() {
	local chain_raw="${_orb_namespace_path//\/namespaces\// }"
	read -r -a _orb_namespace_chain <<< "$chain_raw"
}

_orb_set_namespace_chain_name_from_chain() {
	_orb_namespace_chain_name="${_orb_namespace_chain[*]}"
}

_orb_get_namespace_shift_steps() {
	echo "${#_orb_namespace_chain[@]}"
}

_orb_validate_current_namespace() {
	[[ -n $_orb_namespace_name ]] && ! orb_is_valid_variable_name $_orb_namespace_name && _orb_raise_error "not a valid namespace name"
	return 0
}
