Include functions/argument/assignment.sh

# _orb_assign_stored_arg_values_to_declared_variables
Describe '_orb_assign_stored_arg_values_to_declared_variables'
  It 'assigns arg values to declared vars'
    _orb_declared_params=(1 -f ...)
    declare -A _orb_declared_vars=([1]=first [-f]=flag [...]=rest)
    _orb_get_arg_value() { spec_args+=($(echo_fn $@)); }
    When call _orb_assign_stored_arg_values_to_declared_variables
    The variable "spec_args[@]" should equal "_orb_get_arg_value 1 first _orb_get_arg_value -f flag _orb_get_arg_value ... rest"
  End
End
