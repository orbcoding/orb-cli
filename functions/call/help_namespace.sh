# Namespace help functions
_orb_print_namespace_help() {
	local i=0 file current_dir output

	local file; for file in "${_orb_namespace_files[@]}"; do
		local dir="${_orb_namespace_files_orb_dir_tracker[$i]}"

		if [[ "$dir" != "$current_dir" ]]; then
			current_dir="$dir"
			output+="-----------------  $current_dir\n"
		fi

		output+="$(basename "$file")\n"
		source "$file"
		local fns; orb_get_public_functions "$file" fns

		local fn; for fn in "${fns[@]}"; do
			declare -A _orb_declared_comments=()
			_orb_parse_function_declaration "${fn}_orb" false
			output+="  $fn§"
			output+="${_orb_declared_comments[function]}\n"
		done

		((i++))

		output+='§\n'
	done

	# remove last newline chars §\n
	echo -e "${output::-3}" | column -tes '§'

	echo -e "\nTo show information about a function, use \`orb --help \"namespace\" \"function\"\`"
}
