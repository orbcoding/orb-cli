Include functions/argument/validation.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include functions/utils/utils.sh

# _orb_is_valid_arg
Describe '_orb_is_valid_arg'
  _orb_is_valid_in() { echo_fn $@; }
  
  It 'should call _orb_is_valid_in'
    When call _orb_is_valid_arg 1 2
    The output should equal "_orb_is_valid_in 1 2"
  End
End

# _orb_is_valid_in
Describe '_orb_is_valid_in'
  _orb_declared_params=(1)
  declare -a _orb_declared_option_values=(1 2 3 4 5) 

  Context 'with In declaration'
    declare -A _orb_declared_option_start_indexes=([In:]=1)
    declare -A _orb_declared_option_lengths=([In:]=3)    

    It 'succeeds if arg value in In array'
      When call _orb_is_valid_in 1 2
      The status should be success
    End
    
    It 'fails if arg value not in In array'
      When call _orb_is_valid_in 1 1
      The status should be failure
    End
  End

  It 'succeeds if no In declaration'
    declare -A _orb_declared_option_start_indexes=([In:]="-")
    declare -A _orb_declared_option_lengths=([In:]="-")    
    When call _orb_is_valid_in 1 2
    The status should be success
  End
End

# _orb_raise_invalid_arg
Describe '_orb_raise_invalid_arg'
  _orb_raise_error() { echo "$1"; }
  _orb_print_params_explanation() { echo "params"; }

  It 'passes message through and appends params explanation'
    When call _orb_raise_invalid_arg "invalid argument: -e"
		The output should include "invalid argument: -e"
    The output should include "params"
  End

  It 'passes custom argument messages through'
    When call _orb_raise_invalid_arg "unexpected positional argument: asd"
		The output should include "unexpected positional argument: asd"
  End
End
