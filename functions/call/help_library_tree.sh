_orb_print_library_tree() {
  # TODO library tree
  local msg=()

  local lib; for lib in "${_orb_libraries[@]}"; do
    msg+=("$lib\n")

    local namespaces_dir="$lib/namespaces"
    if [[ -d "$namespaces_dir" ]]; then
      local namespaces
      readarray -d '' namespaces < <(find $namespaces_dir -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

      local ns; for ns in "${namespaces[@]}"; do
        msg+=("  $(basename "$ns")\n")
      done
    fi
   done

  echo -e "${msg[@]}"
}
