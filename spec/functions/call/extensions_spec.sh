Include functions/call/extensions.sh
Include functions/utils/file.sh
Include functions/utils/utils.sh


Describe '_orb_collect_orb_extensions'
  _orb_extensions=()

  It 'calls nested functions with correct params'
    orb_get_parents() { :; }
    orb_trim_uniq_realpaths() { :; }
    # so no home .orb is found
    HOME=
    orb_get_parents() { spec_args+=($(echo_fn "$@")); }
    orb_trim_uniq_realpaths() { spec_args+=($(echo_fn "$@")); }
    When call _orb_collect_orb_extensions start last
    The variable "spec_args[@]" should equal "orb_get_parents _orb_extensions _orb&.orb start last orb_trim_uniq_realpaths _orb_extensions _orb_extensions"
    The variable "_orb_extensions[0]" should be undefined
  End

  It 'includes .orb from home dir if present'
    HOME="$(pwd)/spec/fixtures"
    cd /
    When call _orb_collect_orb_extensions
    The variable "_orb_extensions[0]" should eq "$HOME/.orb"
    The variable "_orb_extensions[1]" should be undefined
  End

  It 'finds _orb and .orb folders'
    cd spec/fixtures
    When call _orb_collect_orb_extensions
    The variable "_orb_extensions[0]" should eq "$(pwd)/_orb"
    The variable "_orb_extensions[1]" should eq "$(pwd)/.orb"
  End
End


Describe '_orb_parse_env_extensions'
  Include functions/utils/file.sh
  It 'parses env files in orb folders'
    _orb_extensions=( spec/fixtures/.orb spec/fixtures/_orb )
    When call _orb_parse_env_extensions
    The variable SPEC_TEST_VAR should equal "test"
    The variable SPEC_TEST_VAR3 should equal "test3"
  End
End
