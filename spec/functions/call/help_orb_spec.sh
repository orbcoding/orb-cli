_orb_root=$(pwd)
Include functions/call/help_orb.sh
Include functions/call/namespace.sh
Include functions/utils/utils.sh

# _orb_handle_help
Describe '_orb_handle_help'
  _orb_print_orb_help() { echo_fn; }
  _orb_print_namespace_help() { echo_fn; }
  _orb_print_function_help() { echo_fn; }
  _orb_setting_help=true

  It 'prints global help if global help requested'
    When call _orb_handle_help
    The output should equal _orb_print_orb_help
  End

  It 'prints function help if function provided'
    _orb_function_name=spec
    When call _orb_handle_help
    The output should equal _orb_print_function_help
  End

  It 'prints namespace help if namespace provided'
    _orb_namespace_name=spec
    When call _orb_handle_help
    The output should equal _orb_print_namespace_help
  End

  It 'fails when no help requested'
    _orb_setting_help=false
    When call _orb_handle_help
    The status should be failure
  End
End

# _orb_print_orb_help
Describe '_orb_print_orb_help'
  Include functions/utils/text.sh

  It 'prints help with no namespaces or default'
    When call _orb_print_orb_help
    The output should equal 'Default namespace $ORB_DEFAULT_NAMESPACE not set.

No namespaces found'
  End

  It 'prints default namespace if found'
    ORB_DEFAULT_NAMESPACE=spec
    When call _orb_print_orb_help
    The output should equal "Default namespace: $ORB_DEFAULT_NAMESPACE.

No namespaces found"
  End

  It 'prints namespaces when found'
    _orb_namespaces=( spec spec2 )
    When call _orb_print_orb_help
    The line 1 of output should include 'Default namespace $ORB_DEFAULT_NAMESPACE not set'
    The line 4 of output should include "spec"
    The line 5 of output should include "spec2"
    The line 7 of output should include 'To show information about a namespace, use `orb --help "namespace"`'
  End
End
