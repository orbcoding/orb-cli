# orb_get_closest_parent
orb_get_closest_parent_orb=(
	"Find closest filename upwards in filsystem"
	Raw: true

	1 = 'filename to orb_get_closest_parent'
	2 = 'starting path'
		Default: '$PWD'
)
function orb_get_closest_parent() {
	local path="${2-$PWD}"

	# Make relative path absolute
	[[ ${path::1} != '/' ]] && path="$PWD/$path"

	while [ "$path" != "/" ] ; do
			if [[ -e "$path/$1" ]]; then
				echo "$path/$1"
				return 0;
			fi
			path=$(dirname "$path")
	done

	return 1;
}

# orb_get_parents
# Needs _orb_prefix because of nameref
orb_get_parents_orb=(
	"Finds all files with filename(s) upwards in file system. Supports file1|file2 (first find) and file1&file2 (any find)"
	Raw: true

	1 = 'array_name'
	2 = 'filename to find'
	3 = 'start path' Default: '$PWD'
	4 = 'last check path' Default: '/'
)
function orb_get_parents() {
	declare -n _orb_assign_ref=$1
	local _orb_filename=$2
	local _orb_p=${3-$PWD}
	local _orb_stop_p=${4-'/'}

	# support multiple filenames separated by & (all matches) or | (first match)
	local _orb_mode="single"   # single, all, first
	local -a _orb_filenames=()

	if [[ "$_orb_filename" == *"&"* ]]; then
		IFS='&' read -r -a _orb_filenames <<< "$_orb_filename"
		_orb_mode="all"
	elif [[ "$_orb_filename" == *"|"* ]]; then
		IFS='|' read -r -a _orb_filenames <<< "$_orb_filename"
		_orb_mode="first"
	else
		_orb_filenames=("$_orb_filename")
	fi

	# Make relative paths absolute
	[[ ${_orb_p:0:1} != '/' ]] && _orb_p="$PWD/$_orb_p"
	[[ ${_orb_stop_p:0:1} != '/' ]] && _orb_stop_p="$PWD/$_orb_stop_p"

	local _orb_fullpath

	while true; do
		# check each candidate name according to mode
		for name in "${_orb_filenames[@]}"; do
			_orb_fullpath="$_orb_p/$name"
			if [[ -e "$_orb_fullpath" ]]; then
				_orb_assign_ref+=( "$_orb_fullpath" )
				if [[ "$_orb_mode" == "first" ]]; then
					break
				fi
			fi
		done

		[[ "$_orb_p" == "$_orb_stop_p" ]] || [[ "$_orb_p" == '/' ]] && break
		_orb_p=$(dirname "$_orb_p")
	done
}

# orb_trim_uniq_realpaths
orb_trim_uniq_realpaths_orb=(
	"Remove any non unique realpaths (symlinked duplicates) from array of paths"
	Raw: true

	1 = _orb_input_array "Input path array name"
	2 = _orb_uniq_array "Array name to store trimmed realpath array version"
)
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

# orb_parse_env
orb_parse_env_orb=(
	"Export variables in .env to shell"
	Raw: true

	1 = 'path to .env'
)
function orb_parse_env() {
	set -o allexport; source "$1"; set +o allexport
}

# orb_has_public_function
orb_has_public_function_orb=(
	"Check if file has public function"
	Raw: true

	1 = "Function name"
	2 = "File"
)
function orb_has_public_function() {
	grep -q "^[); ]*function[ ]$1[ ]*()" "$2"
}

# orb_get_public_functions
# Needs _orb_prefix due to nameref
orb_get_public_functions_orb=(
	"Get list public functions in file"
	Raw: true

	1 = "File"
	2 = "Assign to arr name"
)
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
