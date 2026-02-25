Include functions/argument/store.sh
Include functions/argument/collection.sh
Include functions/argument/assignment.sh
Include functions/argument/validation.sh
Include scripts/call/variables.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include functions/argument/getters.sh
Include functions/utils/param_token.sh
Include functions/utils/utils.sh

declare flag
declare dash
declare -A _orb_declared_vars=(
  [1]=one 
  [-f]=flag 
  [--]=dash 
  [-b-]=block 
  [...]=rest
)
_orb_declared_params=(1 -f -- -b- ...)

# _orb_store_arg_value
Describe '_orb_store_arg_value'
  It 'should store to arg values arrs'
    _orb_store_arg_value -- some values come before
    When call _orb_store_arg_value -f "some values after"
    _orb_assign_stored_arg_values_to_declared_variables 
    The variable "_orb_args_values[@]" should equal "some values come before some values after"
    The variable "_orb_args_values_start_indexes[--]" should equal 0
    The variable "_orb_args_values_lengths[--]" should equal 4
    The variable "_orb_args_values_start_indexes[-f]" should equal 4
    The variable "_orb_args_values_lengths[-f]" should equal 1
    The variable "dash[@]" should equal "some values come before"
    The variable flag should equal "some values after"
  End

  It 'should handle Multiple'
    declare -a _orb_declared_option_values=(true) 
    declare -A _orb_declared_option_start_indexes=([Multiple:]="- 0 - - -")
    declare -A _orb_declared_option_lengths=([Multiple:]="- 1 - - -")
    _orb_store_arg_value -f "first value"
    When call _orb_store_arg_value -f "second value"
    _orb_assign_stored_arg_values_to_declared_variables
    The variable "_orb_args_values_start_indexes[-f]" should equal "0 1"
    The variable "_orb_args_values_lengths[-f]" should equal "1 1"
    The variable "flag[@]" should equal "first value second value"
  End
End



# _orb_store_boolean_flag
Describe '_orb_store_boolean_flag'
  It 'should call nested functions'
    _orb_store_arg_value() { spec_fns+=($(echo_fn $@)); }
    _orb_shift_args() { spec_fns+=($(echo_fn $@)); }
    When call _orb_store_boolean_flag -f
    The variable "spec_fns[@]" should equal "_orb_store_arg_value -f true _orb_shift_args 1"
  End

  It 'should store true for - prefix'
    When call _orb_store_boolean_flag -f
    _orb_assign_stored_arg_values_to_declared_variables
    The variable flag should equal true
  End

  It 'takes shift step override'
    _orb_shift_args() { spec_fns+=$(echo_fn $@); }
    When call _orb_store_boolean_flag -f 0
    The variable "spec_fns[@]" should equal "_orb_shift_args 0"
  End

  It 'stores verbose alias on canonical key'
    declare -A _orb_declared_param_aliases=([--flag]=-f [-f]=-f)
    When call _orb_store_boolean_flag --flag
    _orb_assign_stored_arg_values_to_declared_variables
    The variable flag should equal true
  End
End

Describe '_orb_flag_value'
	It 'returns true if starts with -'
    When call _orb_flag_value -f
    The output should equal true
  End

	It 'returns false if does not start with -'
    When call _orb_flag_value +f
    The output should equal false
  End
End


# _orb_store_value_flag
Describe '_orb_store_value_flag'
  args_remaining=(-f followed by args)
  declare -A _orb_declared_param_suffixes=([-f]=3)

  _orb_store_arg_value() { spec_args+=($(echo_fn $@)); }
  _orb_raise_invalid_arg() { spec_args+=($(echo_fn $@)); }
  _orb_shift_args() { spec_args+=($(echo_fn $@)); }

	It 'returns true if starts with -'
    When call _orb_store_value_flag -f
    The variable "spec_args[@]" should equal "_orb_store_arg_value -f followed by args _orb_shift_args 4"
  End

  It 'takes shift step override'
    When call _orb_store_value_flag -f 0
    The variable "spec_args[@]" should equal "_orb_store_arg_value -f followed by args _orb_shift_args 0"
  End
