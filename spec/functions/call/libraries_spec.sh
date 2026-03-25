Include functions/call/libraries.sh
Include functions/utils/file.sh
Include functions/utils/utils.sh


Describe '_orb_collect_orb_libraries'
  _orb_libraries=()

  It 'calls nested functions with correct params'
    orb_trim_uniq_realpaths() { :; }
    orb_trim_uniq_realpaths() { spec_args+=($(echo_fn "$@")); }
    When call _orb_collect_orb_libraries start last
    The variable "spec_args[@]" should equal "orb_trim_uniq_realpaths _orb_libraries _orb_libraries"
    The variable "_orb_libraries[0]" should be undefined
  End

  It 'adds ORB_LIBRARIES values after existing setting libraries'
    _orb_libraries=("setting/lib1" "setting/lib2")
    ORB_LIBRARIES="env/lib1:env/lib2"
    orb_trim_uniq_realpaths() { :; }
    When call _orb_collect_orb_libraries
    The variable "_orb_libraries[0]" should eq "setting/lib1"
    The variable "_orb_libraries[1]" should eq "setting/lib2"
    The variable "_orb_libraries[2]" should eq "env/lib1"
    The variable "_orb_libraries[3]" should eq "env/lib2"
  End

  It 'skips empty ORB_LIBRARIES entries'
    ORB_LIBRARIES=":env/lib1::env/lib2:"
    orb_trim_uniq_realpaths() { :; }
    When call _orb_collect_orb_libraries
    The variable "_orb_libraries[0]" should eq "env/lib1"
    The variable "_orb_libraries[1]" should eq "env/lib2"
    The variable "_orb_libraries[2]" should be undefined
  End
End
