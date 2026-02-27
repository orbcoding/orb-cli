Include functions/declaration/validation.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include scripts/call/variables.sh
Include scripts/initialize_variables.sh
Include functions/utils/param_token.sh
Include functions/utils/utils.sh

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
    The output should equal "declaration: error message"
  End
End

# _orb_raise_undeclared
Describe '_orb_raise_undeclared'
  _orb_raise_error() { echo "$@"; }
  _orb_print_params_explanation() { echo_fn; }

  It 'calls raise error with undeclared error'
    _orb_function_descriptor_with_suffix=spec_descriptor 
    _orb_variable_suffix=_with_suffix

    When call _orb_raise_undeclared "1"
    The output should equal "'1' not in spec_descriptor params declaration\n\n_orb_print_params_explanation"
  End
End

Describe '_orb_validate_declared_param_assignment'
  _orb_raise_invalid_declaration() { echo "$1" && exit 1; }

  It 'fails for invalid alias token'
    _orb_declared_raw=false
    When run _orb_validate_declared_param_assignment '-f|1' '-f' file true
    The status should be failure
    The output should eq "invalid alias declaration: -f|1"
  End

  It 'fails for invalid param assignment context'
    _orb_declared_raw=false
    When run _orb_validate_declared_param_assignment note note comment true
    The status should be failure
    The output should eq "invalid parameter assignment: note = comment"
  End

  It 'fails for invalid variable when not raw'
    _orb_declared_raw=false
    When run _orb_validate_declared_param_assignment -f -f "invalid name" false
    The status should be failure
    The output should eq "invalid variable name: 'invalid name'"
  End
End

# _orb_postvalidate_declared_params_options
Describe '_orb_postvalidate_declared_params_options'
  It 'calls _orb_postvalidate_declared_params_options_catchs'
    _orb_postvalidate_declared_params_options_catchs() { spec_args+=($(echo_fn)); }
    _orb_postvalidate_declared_params_options_requireds() { spec_args+=($(echo_fn)); }
    _orb_postvalidate_declared_params_options_multiples() { spec_args+=($(echo_fn)); }
    _orb_postvalidate_declared_params_incompatible_options() { spec_args+=($(echo_fn)); }
    
    When call _orb_postvalidate_declared_params_options
    The status should be success
    The variable "spec_args[@]" should equal "_orb_postvalidate_declared_params_options_catchs _orb_postvalidate_declared_params_options_requireds _orb_postvalidate_declared_params_options_multiples _orb_postvalidate_declared_params_incompatible_options"
  End
End


# _orb_postvalidate_declared_params_options_catchs
Describe '_orb_postvalidate_declared_params_options_catchs'
  _orb_declared_params=(-f)
  _orb_declared_option_values=(1 flag block dash 2)
  declare -A _orb_declared_option_start_indexes=([Catch:]=1)
  declare -A _orb_declared_option_lengths=([Catch:]=3)

  It 'succeeds on valid catch values'
    When call _orb_postvalidate_declared_params_options_catchs
    The status should be success
  End

  It 'fails on invalid catch values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    declare -A _orb_declared_option_start_indexes=([Catch:]=0)
    When run _orb_postvalidate_declared_params_options_catchs
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: invalid catch value: 1 (available: any flag block dash)"
  End
End

# _orb_postvalidate_declared_params_options_requireds
Describe '_orb_postvalidate_declared_params_options_requireds'
  _orb_declared_params=(-f)
  _orb_declared_option_values=(true) 
  declare -A _orb_declared_option_start_indexes=([Required:]=0)
  declare -A _orb_declared_option_lengths=([Required:]=1)

  It 'succeeds on valid required values'
    When call _orb_postvalidate_declared_params_options_requireds
    The status should be success
  End

  It 'fails on invalid required values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    _orb_declared_option_values=(unknown)
    When run _orb_postvalidate_declared_params_options_requireds
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: invalid required value: unknown (available: true false)"
  End
End

# _orb_postvalidate_declared_params_options_multiples
Describe '_orb_postvalidate_declared_params_options_multiples'
  _orb_declared_params=(-f)
  _orb_declared_option_values=(true) 
  declare -A _orb_declared_option_start_indexes=([Multiple:]=0)
  declare -A _orb_declared_option_lengths=([Multiple:]=1)

  It 'succeeds on valid multiple values'
    When call _orb_postvalidate_declared_params_options_multiples
    The status should be success
  End

  It 'fails on invalid multiple values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    _orb_declared_option_values=(unknown) 
    When run _orb_postvalidate_declared_params_options_multiples
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: invalid multiple value: unknown (available: true false)"
  End
