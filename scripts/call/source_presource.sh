# Source namespace _presource.sh in reverse (closest last)
local _i; for (( _i=${#_orb_libraries[@]}-1 ; _i>=0 ; _i-- )); do
  local _lib="${_orb_libraries[$_i]}"
  if [[ -f "$_lib/namespaces/$_orb_namespace_path/.presource.sh" ]]; then
    source "$_lib/namespaces/$_orb_namespace_path/.presource.sh"
  fi
done
