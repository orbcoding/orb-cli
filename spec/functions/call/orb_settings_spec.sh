_orb_dir=$(pwd)
Include scripts/initialize.sh
Include scripts/call/variables.sh

Describe '_orb_extract_orb_settings_arguments'
  It 'extracts settings arguments'
    extract() { 
      _orb_parse_function_declaration _orb_settings_declaration
      _orb_extract_orb_settings_arguments settings_args -e ext --help -d -r -e ext2 namespace function
    }
    When call extract 
    The variable "settings_args[0]" should equal "-e"
    The variable "settings_args[@]" should equal "-e ext --help -d -r -e ext2"
  End

  It 'raises error un undefined settings arg'
    _orb_raise_invalid_orb_settings_arg() { echo_fn "$@"; }
    extract() { 
      _orb_parse_function_declaration _orb_settings_declaration
      _orb_extract_orb_settings_arguments settings_args -k -e ext --help -d -r -e ext2 namespace function
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
    orb_raise_error() { echo -e "$@" && exit 1; }

    When run source scripts/call/orb_settings.sh --unknown-flag
    The output should equal "-d $(orb_bold)orb$(orb_normal) invalid option --unknown-flag

Available options:

  --help   Show help
  -e       Additional orb extension folders
  -d       Direct function call
  -r       Restore function declarations after call"

    The status should be failure
  End
End