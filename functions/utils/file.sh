# orb_trim_uniq_realpaths
# 1 = _orb_input_array "Input path array name"
# 2 = _orb_uniq_array "Array name to store trimmed realpath array version"
function orb_trim_uniq_realpaths() {
	declare -n _orb_i_array=$1
	declare -n _orb_uniq_assign=$2
	local _orb_u_array=()
	local _orb_realpaths=()
	local _orb_realpath

	local _orb_path; for _orb_path in "${_orb_i_array[@]}"; do
		_orb_realpath=$(realpath $_orb_path)

	  if ! orb_in_arr $_orb_realpath _orb_realpaths; then
			_orb_u_array+=($_orb_path)
			_orb_realpaths+=("$_orb_realpath")
		fi
	done

	_orb_uniq_assign=("${_orb_u_array[@]}")
}

# orb_has_public_function
# 1 = "Function name"
# 2 = "File"
function orb_has_public_function() {
	grep -q "^[); ]*function[ ]$1[ ]*()" "$2"
}

# orb_get_public_functions
# Needs _orb_prefix due to nameref
# 1 = "File"
# 2 = "Assign to arr name"
function orb_get_public_functions() {
	local _orb_file=$1
	declare -n _orb_assign_ref=$2

	# Find function line
	# Remove preceeding "); " up to and including function statement
	# Get first word = function_name ignoring whitespace
	# Remove any () from function_name
	_orb_assign_ref=($(\
		grep "^[); ]*function[ ]*[a-zA-Z_-]*[ ]*()" $_orb_file | \
			sed 's/\(); \)*function//' | \
			awk '{print $1;}' | \
			sed 's/()//'\
		 ))
}
