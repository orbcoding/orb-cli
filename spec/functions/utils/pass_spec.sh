_orb_raise_undeclared() { echo_fn; exit 1; }
Include functions/utils/pass.sh
Include functions/utils/param_token.sh
_orb_arr=()

# orb_pass
Describe 'orb_pass'
  # Holistic testing
  spec_function_orb=(
    1 = first
      Required: false
    -f = flag
    -a 1 = flag_arg
    -b- = block
    --verbose-flag = verbose_flag
    ... = rest 
      Required: false
    -- = dash
  )

  spec_function() { source $_orb_root/bin/orb; callback; }
  callback() { orb_pass -a my_arr -- 1 -f -a -b- --verbose-flag ... --; }

  BeforeEach() { my_arr=(); }
  
  It 'should pass received args'
    When call spec_function first -f -a arg -b- my block -b- --verbose-flag rest args -- dash args
    The variable "my_arr[@]" should eq "first -f -a arg -b- my block -b- --verbose-flag rest args -- dash args"
  End

  It 'should pass only values of received args if -v'
    callback() { orb_pass -v -a my_arr -- 1 -f -a -b- --verbose-flag ... --; }
    When call spec_function first -f -a arg -b- my block -b- --verbose-flag rest args -- dash args
    The variable "my_arr[@]" should eq "first -f arg my block --verbose-flag rest args dash args"
  End

  It 'should not pass anything if nothing received'
    When call spec_function
    The variable "my_arr[@]" should be undefined
  End
End

# _orb_pass_flag
Describe '_orb_pass_flag'
  _orb_only_val=false
  _orb_pass_arg() { echo "$@"; }

  Context 'with boolean flag'
    _orb_has_declared_boolean_flag() { return 0; }

    It 'calls _orb_pass_arg with correct params'
      When call _orb_pass_flag -f
      The output should eq "-f   true" 
    End

    It 'handles multiflags'
      _orb_pass_arg() { spec_flags+=("$@"); }
      When call _orb_pass_flag -fasd
      The variable "spec_flags[@]" should eq "-f   true -a   true -s   true -d   true" 
    End

    It 'handles verbose flags'
      When call _orb_pass_flag --verbose-flag
      The output should eq "--verbose-flag   true"
    End
  End

  Context 'with value flag'
    _orb_has_declared_boolean_flag() { return 1; }
    _orb_has_declared_value_flag() { return 0; }

    It 'calls _orb_pass_arg with correct params'
      When call _orb_pass_flag -f
      The output should eq "-f -f"
    End

    It 'omits flag if only val'
      _orb_only_val=true
      When call _orb_pass_flag -f
      The output should eq -f
    End
  End
End

# _orb_pass_block
Describe '_orb_pass_block'
  _orb_only_val=false
  _orb_pass_arg() { echo "$@"; }

  It 'calls _orb_pass_arg with correct params'
    When call _orb_pass_block -b-
    The output should eq "-b- -b- -b-"
  End

  It 'omits surrounding block marks if only val specified'
    _orb_only_val=true
    When call _orb_pass_block -b-
    The output should eq -b-
  End
End

# _orb_pass_dash
Describe '_orb_pass_dash'
  _orb_only_val=false
  _orb_pass_arg() { echo "$@"; }

  It 'calls _orb_pass_arg with correct params'
    When call _orb_pass_dash --
    The output should eq "-- --"
  End

  It 'omits dash if only val specified'
    _orb_only_val=true
    When call _orb_pass_dash --
    The output should eq --
  End
End

# _orb_pass_arg
Describe '_orb_pass_arg'
  _orb_has_declared_param() { return 0; }
  _orb_has_arg_value() { return 0; }

  _orb_get_arg_value() {
    declare -n store=$2
    store=(generic value)
  }

  It 'adds value to _orb_arr if declared with val'
    When call _orb_pass_arg ...
    The variable "_orb_arr[@]" should eq "generic value" 
  End

  It 'adds prefix and suffix if supplied'
    When call _orb_pass_arg ... prefix suffix
    The variable "_orb_arr[@]" should eq "prefix generic value suffix" 
  End

  It 'adds if matches eq param'
    When call _orb_pass_arg ... "" "" "generic value"
    The variable "_orb_arr[@]" should eq "..." 
  End

  It 'does not add if does not match eq param'
    When call _orb_pass_arg ... "" "" "non_eq"
    The status should be failure
    The variable "_orb_arr[@]" should be undefined 
  End
  
  It 'fails if no value'
    _orb_has_arg_value() { return 1; }
    When call _orb_pass_arg ...
    The status should be failure
    The variable "_orb_arr[@]" should be undefined 
  End

  It 'raises undeclared if undeclared'
    _orb_has_declared_param() { return 1; }
    When run _orb_pass_arg ...
    The status should be failure
    The variable "_orb_arr[@]" should be undefined 
    The output should equal _orb_raise_undeclared
  End
End
