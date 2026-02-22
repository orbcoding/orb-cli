Include functions/declaration/validation.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include scripts/call/variables.sh
Include scripts/initialize_variables.sh
Include functions/utils/argument.sh
Include functions/utils/utils.sh
Include functions/call/help.sh

# _orb_prevalidate_declaration
Describe '_orb_prevalidate_declaration'
  raise_invalid_declaration() { echo "$@"; }

  declaration=(= value)

  It 'raises invalid declaration if starts with ='
    When call _orb_prevalidate_declaration
    The output should equal "Cannot start with ="
  End
End

# _orb_raise_invalid_declaration
Describe '_orb_raise_invalid_declaration'
  _orb_raise_error() { echo "$@"; }

  It 'calls raise error with invalid declaration error'
    When call _orb_raise_invalid_declaration "error message"
    The output should equal "Invalid declaration. error message"
  End
End

# _orb_raise_undeclared
Describe '_orb_raise_undeclared'
  _orb_raise_error() { echo "$@"; }
  _orb_print_args_explanation() { echo_fn; }

  It 'calls raise error with undeclared error'
    _orb_function_descriptor_with_suffix=spec_descriptor 
    _orb_variable_suffix=_with_suffix

    When call _orb_raise_undeclared "1"
    The output should equal "'1' not in spec_descriptor args declaration\n\n_orb_print_args_explanation"
  End
End


Describe '_orb_validate_declared_args'
  _orb_raise_invalid_declaration() { echo "$1" && exit 1; }

  It 'raises error on multiple definitions of same argument'
    _orb_declared_args=(1 2 3 4 5 5)

    When run _orb_validate_declared_args
    The status should be failure
    The output should eq "5: multiple definitions"
  End
  
  It 'raises error on multiple definitions at beginning'
    _orb_declared_args=(1 1 2 3 4 5)

    When run _orb_validate_declared_args
    The status should be failure
    The output should eq "1: multiple definitions"
  End
  
  It 'raises error on multiple definitions with others between'
    _orb_declared_args=(1 2 3 1 4 5)

    When run _orb_validate_declared_args
    The status should be failure
    The output should eq "1: multiple definitions"
  End

  It 'does not raise error if unique arg definitions'
    _orb_declared_args=(1 2 3 4 5)

    When call _orb_validate_declared_args
    The status should be success
  End
End

Describe '_orb_validate_declared_arg_alias_token_types'
  _orb_raise_invalid_declaration() { echo "$1" && exit 1; }

  It 'fails when alias token contains non-flag alias part'
    declaration=(-f\|1 = file)
    When run _orb_validate_declared_arg_alias_token_types
    The status should be failure
    The output should eq "-f|1: invalid alias declaration"
  End

  It 'succeeds for valid alias flag token'
    declaration=(-f\|--file = file)
    When call _orb_validate_declared_arg_alias_token_types
    The status should be success
  End
End

# _orb_postvalidate_declared_args_options
Describe '_orb_postvalidate_declared_args_options'
  It 'calls _orb_postvalidate_declared_args_options_catchs'
    _orb_postvalidate_declared_args_options_catchs() { spec_args+=($(echo_fn)); }
    _orb_postvalidate_declared_args_options_requireds() { spec_args+=($(echo_fn)); }
    _orb_postvalidate_declared_args_options_multiples() { spec_args+=($(echo_fn)); }
    # _orb_postvalidate_declared_args_incompatible_options() { spec_args+=$(echo_fn); }
    
    When call _orb_postvalidate_declared_args_options
    The status should be success
    The variable "spec_args[@]" should equal "_orb_postvalidate_declared_args_options_catchs _orb_postvalidate_declared_args_options_requireds _orb_postvalidate_declared_args_options_multiples"
  End
End


# _orb_postvalidate_declared_args_options_catchs
Describe '_orb_postvalidate_declared_args_options_catchs'
  _orb_declared_args=(-f)
  _orb_declared_option_values=(1 flag block dash 2)
  declare -A _orb_declared_option_start_indexes=([Catch:]=1)
  declare -A _orb_declared_option_lengths=([Catch:]=3)

  It 'succeeds on valid catch values'
    When call _orb_postvalidate_declared_args_options_catchs
    The status should be success
  End

  It 'fails on invalid catch values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    declare -A _orb_declared_option_start_indexes=([Catch:]=0)
    When run _orb_postvalidate_declared_args_options_catchs
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: Invalid Catch: value: 1. Available values: any flag block dash"
  End
End

