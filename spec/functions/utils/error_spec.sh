Include functions/utils/error.sh
# PATH=PATH:$_orb_root/bin

# Describe 'orb_raise_error'
#   kill() {
#     return 2
#   }
  
#   _orb_function_descriptor=test_caller_descriptor
  
#   It 'prints error with trace and kills script'
#     When call orb_raise_error "test error"
#     The status should equal 2
#     The error should include Error:
#     The error should include "test_caller_descriptor"
#     The error should include "test error"
#     # Parts of trace
#     The error should include error.sh
#     The error should include orb_raise_error
#   End

#   It 'does not kill script with +k'
#     exit() {
#       return 1
#     }
#     When call orb_raise_error +k "test error"
#     The status should be failure
#     The error should include Error:
#     The error should include "test_caller_descriptor"
#     The error should include "test error"
#     # Parts of trace
#     The error should include error.sh
#     The error should include orb_raise_error
#   End

#   It 'does not print trace with +t'
#     When call orb_raise_error +t "test error"
#     The status should be failure
#     The error should include Error:
#     The error should include "test error"
#     The error should include "test_caller_descriptor"
#     # Parts of trace
#     The error should not include error_handling.sh
#     The error should not include orb_raise_error
#   End

#   It 'accepts custom descriptor'
#     When call orb_raise_error -d "custom_descriptor" "test error"
#     The status should be failure
#     The error should include Error:
#     The error should include "test error"
#     The error should include "custom_descriptor"
#   End
# End

# Describe 'orb_print_error'
#   _orb_function_descriptor=test_caller_descriptor

#   It 'prints pretty error'
#     When call orb_print_error 'test error'
#     The status should be success
#     The error should include Error:
#     The error should include "test error"
#     The error should include "test_caller_descriptor"
#   End

#   It 'accepts custom descriptor'
#     When call orb_print_error -d "custom_descriptor" "test error"
#     The status should be success
#     The error should include Error:
#     The error should include "test error"
#     The error should include "custom_descriptor"
#   End
# End

Describe 'orb_kill_script'
  It 'exits 1 if kill_script false'
    When run orb_kill_script
    The status should be failure
  End 

  It 'kills -PIPE 0 if kill_script true'
    kill() {
      echo $*
    }
    
    When call orb_kill_script true
    The output should equal "-PIPE 0"
  End
  
  It 'kills -PIPE 0 if kill_script true'
    kill() {
      echo $*
    }
    
    ORB_KILL_SCRIPT_ON_ERROR=true
    When call orb_kill_script
    The output should equal "-PIPE 0"
    ORB_KILL_SCRIPT_ON_ERROR=false
  End
End

Describe 'orb_print_stack_trace'
  It 'Should print stack trace to stdout'
    export -f orb_print_stack_trace

    When call $spec_proxy orb_print_stack_trace
    The first line of output should equal ""
    The second line of output should include proxy_fn
    The third line of output should include main
  End
End
