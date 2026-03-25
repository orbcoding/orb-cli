# Source file if has public function
local _orb_i=0
local _orb_file; for _orb_file in "${_orb_namespace_files[@]}"; do
  if orb_has_public_function "$_orb_function_name" "$_orb_file"; then
    _orb_script_path="$_orb_file"
    _orb_script_lib="${_orb_namespace_files_orb_dir_tracker[$_orb_i]}"
    _orb_script_file="$(basename $_orb_file)"
    _orb_script_dir="$(dirname "$_orb_file")"
    ! _orb_help_requested && source "$_orb_root/scripts/call/source_presource.sh"
    source "$_orb_file"
    break
  fi
  (( _orb_i++ ))
done

orb_function_declared $_orb_function_name || _orb_raise_error "undefined function: $_orb_function_name"
