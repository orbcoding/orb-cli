# Source namespace _presource.sh in reverse (closest last)
local _i; for (( _i=${#_orb_extensions[@]}-1 ; _i>=0 ; _i-- )); do
  local _ext="${_orb_extensions[$_i]}"
  if [[ -f "$_ext/namespaces/$_orb_namespace_path/.presource.sh" ]]; then
    source "$_ext/namespaces/$_orb_namespace_path/.presource.sh"
  fi
done
