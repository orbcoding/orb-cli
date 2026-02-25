Include functions/utils/param_token.sh
Include functions/utils/utils.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include scripts/initialize_variables.sh

# _orb_has_declared_param
Describe '_orb_has_declared_param'
  _orb_declared_params=(-f)
  declare -A _orb_declared_param_aliases=([--flag]=-f [-f]=-f)

  It 'succeeds when arg declared'
    When call _orb_has_declared_param "-f"
    The status should be success
  End

  It 'fails when arg undeclared'
    When call _orb_has_declared_param "-a"
    The status should be failure
  End

  It 'succeeds for flags with +'
    When call _orb_has_declared_param "+f"
    The status should be success
  End

  It 'succeeds for declared verbose alias'
    When call _orb_has_declared_param "--flag"
    The status should be success
  End
End

# _orb_has_declared_boolean_flag
Describe '_orb_has_declared_boolean_flag'
  _orb_declared_params=(-f)
  declare -A _orb_declared_param_aliases=()

  It 'succeeds when boolean flag declared'
    When call _orb_has_declared_boolean_flag "-f"
    The status should be success
  End

  It 'fails when boolean flag undeclared'
    When call _orb_has_declared_boolean_flag "-a"
    The status should be failure
  End
  
  It 'fails when boolean flag has suffix'
    declare -A _orb_declared_param_suffixes=([-f]=1)
    When call _orb_has_declared_boolean_flag -f
    The status should be failure
  End

  It 'handles declaration suffixes'
    _orb_variable_suffix="_suffix"
    _orb_declared_params_suffix=(-s)
    declare -A _orb_declared_param_aliases_suffix=()
    When call _orb_has_declared_boolean_flag -s
    The status should be success
  End
End


# _orb_has_declared_value_flag
Describe '_orb_has_declared_value_flag'
  _orb_declared_params=(-f)
  declare -A _orb_declared_param_aliases=()
  declare -A _orb_declared_param_suffixes=([-f]=1)

  It 'succeeds when value flag declared'
    When call _orb_has_declared_value_flag "-f"
    The status should be success
  End

  It 'fails when flag undeclared'
    When call _orb_has_declared_value_flag "-a"
    The status should be failure
  End
  
  It 'fails for boolean flags'
    declare -A _orb_declared_param_suffixes
    When call _orb_has_declared_value_flag -f
    The status should be failure
  End

  It 'handles declaration suffixes'
    _orb_variable_suffix="_suffix"
    _orb_declared_params_suffix=(-s)
    declare -A _orb_declared_param_aliases_suffix=()
    declare -A _orb_declared_param_suffixes_suffix=([-s]=1)
    When call _orb_has_declared_value_flag -s
    The status should be success
  End
End

# _orb_has_declared_array_flag_param
Describe '_orb_has_declared_array_flag_param'
  _orb_declared_params=(-a -f -n)
  declare -A _orb_declared_param_aliases=()
  declare -A _orb_declared_param_suffixes=([-a]=2 [-f]=1)

  It 'succeeds when suffix > 1'
    When call _orb_has_declared_array_flag_param "-a"
    The status should be success
  End

  It 'fails when suffix < 2'
    When call _orb_has_declared_array_flag_param "-f"
    The status should be failure
  End
  
  It 'fails when no suffix (boolean flags)'
    When call _orb_has_declared_array_flag_param -n
    The status should be failure
  End
End

# _orb_has_declared_array_param
Describe '_orb_has_declared_array_param'
  _orb_declared_params=(-b -f -m -a ... -b- --)
  declare -A _orb_declared_param_aliases=()
  declare -A _orb_declared_param_suffixes=([-f]="1" [-m]="2")
  _orb_declared_option_values=(true)
  declare -A _orb_declared_option_start_indexes=([Multiple:]="- - - 0 - - -")
  declare -A _orb_declared_option_lengths=([Multiple:]="- - - 1 - - -")
  
  It 'suceeds for value flag with suffix > 1'
    When call _orb_has_declared_array_param -m
    The status should be success
  End

  It 'suceeds for value flag with catches multiple'
    When call _orb_has_declared_array_param -a
    The status should be success
  End

  It 'fails for value flag with suffix <= 1'
    When call _orb_has_declared_array_param -f
    The status should be failure
  End

  It 'suceeds for ...'
    When call _orb_has_declared_array_param ...
    The status should be success
  End

  It 'suceeds for block'
    When call _orb_has_declared_array_param -b-
    The status should be success
  End

  It 'suceeds for --'
    When call _orb_has_declared_array_param --
    The status should be success
  End

  It 'fails for number args'
    When call _orb_has_declared_array_param 1
    The status should be failure
  End
  
  It 'fails for boolean flags'
    When call _orb_has_declared_array_param -b
    The status should be failure
  End
End

# _orb_param_catches
Describe '_orb_param_catches'
  _orb_declared_params=(1)
  _orb_declared_option_values=(flag)
  declare -A _orb_declared_option_start_indexes=([Catch:]="0")
  declare -A _orb_declared_option_lengths=([Catch:]="1")
  
  It 'adds catch values to arg_catchs'
    When call _orb_param_catches 1 -f
    The status should be success
  End
End

# _orb_param_option_value_is
Describe '_orb_param_option_value_is'
  _orb_declared_params=(-e)
  declare -A _orb_declared_param_aliases=()

  It 'fails when option is not declared for param'
    declare -A _orb_declared_option_start_indexes=([Multiple:]='-')
    declare -A _orb_declared_option_lengths=([Multiple:]='-')
    When call _orb_param_option_value_is -e Multiple: true
    The status should be failure
  End

  It 'succeeds when option value matches'
    _orb_declared_option_values=(true)
    declare -A _orb_declared_option_start_indexes=([Multiple:]=0)
    declare -A _orb_declared_option_lengths=([Multiple:]=1)
    When call _orb_param_option_value_is -e Multiple: true
    The status should be success
  End
End

