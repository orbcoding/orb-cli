# orb_function_declared
orb_function_declared_orb=(
	"Check if a function name has been declared"
	Raw: true

	1 = "Function name"
)
function orb_function_declared() {
	declare -f -F $1 > /dev/null
}

function orb_index_of() {
	local _orb_arr_value="$1"
	declare -n _orb_arr_ref="$2"

	local _orb_i; for _orb_i in "${!_orb_arr_ref[@]}"; do
		if [[ "${_orb_arr_ref[$_orb_i]}" == "$_orb_arr_value" ]]; then
			echo "$_orb_i" && return
		fi
	done

	echo "-1"
	return 1
}

function orb_in_arr() {
	local _orb_arr_value="$1"
	local _orb_arr_name="$2"

	orb_index_of "$_orb_arr_value" "$_orb_arr_name" > /dev/null
}


# To be evaled
_orb_copy_variable() {
	local _orb_var=$1
	local _orb_name=$2
	local _orb_global=${3-false}

	local _orb_declare_statement; _orb_declare_statement=($(declare -p "$_orb_var" 2>/dev/null)) || return 1
	local _orb_opening=(${_orb_declare_statement[@]:0:2}) # declare -a
	$_orb_global && _orb_opening=(${_orb_opening[0]} -g ${_orb_opening[1]})
	local _orb_assignment=${_orb_declare_statement[@]:2} # var=....
	_orb_assignment="${_orb_name}${_orb_assignment/$_orb_var/}" # name=...

	local to_eval=("${_orb_opening[@]} ${_orb_assignment[@]}")

	echo "${to_eval[@]}"
}

orb_variable_or_string_value_orb=(
	'Evaluates $variable or string'

	1 = "store variable name"
	2 = '$variable/string name'
)
function orb_variable_or_string_value() {
	declare -n _orb_store_ref=$1

	if [[ ${2:0:1} == '$' ]]; then # is variable
	 	declare -n _orb_var_ref=${2:1}

		if [[ -n "${_orb_var_ref[@]}" ]]; then
			_orb_store_ref=("${_orb_var_ref[@]}") # store as array
		else
			return 1
		fi
	elif [[ -n ${2+x} ]]; then # is string
		_orb_store_ref="$2"
	else
		return 1
	fi

	return 0
}

# orb_if_present
orb_if_present_orb=(
	"Store first present value in a chain of variables or strings separated by ||"

	1 = "store variable name"
	2 = '$option1 || $option2 || fallback_str'
); 
function orb_if_present() {
	local _orb_store=$1
	local _orb_raw_options=($2)
	local _orb_options=()

	local i=0
	local _orb_current_opt=()

	local _orb_opt; for _orb_opt in "${_orb_raw_options[@]}"; do
		if [[ "$_orb_opt" == '||' ]]; then
			_orb_options+=("${_orb_current_opt[*]}")
			_orb_current_opt=()
		else
			_orb_current_opt+=($_orb_opt)
		fi	
		
		if [[ $i == $(( ${#_orb_raw_options[@]} - 1)) ]]; then
			_orb_options+=("${_orb_current_opt[*]}")
		fi

		((i++))
	done
	

	local _orb_option; for _orb_option in "${_orb_options[@]}"; do
		orb_variable_or_string_value $_orb_store "$_orb_option" && return 0
	done

	return 1
}



# # orb_grep_between
# orb_grep_between=(
# 	1 = 'string to grep'
# 	2 = 'grep between from'
# 	3 = 'grep between to'
# ); function orb_grep_between() { # grep between two strings, can use (either|or)
# 	grep -oP "(?<=$2).*?(?=$3)" <<< $1
# }

# # verify empty or unset?
# declare -A orb_is_empty_arr_args=(
# 	['1']='arr_name'
# ); function orb_is_empty_arr() {
# 	[[ ! -v "$1[@]" ]]
# }


# declare -A orb_remove_prefix_args=(
# 	['1']='prefix to remove'
# 	['2']='string to remove from'
# ); function orb_remove_prefix() {
# 	if [[ ${2:0:${#1}} == $1 ]]; then # is variable
# 		echo ${2:${#1}}
# 	else
# 		echo $2
# 		return 1
# 	fi
# }

# # orb_join_by
# declare -A orb_join_by_args=(
# 	['1']='delimiter'
# 	['*']='to join'
# ); function orb_join_by() { # join array by separator
# 	local _d=$1; shift; local _f=$1; shift; printf %s "$_f" "${@/#/$_d}";
# }

# # orb_variable_or_string_value
# orb_variable_or_string_value_orb=(
# 	1 = '$variable/string'
# )
