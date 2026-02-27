_orb_root=$(pwd)
Include functions/call/help_namespace.sh
Include functions/utils/utils.sh
Include scripts/initialize.sh

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
