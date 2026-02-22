_orb_root=$(pwd)
Include functions/call/help.sh
Include functions/utils/utils.sh
Include scripts/initialize.sh

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
    The output should equal "Default namespace: $(orb_bold $ORB_DEFAULT_NAMESPACE).

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

# _orb_print_namespace_help
Describe '_orb_print_namespace_help'
  Include "$_orb_root/scripts/call/variables.sh"
  _orb_setting_raw=false

  dir="$(pwd)/spec/fixtures/.orb/namespaces/spec"
  It 'prints functions with comments'
    _orb_namespace_files=( "$dir/test_print_help_functions.sh" "$dir/public_and_private_functions.sh" "$dir/test_print_help_functions2.sh" )
    _orb_namespace_files_orb_dir_tracker=( "$spec_orb" "$spec_orb" "$spec_orb/random_dir" )
    When call _orb_print_namespace_help
    The line 1 of output should include "-----------------  "
    The line 1 of output should include "spec/fixtures/.orb"
    The line 2 of output should include "test_print_help_functions.sh"
    # The third line of output should include "test_orb_print_args                        test_orb_print_args comment"
    The line 4 of output should eq "                                                  "
    The line 5 of output should include "public_and_private_functions.sh"
    The line 12 of output should eq "                                                  "
    The line 13 of output should include "-----------------  "
    The line 13 of output should include "spec/fixtures/.orb/random_dir"
    The line 17 of output should include "To show information about a function, use \`orb --help \"namespace\" \"function\"\`"
    The output should include "\
  public_function                                 public_function comment
  public_function_with_preceeding_array_end       public_function_with_preceeding_array_end comment
  public_function_with_curly_on_next_line         public_function_with_curly_on_next_line comment
  public_function_with_space_before_braces        public_function_with_space_before_braces comment
  public_function_with_comment_after              public_function_with_comment_after comment
  public_function_oneliner                   "
  End
End

# _orb_print_function_help
Describe '_orb_print_function_help'
End

# _orb_print_args_explanation
Describe '_orb_print_args_explanation'
  Include "$_orb_root/scripts/call/variables.sh"

  _orb_function_declaration=(
    1 = first
      "This is first comment"
      Required: false
      Default: value
      In: first value or other

    -a 1 = flagged_arg
      "This is flagged comment"
      Required: true
      Default: Help: "value help"
      In: second value or other
  )

  It "fails if no declared args"
    When call _orb_print_args_explanation
    The status should be failure
  End

  It 'prints args explanation'
    parse() {
      _orb_parse_function_declaration
      _orb_print_args_explanation
    }
    When call parse
    The first line of output should include "Required:  Default:          In:                    Catch:  Multiple:"
    The output should include "\
  1     false      value             first value or other   -       -          This is first comment
  -a 1  true       Help: value help  second value or other  -       -          This is flagged comment"
    End
End

# _orb_print_function_comment
Describe '_orb_print_function_comment'
End

# _orb_print_orb_function_and_comment
Describe '_orb_print_orb_function_and_comment'
End
