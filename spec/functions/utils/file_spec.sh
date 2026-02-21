Include functions/utils/file.sh
Include functions/utils/utils.sh

Describe 'orb_get_closest_parent'
  It 'finds the closest matching file'
    When call orb_get_closest_parent specfile spec/fixtures/functions/utils/file.sh/nest1/nest2
    The output should include "spec/fixtures/functions/utils/file.sh/nest1/nest2/specfile"
    The status should be success
  End

  It 'finds the closest matching file in lower levels'
    When call orb_get_closest_parent specfile1 spec/fixtures/functions/utils/file.sh/nest1/nest2
    The output should include "spec/fixtures/functions/utils/file.sh/nest1/specfile1"
  End

  It 'fails if no file found'
    When call orb_get_closest_parent file_non_existent spec/fixtures/functions/utils/file.sh/nest1/nest2
    The status should be failure
  End
End

Describe 'orb_get_parents'
  # TODO test & and |

  It 'adds file matches to array'
    arr=()
    When call orb_get_parents arr specfile spec/fixtures/functions/utils/file.sh/nest1/nest2
    The variable "arr[0]" should include "spec/fixtures/functions/utils/file.sh/nest1/nest2/specfile" 
    The variable "arr[1]" should include "spec/fixtures/functions/utils/file.sh/nest1/specfile"
  End

  It 'stops after parsing last directory'
    arr=()
    When call orb_get_parents arr specfile spec/fixtures/functions/utils/file.sh/nest1/nest2 spec/fixtures/functions/utils/file.sh/nest1/nest2
    The variable "arr[0]" should include "spec/fixtures/functions/utils/file.sh/nest1/nest2/specfile" 
    The variable "arr[1]" should be undefined
  End

  It 'fails if no file found'
    When call orb_get_closest_parent file_non_existent spec/fixtures/functions/utils/file.sh/nest1/nest2
    The status should be failure
  End

  It 'finds both if two files specified with &'
    arr=()
    cd spec/fixtures
    When call orb_get_parents arr "_orb&.orb" "$(pwd)" "$(pwd)"
    The variable "arr[0]" should eq "$(pwd)/_orb"
    The variable "arr[1]" should eq "$(pwd)/.orb"
  End

  It 'finds first if two files specified with |'
    arr=()
    cd spec/fixtures
    When call orb_get_parents arr "_orb|.orb" "$(pwd)" "$(pwd)"
    The variable "arr[0]" should eq "$(pwd)/_orb"
    The variable "arr[1]" should be undefined
  End
End

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

Describe 'orb_parse_env'
  It 'exports variables from .env'
    When call orb_parse_env "$spec_orb/.env"
    The variable SPEC_TEST_VAR should equal "test"
    The variable SPEC_TEST_VAR2 should equal "test2"
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
