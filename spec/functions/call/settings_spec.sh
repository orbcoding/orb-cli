_orb_root=$(pwd)
Include scripts/initialize.sh
Include scripts/call/variables.sh

Describe '_orb_extract_orb_settings_arguments'
  _orb_raise_invalid_orb_settings_arg() { echo_fn "$@"; }

  It 'extracts settings arguments'
    extract() { 
      _orb_parse_function_declaration _orb_settings_declaration
      _orb_extract_orb_settings_arguments settings_args -l lib --help -r -l lib2 namespace function
    }
    When call extract 
    The variable "settings_args[0]" should equal "-l"
    The variable "settings_args[@]" should equal "-l lib --help -r -l lib2"
  End

  It 'raises error un undefined settings arg'
    extract() { 
      _orb_parse_function_declaration _orb_settings_declaration
      _orb_extract_orb_settings_arguments settings_args -k -l lib --help -r -l lib2 namespace function
    }
    When call extract 
    The output should equal "_orb_raise_invalid_orb_settings_arg -k"
  End
End


Describe '_orb_has_orb_settings_arguments'
  It 'succeeds if first arg is flag'
    When call _orb_has_orb_settings_arguments -b spec
    The status should be success
  End

  It 'fails if first arg is not flag'
    When call _orb_has_orb_settings_arguments spec -b
    The status should be failure
  End
End

Describe '_orb_raise_invalid_orb_settings_arg'
  It 'raises on invalid flag'
    _orb_raise_error() { echo -e "$@" && exit 1; }

    When run source scripts/call/settings.sh --unknown-flag
    The output should include "invalid option --unknown-flag

Available options:"

    The status should be failure
  End
End
