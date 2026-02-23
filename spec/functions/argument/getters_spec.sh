Include functions/argument/getters.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include functions/utils/argument.sh
Include functions/utils/utils.sh
Include scripts/call/variables.sh

# _orb_get_arg_value
Describe '_orb_get_arg_value'
  declare -A _orb_args_values_start_indexes=([1]=0 [...]=5 [-m]=7 [-f]=9 )
  declare -A _orb_args_values_lengths=([1]=5 [...]=2 [-m]=2 [-f]=2)
  _orb_args_values=(1 2 3 4 5 1 2 6 7 9 0)

  _orb_declared_params=(1 ... -m -f)
  _orb_declared_option_values=(true)
  declare -A _orb_declared_option_start_indexes=([Multiple:]="- - 0 -")
  declare -A _orb_declared_option_lengths=([Multiple:]="- - 1 -")
  values=()
  
  It 'adds arg values to ref'
    When call _orb_get_arg_value 1 values
    The variable "values[@]" should equal "1 2 3 4 5"
  End 

  It 'stores as array for array args'
    When call _orb_get_arg_value ... values
    The variable "values[0]" should equal "1"
  End 

  It 'stores as array for multiple args'
    When call _orb_get_arg_value -m values
    The variable "values[0]" should equal "6"
    The variable "values[1]" should equal "7"
  End

  It 'stores as string for non multiple'
    When call _orb_get_arg_value -f values
    The variable "values[0]" should equal "9 0"
    The variable "values[1]" should be undefined
  End 

  It 'stores as string for non array args'
    When call _orb_get_arg_value 1 values
    The variable "values[0]" should equal "1 2 3 4 5"
  End 
End

Describe '_orb_has_arg_value'
  It 'succeeds when has start index'
    declare -A _orb_args_values_start_indexes=([1]=0)
    When call _orb_has_arg_value 1
    The status should be success
  End

  It 'fails when does not have start index'
    When call _orb_has_arg_value 1
    The status should be failure
  End
End
