Include functions/argument/defaults.sh

Describe '_orb_set_default_arg_values'
  _orb_set_default_from_declaration() { spec_args+=("$@"); }
  _orb_declared_params=(1 -f)

  It 'sets from declaration if value not already set'
    _orb_has_arg_value() { return 1; }

    When call _orb_set_default_arg_values
    The variable "spec_args[@]" should eq "1 -f"
  End

  It 'Does not set from declaration if value already set'
    _orb_has_arg_value() { return 0; }

    When call _orb_set_default_arg_values
    The variable "spec_args[@]" should be undefined
  End
End
