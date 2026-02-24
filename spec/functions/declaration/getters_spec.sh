Include functions/declaration/getters.sh
Include functions/declaration/checkers.sh
Include functions/utils/param_token.sh
Include functions/utils/utils.sh

# _orb_get_declared_number_params_in_order
Describe '_orb_get_declared_number_params_in_order'
  _orb_declared_params=(4 6 -f 1 5 3 ... 2)
  
  It 'gets declared number args in sorted order'
    When call _orb_get_declared_number_params_in_order _arr
    The variable "_arr[@]" should equal "1 2 3 4 5 6"
  End
End

# _orb_get_param_comment
Describe '_orb_get_param_comment'
  declare -A _orb_declared_param_aliases=()
  declare -A _orb_declared_comments=([1]="first comment" [2]="" [-f]="third comment")
  
  It 'succeeds and outputs comment if has comment'
    When call _orb_get_param_comment 1
    The output should equal "first comment"
  End 
  
  It 'fails if no comment'
    When call _orb_get_param_comment 2
    The status should be failure
  End 
  
  It 'fails if missing'
    When call _orb_get_param_comment -a
    The status should be failure
  End 
End

# # _orb_get_function_option_value
# Describe '_orb_get_function_option_value'
#   It 'stores value to store var'
#     _orb_declared_raw=true
#     When call _orb_get_function_option_value 
#   End
# End

# _orb_get_default_param_option_value
Describe '_orb_get_default_param_option_value'
  declare -A _orb_declared_param_aliases=()
  It 'sets required false for flags'
    When call _orb_get_default_param_option_value -f Required: store_ref
    The variable store_ref should eq false
  End
  
  It 'sets required false for blocks'
    When call _orb_get_default_param_option_value -f- Required: store_ref
    The variable store_ref should eq false
  End

  It 'sets required false for --'
    When call _orb_get_default_param_option_value -- Required: store_ref
    The variable store_ref should eq false
  End

  It 'sets required true for others'
    When call _orb_get_default_param_option_value 1 Required: store_ref
    The variable store_ref should eq true
  End
  
  It 'sets default false for boolean flags'
    _orb_has_declared_boolean_flag() { return 0; }
    When call _orb_get_default_param_option_value -f Default: store_ref
    The variable store_ref should eq false
  End

  It 'does not set default for others'
    _orb_has_declared_boolean_flag() { return 1; }
    When call _orb_get_default_param_option_value -f Default: store_ref
    The status should be failure
    The variable store_ref should be undefined
  End
End

# _orb_get_param_option_value
Describe '_orb_get_param_option_value'
  declare -A _orb_declared_param_aliases=()
  Include scripts/initialize.sh
  _orb_get_param_option_declaration() { return 0; }
  _orb_get_param_nested_option_declaration() { [[ $2 == false ]] && echo 'just_val'; return 0; }
  orb_if_present() { echo checked_present && return 0; }

  It 'gets the arg option'
    When call _orb_get_param_option_value -f Default: store_ref
    The output should eq checked_present
  End

  It 'falls back to base value if no present'
    orb_if_present() { return 1; }
    When call _orb_get_param_option_value -f Default: store_ref
    The output should eq just_val
  End

  It 'fails if not vals found'
    _orb_get_param_nested_option_declaration() { [[ $2 == false ]] && return 1 || return 0; }
    orb_if_present() { return 1; }
    When call _orb_get_param_option_value -f Default: store_ref
    The status should be failure
  End
End


# _orb_get_param_option_declaration
Describe '_orb_get_param_option_declaration'
  declare -A _orb_declared_param_aliases=()
  declare -A _orb_declared_option_start_indexes=([Default:]="0")
  declare -A _orb_declared_option_lengths=([Default:]="2")
  _orb_declared_option_values=(my flag)
  _orb_declared_params=(-f)

  It 'gets the arg option'
    When call _orb_get_param_option_declaration -f Default: store_ref
    The variable "store_ref[@]" should eq "my flag"
  End

  It 'only succeeds if no store_ref'
    When call _orb_get_param_option_declaration -f Default:
    The variable "store_ref[@]" should be undefined
  End
  
  It 'fails if not found'
    When call _orb_get_param_option_declaration -f unknown store_ref
    The variable "store_ref[@]" should be undefined
    The status should be failure
  End
End

# _orb_get_param_nested_option_declaration
Describe '_orb_get_param_nested_option_declaration'
  Include scripts/initialize_variables.sh
  opts=(default value IfPresent: present value Help: "help" value)

  It 'gets nested option inside'
    opts=(default value IfPresent: present value Help: "help" value)

    When call _orb_get_param_nested_option_declaration Default: IfPresent: opts store_ref
    The variable "store_ref[@]" should eq "present value"
  End
  
  It 'gets nested option at beginning'
    opts=(IfPresent: present value Help: "help" value)

    When call _orb_get_param_nested_option_declaration Default: IfPresent: opts store_ref
    The variable "store_ref[@]" should eq "present value"
  End
  
  It 'gets nested option at end'
    opts=(default value IfPresent: present value Help: "help" value)

    When call _orb_get_param_nested_option_declaration Default: Help: opts store_ref
    The variable "store_ref[@]" should eq "help value"
  End
  
  It 'gets value without options if internal_opt false'
    opts=(default value IfPresent: present value Help: "help" value)

    When call _orb_get_param_nested_option_declaration Default: false opts store_ref
    The variable "store_ref[@]" should eq "default value"
  End
  
  It 'raises if option without value at end'
    _orb_raise_invalid_declaration() { echo "$@"; exit 1; }
    opts=(default value IfPresent: present value Help:)

    When run _orb_get_param_nested_option_declaration Default: Help: opts store_ref
    The status should be failure
    The output should eq "Help: missing value"
  End
  
  It 'raises if option without value inside'
    _orb_raise_invalid_declaration() { echo "$@"; exit 1; }
    opts=(default value IfPresent: Help:)

    When run _orb_get_param_nested_option_declaration Default: IfPresent: opts store_ref
    The status should be failure
    The output should eq "IfPresent: missing value"
  End
  
  It 'raises if internal_opt not valid'
    _orb_raise_error() { echo "$@"; exit 1; }
    opts=(default value IfPresent: Help:)

    When run _orb_get_param_nested_option_declaration Default: unknown opts store_ref
    The status should be failure
    The output should eq "unknown invalid nested option for Default:"
  End
End
