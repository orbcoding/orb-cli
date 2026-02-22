_orb_root=$(pwd)
Include scripts/initialize.sh
Include scripts/call/variables.sh

Describe 'settings.sh'
  _orb_raise_error() { echo "$@"; exit 1; }

  It 'collects --help'
    When call source scripts/call/settings.sh --help
    The variable "_orb_setting_help" should equal true
    The variable "_orb_settings_args[@]" should eq "--help"
  End

  It 'collects --d'
    When call source scripts/call/settings.sh -r
    The variable "_orb_setting_raw" should equal true
    The variable "_orb_settings_args[@]" should eq "-r"
  End
  
  It 'collects --restore-fns'
    When call source scripts/call/settings.sh --restore-fns
    The variable "_orb_setting_restore_functions" should equal true
    The variable "_orb_settings_args[@]" should eq "--restore-fns"
  End

  It 'collects -l'
    When call source scripts/call/settings.sh -l spec_lib -l spec_lib2
    The variable "_orb_setting_libraries[0]" should equal "spec_lib"
    The variable "_orb_setting_libraries[1]" should equal "spec_lib2"
    The variable "_orb_settings_args[@]" should eq "-l spec_lib -l spec_lib2"
  End

  It 'adds collected libraries to _orb_libraries array'
    _orb_libraries=("some/lib")
    When call source scripts/call/settings.sh -l spec_lib -l spec_lib2
    The variable "_orb_libraries[0]" should equal "some/lib"
    The variable "_orb_libraries[1]" should equal "spec_lib"
    The variable "_orb_libraries[2]" should equal "spec_lib2"
    The variable "_orb_settings_args[@]" should eq "-l spec_lib -l spec_lib2"
  End
End
