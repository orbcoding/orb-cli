Include functions/utils/param_token.sh

# orb_is_flag
Describe 'orb_is_flag'
  It 'succeeds with dash (-) flag'
    When call orb_is_flag -f
    The status should be success
  End

  It 'accepts w'
    When call orb_is_flag -w
    The status should be success
  End

  It 'fails with plus (+) flag'
    When call orb_is_flag +f
    The status should be failure
  End

  It 'fails with multiple chars'
    When call orb_is_flag -far
    The status should be failure
  End

  It 'succeeds with verbose flag (--) flag'
    When call orb_is_flag --verbose-flag
    The status should be success
  End

  It 'fails without +/- prefix'
    When call orb_is_flag f
    The status should be failure
  End

  It 'fails with spaces'
    When call orb_is_flag "-f s"
    The status should be failure
  End

  It 'fails with _'
    When call orb_is_flag "-f_"
    The status should be failure
  End

  It 'fails with extra -'
    When call orb_is_flag "-f-f"
    The status should be failure
  End

  It 'fails with block'
    When call orb_is_flag -f-
    The status should be failure
  End
End

# orb_is_input_flag
Describe 'orb_is_input_flag'
  It 'accepts normal short flag'
    When call orb_is_input_flag -f
    The status should be success
  End

  It 'accepts normal verbose flag'
    When call orb_is_input_flag --verbose-flag
    The status should be success
  End

  It 'accepts reversed short flag (+f)'
    When call orb_is_input_flag +f
    The status should be success
  End

  It 'accepts reversed verbose flag (+-verbose-flag)'
    When call orb_is_input_flag +-verbose-flag
    The status should be success
  End

  It 'fails for invalid plus-verbose form'
    When call orb_is_input_flag +--verbose-flag
    The status should be failure
  End
End


# orb_is_flag_with_nr
Describe 'orb_is_flag_with_nr'
  It 'succeeds with dash (-) flag arg'
    When call orb_is_flag_with_nr "-f 1"
    The status should be success
  End

  It 'succeeds with verbose flag (--) flag arg'
    When call orb_is_flag_with_nr "--verbose-flag 20"
    The status should be success
  End

  It 'fails with plus (+) flag arg'
    When call orb_is_flag_with_nr "+f 3"
    The status should be failure
  End

  It 'fails without +/- prefix flag arg'
    When call orb_is_flag_with_nr "f 4"
    The status should be failure
  End
End

# orb_is_nr
Describe 'orb_is_nr'
  It 'succeeds with numbers'
    When call orb_is_nr 1231098
    The status should be success
  End

  It 'fails with spaces'
    When call orb_is_nr "1 1"
    The status should be failure
  End

  It 'fails with letters'
    When call orb_is_nr "1a1"
    The status should be failure
  End
End

# orb_is_block
Describe 'orb_is_block'
  It 'succeeds with -b-'
    When call orb_is_block -b-
    The status should be success
  End

  It 'succeeds with w'
    When call orb_is_block -w-
    The status should be success
  End

  It 'succeeds with verbose block name'
    When call orb_is_block "--very-verbose-block--"
    The status should be success
  End

  It 'fails for single-dash multi-letter block'
    When call orb_is_block "-long-block-"
    The status should be failure
  End

  It 'fails with spaces'
    When call orb_is_block "-b -"
    The status should be failure
  End
End

# orb_is_rest
Describe 'orb_is_rest'
  It 'accepts ...'
    When call orb_is_rest '...'
    The status should be success
  End

  It 'fails if not rest'
    When call orb_is_rest random
    The status should be failure
  End
End

# orb_is_rest
Describe 'orb_is_dash'
  It 'accepts --'
    When call orb_is_dash '--'
    The status should be success
  End

  It 'fails if not dash'
    When call orb_is_dash random
    The status should be failure
  End
End

# orb_is_canonical_param
Describe 'orb_is_canonical_param'
  It 'succeeds for flag'
    When call orb_is_canonical_param "-f"
    The status should be success
  End

  It 'succeeds for verbose_flag'
    When call orb_is_canonical_param "--verbose-flag"
    The status should be success
  End

  It 'succeeds for block'
    When call orb_is_canonical_param "-b-"
    The status should be success
  End

  It 'succeeds for rest'
    When call orb_is_canonical_param "..."
    The status should be success
  End

  It 'succeeds for dash'
    When call orb_is_canonical_param "--"
    The status should be success
  End

  It 'fails with other'
    When call orb_is_canonical_param '_f'
    The status should be failure
  End
End

