Include functions/call/function.sh
Include functions/utils/param_token.sh
Include functions/utils/text.sh


Describe _orb_get_current_function
  Context 'with _orb_sourced'
    _orb_sourced=true
    _orb_get_current_function_from_trace() { echo_fn; }

    It 'calls _orb_get_current_function_from_trace and returns 2'
      When call _orb_get_current_function my_function
      The status should equal 2
      The output should equal _orb_get_current_function_from_trace
    End
  End

  Context 'without _orb_sourced'
    unset _orb_sourced

    It 'returns 0 and outputs $1'
      When call _orb_get_current_function my_function
      The status should be success
      The variable _orb_function_name should equal my_function
    End
  End
End

Describe '_orb_get_current_function_from_trace'
  It 'gets function from source chain'
    _orb_function_trace=("source" "fn" )
    When call _orb_get_current_function_from_trace
    The variable _orb_function_name should eq fn
  End
End


Describe '_orb_get_current_function_descriptor'
  It 'includes namespace if present'
    When call _orb_get_current_function_descriptor test_fn test_namespace
    The variable _orb_function_descriptor should equal "test_namespace -> test_fn"
  End

  It 'only fn if no namespace'
    When call _orb_get_current_function_descriptor test_fn
    The variable _orb_function_descriptor should equal "test_fn"
  End
End

# _orb_validate_current_function
Describe '_orb_validate_current_function'
  _orb_raise_error() { echo_fn "$@"; exit 1; }

  It 'raises if present and not variable name'
    _orb_function_name="--asd"
    When run _orb_validate_current_function
    The status should be failure
    The output should eq "_orb_raise_error invalid function name"
  End

  It 'does not raise if not present'
    _orb_function_name=""
    When run _orb_validate_current_function
    The status should be success
  End

  It 'does not raise if valid var name'
    _orb_function_name="my_function"
    When run _orb_validate_current_function
    The status should be success
  End
End

