Include functions/utils/param_token.sh
Include functions/declaration/params.sh
Include functions/declaration/checkers.sh
Include functions/declaration/validation.sh

_orb_function_declaration=(
  -f = flag
  -a 1 = value_flag
    Required: true
  --verbose-flag = verbose_flag 
  --verbose-value-flag 1 = verbose_value_flag 
  -b- = block # i = 16-18
  -- = dash_args  
  ... = rest 
    Required: false
)



# _orb_parse_declared_params
Describe '_orb_parse_declared_params'
  It 'calls its functions'
    _orb_get_declared_params_and_start_indexes() { spec_fns+=( $(echo_fn) ); }
    _orb_get_declared_params_lengths() { spec_fns+=( $(echo_fn) ); }
    _orb_parse_declared_params_options() { spec_fns+=( $(echo_fn) ); }
    When call _orb_parse_declared_params
    The status should be success
    The variable 'spec_fns[@]' should equal "_orb_get_declared_params_and_start_indexes _orb_get_declared_params_lengths _orb_parse_declared_params_options"
  End
End

# _orb_get_declared_params_and_start_indexes
Describe '_orb_get_declared_params_and_start_indexes'
  declare -A declared_params_start_indexes
  declare -a _orb_declared_params
  declare -A _orb_declared_param_aliases
  declare -A _orb_declared_vars
  declaration=("${_orb_function_declaration[@]}")

  It 'stores args, vars and start indexes'
    When call _orb_get_declared_params_and_start_indexes
    The status should be success
    The variable "_orb_declared_params[@]" should equal "-f -a --verbose-flag --verbose-value-flag -b- -- ..."

    vars_declaration="$(declare -p _orb_declared_vars)"
    The variable "vars_declaration[@]" should equal 'declare -A _orb_declared_vars=([...]="rest" [-b-]="block" [--]="dash_args" [-f]="flag" [-a]="value_flag" [--verbose-flag]="verbose_flag" [--verbose-value-flag]="verbose_value_flag" )'
    
    start_index_declaration="$(declare -p declared_params_start_indexes)"
    The variable "start_index_declaration[@]" should equal 'declare -A declared_params_start_indexes=([...]="22" [-b-]="16" [--]="19" [-f]="0" [-a]="3" [--verbose-flag]="9" [--verbose-value-flag]="12" )'
  End

  Context 'declared direct call'
    It 'stores var if valid var'
      _orb_declared_raw=true
      declaration=(
        -f = "flag"
      )
      When call _orb_get_declared_params_and_start_indexes
      The variable "_orb_declared_vars[-f]" should equal "flag"
      The variable "_orb_declared_comments[-f]" should be undefined
    End

    It 'stores var to comment if invalid var'
      _orb_declared_raw=true
      declaration=(
        -f = "flag comment"
      )
      When call _orb_get_declared_params_and_start_indexes
      The variable "_orb_declared_vars[-f]" should be undefined
      The variable "_orb_declared_comments[-f]" should equal "flag comment"
    End
  End

  It 'supports declared aliases for short and verbose flags'
    declaration=(
      -b\|--boolean = "boolean"
      -f\|--file 1 = "file"
    )

    When call _orb_get_declared_params_and_start_indexes
    The status should be success
    The variable "_orb_declared_params[@]" should equal "-b -f"
    The variable "_orb_declared_param_aliases[-b]" should equal "-b"
    The variable "_orb_declared_param_aliases[--boolean]" should equal "-b"
    The variable "_orb_declared_param_aliases[--file]" should equal "-f"
    The variable "_orb_declared_param_suffixes[-f]" should equal "1"
  End

  It 'supports declared aliases for block params'
    declaration=(
      '-b-|--block--' = "block"
    )

    When call _orb_get_declared_params_and_start_indexes
    The status should be success
    The variable "_orb_declared_params[@]" should equal "-b-"
    The variable "_orb_declared_param_aliases[-b-]" should equal "-b-"
    The variable "_orb_declared_param_aliases[--block--]" should equal "-b-"
  End

  It 'fails when alias types are mixed for one canonical param'
    _orb_raise_invalid_declaration() { echo_fn "$@" && exit 1; }
    declaration=(
      '-b-|-f' = "block"
    )

    When run _orb_get_declared_params_and_start_indexes
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration invalid alias declaration: -b-|-f"
  End

  It 'allows equal sign as value when preceded by Default:'
    declaration=(
      -f = file
      Default: = keep
    )

    When call _orb_get_declared_params_and_start_indexes
    The status should be success
    The variable "_orb_declared_params[@]" should equal "-f"
  End

  It 'fails on standalone non-Default equals context'
    _orb_raise_invalid_declaration() { echo_fn "$@" && exit 1; }
    declaration=(
      note = comment
    )

    When run _orb_get_declared_params_and_start_indexes
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration invalid parameter assignment: note = comment"
  End