End

# _orb_store_block
Describe '_orb_store_block'
  args_remaining=(-b- followed by args -b-)

	It 'stores when end block exists'
    _orb_store_arg_value() { spec_args+=($(echo_fn $@)); }
    When call _orb_store_block -b-
    The variable "spec_args[@]" should equal "_orb_store_arg_value -b- followed by args"
  End
 
	It 'stores to values arr'
    When call _orb_store_block -b-
    _orb_assign_stored_arg_values_to_declared_variables
    The variable "block[@]" should equal "followed by args"
  End

  It 'raises error if end block missing'
    _orb_raise_error() { spec_args+=($(echo_fn $@)); return 1; }
    args_remaining=(-b- followed by args)
    When call _orb_store_block -b-
    The status should be failure
    The variable "spec_args[@]" should equal "_orb_raise_error missing block end: '-b-'"
  End
End

# _orb_store_inline_arg
Describe '_orb_store_inline_arg'
  args_count=1

  It 'calls nested functions with correct args'
    _orb_store_arg_value() { spec_args+=($(echo_fn $@)); }
    _orb_shift_args() { spec_args+=($(echo_fn $@)); }
    When call _orb_store_inline_arg val
    The variable "spec_args[@]" should equal "_orb_store_arg_value 1 val _orb_shift_args"
  End
End

# _orb_store_dash
Describe '_orb_store_dash'
  args_remaining=(-- args remaining)

  It 'calls nested functions with correct args'
    args_remaining=(-- args remaining)
    _orb_store_arg_value() { spec_args+=($(echo_fn $@)); }
    When call _orb_store_dash
    The variable "spec_args[@]" should equal "_orb_store_arg_value -- args remaining"
  End

  It 'stores to values arr and empties remaining args'
    When call _orb_store_dash
    _orb_assign_stored_arg_values_to_declared_variables    
    The variable "dash[@]" should equal "args remaining"
    The variable "args_remaining[@]" should be undefined
  End
End

# _orb_store_rest
Describe '_orb_store_rest'
  args_remaining=(rest of args)

  It 'calls nested functions with correct args'
    _orb_store_arg_value() { spec_args+=($(echo_fn $@)); }
    _orb_shift_args() { spec_args+=($(echo_fn $@)); }
    _orb_store_dash() { spec_args+=($(echo_fn $@)); }
    When call _orb_store_rest
    The variable "spec_args[@]" should equal "_orb_store_arg_value ... rest of args"
  End

  It 'stores to values arr and empties remaining args'
    When call _orb_store_rest
    _orb_assign_stored_arg_values_to_declared_variables
    The variable "rest[@]" should equal "rest of args"
    The variable "dash[@]" should be undefined
    The variable "args_remaining[@]" should be undefined
  End

  Context 'with dash args included'
    args_remaining=(rest of args -- dash args)

    It 'calls nested functions with correct args'
      args_remaining=(rest of args -- dash args)
      _orb_store_arg_value() { spec_args+=($(echo_fn $@)); }
      _orb_shift_args() { spec_args+=($(echo_fn $@)); }
      _orb_store_dash() { spec_args+=($(echo_fn $@)); }
      When call _orb_store_rest
      The variable "spec_args[@]" should equal "_orb_shift_args 3 _orb_store_dash _orb_store_arg_value ... rest of args"
    End

    It 'stores to value arr and empties remaining args'
      When call _orb_store_rest
      _orb_assign_stored_arg_values_to_declared_variables
      The variable "rest[@]" should equal "rest of args"
      The variable "dash[@]" should equal "dash args"
      The variable "args_remaining[@]" should be undefined
    End
  End
End

# _orb_shift_args
Describe '_orb_shift_args'
  args_remaining=(some args remaining)

  It 'shifts args in args remaining array'
    When call _orb_shift_args
    The variable "args_remaining[@]" should equal "args remaining"
  End

  It 'handles multiple steps'
    When call _orb_shift_args 2
    The variable "args_remaining[@]" should equal "remaining"
  End
End
