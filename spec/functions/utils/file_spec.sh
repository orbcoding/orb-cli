Include functions/utils/file.sh
Include functions/utils/utils.sh

Describe 'orb_trim_uniq_realpaths'
  It 'trims away non unique realpaths'
    # first is symlink to second
    paths=(
      "$(pwd)"/spec/fixtures/functions/utils/file.sh/nest1/nest2/nest3_file_symlink_to_2/specfile
      "$(pwd)"/spec/fixtures/functions/utils/file.sh/nest1/nest2/specfile
    )
    When call orb_trim_uniq_realpaths paths paths
    The variable "paths[@]" should eq "$(pwd)"/spec/fixtures/functions/utils/file.sh/nest1/nest2/nest3_file_symlink_to_2/specfile
  End
End

Describe 'orb_has_public_function'
  file="$spec_orb/namespaces/spec/public_and_private_functions.sh"

  It 'succeeds if public function exists in file'
    # When call orb_has_public_function "$spec_orb/namespaces/spec/test_functions.sh"
    When call orb_has_public_function public_function "$file"
    The status should be success
  End

  It 'fails if function is private'
    When call orb_has_public_function private_function "$file"
    The status should be failure
  End

  It 'fails if function does not exist in file'
    When call orb_has_public_function non_existent_function "$file"
    The status should be failure
  End
End

Describe "orb_get_public_functions"
  It 'gest public functions from file'
    When call orb_get_public_functions "$spec_orb/namespaces/spec/public_and_private_functions.sh" fns
    The variable "fns[0]" should eq "public_function"
    The variable "fns[@]" should eq "public_function \
public_function_with_preceeding_array_end \
public_function_with_curly_on_next_line \
public_function_with_space_before_braces \
public_function_with_comment_after \
public_function_oneliner"
  End
End