End

# _orb_get_declared_params_lengths
Describe '_orb_get_declared_params_lengths'
  declaration=("${_orb_function_declaration[@]}")
  declare -A declared_params_lengths
  declare -A declared_params_start_indexes=([...]="22" [-b-]="16" [--]="19" [-f]="0" [-a]="3" [--verbose-flag]="9" [--verbose-value-flag]="12" )
  declare -a _orb_declared_params=( -f -a --verbose-flag --verbose-value-flag -b- -- ... )

  It 'stores length in declared_params_lengths array'
    When call _orb_get_declared_params_lengths
    The status should be success
    length_declaration=$(declare -p declared_params_lengths)
    The variable "length_declaration" should equal 'declare -A declared_params_lengths=([...]="5" [-b-]="3" [--]="3" [-f]="3" [-a]="6" [--verbose-flag]="3" [--verbose-value-flag]="4" )'
  End
End

# _orb_get_declared_param_context
Describe '_orb_get_declared_param_context'
  It 'returns context for non-suffixed arg declaration'
    declaration=(-f = file)
    When call _orb_get_declared_param_context 1 arg_raw arg_start_i
    The variable arg_raw should equal -f
    The variable arg_start_i should equal 0
  End

  It 'returns context for suffixed alias declaration'
    declaration=(-f\|--file 2 = file)
    When call _orb_get_declared_param_context 2 arg_raw arg_start_i
    The variable arg_raw should equal -f\|--file
    The variable arg_start_i should equal 0
  End
End

# _orb_get_declared_param_keys
Describe '_orb_get_declared_param_keys'
  It 'extracts canonical key as first alias'
    When call _orb_get_declared_param_keys '-f|--file' keys arg
    The variable "keys[@]" should equal "-f --file"
    The variable arg should equal -f
  End
End

# _orb_store_declared_param_suffix
Describe '_orb_store_declared_param_suffix'
  declare -A _orb_declared_param_suffixes

  It 'stores suffix when argument is suffixed'
    declaration=(-f 2 = file)
    When call _orb_store_declared_param_suffix -f 0 2
    The variable "_orb_declared_param_suffixes[-f]" should equal 2
  End

  It 'does not store suffix for non-suffixed args'
    declaration=(-f = file)
    When call _orb_store_declared_param_suffix -f 0 1
    The variable "_orb_declared_param_suffixes[-f]" should be undefined
  End
End

# _orb_store_declared_param_start_index
Describe '_orb_store_declared_param_start_index'
  declare -A declared_params_start_indexes

  It 'stores canonical arg start index'
    When call _orb_store_declared_param_start_index -f 3
    The variable "declared_params_start_indexes[-f]" should equal 3
  End
End

# _orb_store_declared_param_aliases
Describe '_orb_store_declared_param_aliases'
  declare -A _orb_declared_param_aliases

  It 'stores all aliases mapped to canonical key'
    When call _orb_store_declared_param_aliases -f -f --file
    The variable "_orb_declared_param_aliases[-f]" should equal -f
    The variable "_orb_declared_param_aliases[--file]" should equal -f
  End

  It 'raises on conflicting alias mapping'
    _orb_declared_param_aliases=([--file]=-x)
    _orb_raise_invalid_declaration() { echo_fn "$@" && exit 1; }
    When run _orb_store_declared_param_aliases -f --file
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration --file: multiple definitions"
  End
End

# _orb_store_declared_param_variable_or_comment
Describe '_orb_store_declared_param_variable_or_comment'
  declare -A _orb_declared_vars
  declare -A _orb_declared_comments

  It 'stores variable for valid variable names'
    _orb_declared_raw=false
    When call _orb_store_declared_param_variable_or_comment -f file true
    The variable "_orb_declared_vars[-f]" should equal file
  End

  It 'stores comment in raw mode for invalid variable names'
    _orb_declared_raw=true
    When call _orb_store_declared_param_variable_or_comment -f "invalid name" false
    The variable "_orb_declared_comments[-f]" should equal "invalid name"
  End

  It 'raises for invalid variable names when not raw'
    _orb_declared_raw=false
    _orb_raise_invalid_declaration() { echo_fn "$@" && exit 1; }
    When run _orb_store_declared_param_variable_or_comment -f "invalid name" false
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration invalid variable name: 'invalid name'"
  End
End