# orb_split_flag_aliases
Describe 'orb_split_flag_aliases'
  It 'splits alias token into ordered aliases'
    When call orb_split_flag_aliases '-f|--file' _arr
    The variable "_arr[@]" should equal "-f --file"
  End

  It 'returns single token as one-item array'
    When call orb_split_flag_aliases '--file' _arr
    The variable "_arr[@]" should equal "--file"
  End
End

# orb_is_flag_alias_token
Describe 'orb_is_flag_alias_token'
  It 'succeeds for flag alias token'
    When call orb_is_flag_alias_token '-f|--file'
    The status should be success
  End

  It 'fails for block alias token'
    When call orb_is_flag_alias_token '-b-|--block--'
    The status should be failure
  End

  It 'fails for non-alias single flag token'
    When call orb_is_flag_alias_token '-f'
    The status should be failure
  End

  It 'fails when any alias part is invalid'
    When call orb_is_flag_alias_token '-f|1'
    The status should be failure
  End
End

# orb_is_block_alias_token
Describe 'orb_is_block_alias_token'
  It 'succeeds for block alias token'
    When call orb_is_block_alias_token '-b-|--block--'
    The status should be success
  End

  It 'fails for flag alias token'
    When call orb_is_block_alias_token '-f|--file'
    The status should be failure
  End

  It 'fails when any alias part is invalid'
    When call orb_is_block_alias_token '-b-|1'
    The status should be failure
  End

  It 'fails when alias parts mix flag and block kinds'
    When call orb_is_block_alias_token '-f|-b-'
    The status should be failure
  End
End

# orb_is_alias_token
Describe 'orb_is_alias_token'
  It 'succeeds for alias token'
    When call orb_is_alias_token '-f|--file'
    The status should be success
  End

  It 'succeeds for block alias token'
    When call orb_is_alias_token '-b-|--block--'
    The status should be success
  End

  It 'fails for non-alias single flag token'
    When call orb_is_alias_token '-f'
    The status should be failure
  End

  It 'fails when any alias part is invalid'
    When call orb_is_alias_token '-f|1'
    The status should be failure
  End

  It 'fails when alias parts mix flag and block kinds'
    When call orb_is_alias_token '-f|-b-'
    The status should be failure
  End
End

# orb_is_flag_token
Describe 'orb_is_flag_token'
  It 'succeeds for single flag token'
    When call orb_is_flag_token '-f'
    The status should be success
  End

  It 'succeeds for flag alias token'
    When call orb_is_flag_token '-f|--file'
    The status should be success
  End

  It 'fails for block alias token'
    When call orb_is_flag_token '-b-|--block--'
    The status should be failure
  End
End

# orb_is_block_token
Describe 'orb_is_block_token'
  It 'succeeds for single block token'
    When call orb_is_block_token '-b-'
    The status should be success
  End

  It 'succeeds for block alias token'
    When call orb_is_block_token '-b-|--block--'
    The status should be success
  End

  It 'fails for flag alias token'
    When call orb_is_block_token '-f|--file'
    The status should be failure
  End
End

# orb_is_param_token
Describe 'orb_is_param_token'
  It 'succeeds for normal input arg tokens'
    When call orb_is_param_token '...'
    The status should be success
  End

  It 'succeeds for alias flag token'
    When call orb_is_param_token '-f|--file'
    The status should be success
  End

  It 'succeeds for alias block token'
    When call orb_is_param_token '-b-|--block--'
    The status should be success
  End

  It 'fails for invalid alias token'
    When call orb_is_param_token '-f|1'
    The status should be failure
  End
End

# orb_is_valid_variable_name
Describe 'orb_is_valid_variable_name'
  It 'succeeds for chars'
    When call orb_is_valid_variable_name "var"
    The status should be success
  End
  
  It 'succeeds if ends with number'
    When call orb_is_valid_variable_name "var1"
    The status should be success
  End
  
  It 'succeeds if contains upcase'
    When call orb_is_valid_variable_name "Var"
    The status should be success
  End
  
  # Use eg internally for _orb_settings_declaration
  It 'succeeds if starts with underscore'
    When call orb_is_valid_variable_name "_var"
    The status should be success
  End
  
  It 'succeeds if contains underscore not first'
    When call orb_is_valid_variable_name "Var_name"
    The status should be success
  End
  
  It 'fails if starts with number'
    When call orb_is_valid_variable_name "1var"
    The status should be failure
  End

  It 'fails if contains dash'
    When call orb_is_valid_variable_name "va-r"
    The status should be failure
  End
End