End

# _orb_postvalidate_declared_params_incompatible_options
Describe '_orb_postvalidate_declared_params_incompatible_options'
  _orb_declared_params=(-f)
  declare -A _orb_declared_param_suffixes=([-f]=1)

  It 'succeeds when In is present without Multiple true'
    _orb_declared_option_values=(allowed value)
    declare -A _orb_declared_option_start_indexes=([Multiple:]=- [In:]=0)
    declare -A _orb_declared_option_lengths=([Multiple:]=- [In:]=2)
    When call _orb_postvalidate_declared_params_incompatible_options
    The status should be success
  End

  It 'succeeds when Multiple is not true'
    _orb_declared_option_values=(false)
    declare -A _orb_declared_option_start_indexes=([Multiple:]=0 [In:]=-)
    declare -A _orb_declared_option_lengths=([Multiple:]=1 [In:]=-)
    When call _orb_postvalidate_declared_params_incompatible_options
    The status should be success
  End

  It 'fails when In and Multiple true are combined on value flag'
    _orb_raise_invalid_declaration() { echo_fn "$@"; exit 1; }
    _orb_declared_option_values=(true allowed value)
    declare -A _orb_declared_option_start_indexes=([Multiple:]=0 [In:]=1)
    declare -A _orb_declared_option_lengths=([Multiple:]=1 [In:]=2)
    When run _orb_postvalidate_declared_params_incompatible_options
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: incompatible options: In:, Multiple: true"
  End
End

# _orb_is_valid_param_option
Describe '_orb_is_valid_param_option'
  _orb_raise_invalid_declaration() { echo "$@"; return 1; }
  declare -A _orb_declared_param_suffixes

  Context 'with number args'
    It 'succeeds for Required:'
      When call _orb_is_valid_param_option 1 Default:
      The status should be success
    End

    It 'fails for Multiple:'
      When call _orb_is_valid_param_option 1 Multiple: true
      The status should be failure
      The output should equal "1: invalid option: Multiple: (available for number params: Required: Default: In:)"
    End
  End

  Context 'with boolean flags'
    _orb_declared_params=(-f)

    It 'succeeds for Required:'
      When call _orb_is_valid_param_option -f Default:
      The status should be success
    End

    It 'fails for Multiple:'
      When call _orb_is_valid_param_option -f Multiple: true
      The status should be failure
      The output should equal "-f: invalid option: Multiple: (available for boolean flags: Required: Default:)"
    End
  End

  Context 'with flag args'
    _orb_declared_params=(-f)
    declare -A _orb_declared_param_suffixes=([-f]=1)

    It 'succeeds for In:'
      When call _orb_is_valid_param_option -f In:
      The status should be success
    End

    It 'fails for Catch:'
      When call _orb_is_valid_param_option -f Catch: true
      The status should be failure
      The output should equal "-f: invalid option: Catch: (available for flag params: Required: Default: Multiple: In:)"
    End
  End

  Context 'with array flag args'
    declare -A _orb_declared_param_suffixes=([-f]=2)

    It 'succeeds for Required:'
      When call _orb_is_valid_param_option -f Required:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_param_option -f In: true
      The status should be failure
      The output should equal "-f: invalid option: In: (available for flag array params: Required: Default: Multiple:)"
    End
  End

  Context 'with block'
    It 'succeeds for Multiple:'
      When call _orb_is_valid_param_option -f- Multiple:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_param_option -f- In: true
      The status should be failure
      The output should equal "-f-: invalid option: In: (available for blocks: Required: Default: Multiple:)"
    End
  End

  Context 'with dash'
    It 'succeeds for Required:'
      When call _orb_is_valid_param_option -- Required:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_param_option -- In: true
      The status should be failure
      The output should equal "--: invalid option: In: (available for --: Required: Default:)"
    End
  End

  Context 'with rest'
    It 'succeeds for Required:'
      When call _orb_is_valid_param_option ... Required:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_param_option ... In: true
      The status should be failure
      The output should equal "...: invalid option: In: (available for ...: Required: Default: Catch:)"
    End
  End
End
