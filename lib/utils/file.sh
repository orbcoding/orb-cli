# orb_upfind_closest
declare -A orb_upfind_closest_args=(
	['1']='filename to orb_upfind_closest'
	['2']='starting path; DEFAULT: $PWD'
); function orb_upfind_closest() { # Find closest filename upwards in filsystem
	local _p="${2-$PWD}" _sep _options

	[[ ${_p[1]} != '/' ]] && _p="$(pwd)/$_p"

	while [ "$_p" != "/" ] ; do
			if [[ -e "$_p/$1" ]]; then
				echo "$_p/$1"
				return 0;
			fi
			_p=`dirname "$_p"`
	done

	return 1;
}

# orb_upfind_to_arr
declare -A orb_upfind_to_arr_args=(
	['1']='array name'
	['2']='filename(s) multiple files sep with & (and) or | (or)'
	['3']='start path; DEFAULT: $PWD'
	['4']='last check path; DEFAULT: /'
); function orb_upfind_to_arr() { # finds all files with filename(s) upwards in file system
	local _p="${3-$PWD}"
	local _s="${4-/}"

	[[ ${_p:0:1} != '/' ]] && _p="$(pwd)/$_p"
	[[ ${_s:0:1} != '/' ]] && _s="$(pwd)/$_s"

	declare -n _arr=$1
	[[ -n "$2" ]] && local _path="$2"

	local _sep='&'; [[ $2 == *"|"* ]] && _sep='|'

	local _options; IFS="$_sep" read -r -a _options <<< $2 # split by sep
	local _option

	while true; do
		local _found=false

		for _option in "${_options[@]}"; do
			if [[ -e "$_p/$_option" ]]; then
				[[ $_sep == '|' ]] && $_found && break
				_arr+=( "$_p/$_option" )
			fi
		done

		[ "$_p" == "$_s" ] || [ "$_p" == '/' ] && break
		_p=$(dirname "$_p")
	done
}

# parsenv
declare -A orb_parse_env_args=(
	['1']='path to .env'
); function orb_parse_env() { # export variables in .env to shell
	set -o allexport; source "$1"; set +o allexport
}

# has_public_function $1 function, $2 file
declare -A orb_has_public_function_args=(
	['1']='function_name'
	['2']='file'
); function orb_has_public_function() { # check if file has function
	grep -q "^[); ]*function[ ]*$1[ ]*()[ ]*{" "$2"
}