# _orb_postvalidate_declared_args_options_requireds
Describe '_orb_postvalidate_declared_args_options_requireds'
  _orb_declared_args=(-f)
  _orb_declared_option_values=(true) 
  declare -A _orb_declared_option_start_indexes=([Required:]=0)
  declare -A _orb_declared_option_lengths=([Required:]=1)

  It 'succeeds on valid required values'
    When call _orb_postvalidate_declared_args_options_requireds
    The status should be success
  End

  It 'fails on invalid required values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    _orb_declared_option_values=(unknown)
    When run _orb_postvalidate_declared_args_options_requireds
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: Invalid Required: value: unknown. Available values: true false"
  End
End

# _orb_postvalidate_declared_args_options_multiples
Describe '_orb_postvalidate_declared_args_options_multiples'
  _orb_declared_args=(-f)
  _orb_declared_option_values=(true) 
  declare -A _orb_declared_option_start_indexes=([Multiple:]=0)
  declare -A _orb_declared_option_lengths=([Multiple:]=1)

  It 'succeeds on valid multiple values'
    When call _orb_postvalidate_declared_args_options_multiples
    The status should be success
  End

  It 'fails on invalid multiple values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    _orb_declared_option_values=(unknown) 
    When run _orb_postvalidate_declared_args_options_multiples
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: Invalid Multiple: value: unknown. Available values: true false"
  End
End

# _orb_postvalidate_declared_args_incompatible_options
# Describe '_orb_postvalidate_declared_args_incompatible_options'
#   _orb_declared_args=(-f)
#   _orb_declared_option_values=(def defhelp)
#   declare -A _orb_declared_option_start_indexes=([Default:]=0 [DefaultHelp:]="-")
#   declare -A _orb_declared_option_lengths=([Default:]=1 [DefaultHelp:]="-")

#   It 'succeeds on valid multiple values'
#     When call _orb_postvalidate_declared_args_incompatible_options
#     The status should be success
#   End

#   It 'fails on invalid multiple values'
#     _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
#     _orb_declared_option_start_indexes[DefaultHelp:]=1
#     _orb_declared_option_lengths[DefaultHelp:]=1

#     When run _orb_postvalidate_declared_args_incompatible_options
#     The status should be failure
#     The output should equal "_orb_raise_invalid_declaration -f: Incompatible options: Default:, DefaultHelp:"
#   End
# End

# _orb_is_valid_arg_option
Describe '_orb_is_valid_arg_option'
  _orb_raise_invalid_declaration() { echo "$@"; return 1; }
  declare -A _orb_declared_arg_suffixes

  Context 'with number args'
    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option 1 Default:
      The status should be success
    End

    It 'fails for Multiple:'
      When call _orb_is_valid_arg_option 1 Multiple: true
      The status should be failure
      The output should equal "1: Invalid option: Multiple:. Available options for number args: Required: Default: In:"
    End
  End

  Context 'with boolean flags'
    _orb_declared_args=(-f)

    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option -f Default:
      The status should be success
    End

    It 'fails for Multiple:'
      When call _orb_is_valid_arg_option -f Multiple: true
      The status should be failure
      The output should equal "-f: Invalid option: Multiple:. Available options for boolean flags: Required: Default:"
    End
  End

  Context 'with flag args'
    _orb_declared_args=(-f)
    declare -A _orb_declared_arg_suffixes=([-f]=1)

    It 'succeeds for In:'
      When call _orb_is_valid_arg_option -f In:
      The status should be success
    End

    It 'fails for Catch:'
      When call _orb_is_valid_arg_option -f Catch: true
      The status should be failure
      The output should equal "-f: Invalid option: Catch:. Available options for flag args: Required: Default: Multiple: In:"
    End
  End

  Context 'with array flag args'
    declare -A _orb_declared_arg_suffixes=([-f]=2)

    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option -f Required:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_arg_option -f In: true
      The status should be failure
      The output should equal "-f: Invalid option: In:. Available options for flag array args: Required: Default: Multiple:"
    End
  End

  Context 'with block'
    It 'succeeds for Multiple:'
      When call _orb_is_valid_arg_option -f- Multiple:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_arg_option -f- In: true
      The status should be failure
      The output should equal "-f-: Invalid option: In:. Available options for blocks: Required: Default: Multiple:"
    End
  End

  Context 'with dash'
    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option -- Required:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_arg_option -- In: true
      The status should be failure
      The output should equal "--: Invalid option: In:. Available options for --: Required: Default:"
    End
  End

  Context 'with rest'
    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option ... Required:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_arg_option ... In: true
      The status should be failure
      The output should equal "...: Invalid option: In:. Available options for ...: Required: Default: Catch:"
    End
  End
End
