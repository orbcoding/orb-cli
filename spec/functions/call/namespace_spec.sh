Include functions/call/namespace.sh
Include functions/utils/text.sh
Include functions/utils/utils.sh
Include functions/utils/param_token.sh

# _orb_collect_available_namespaces
Describe '_orb_collect_available_namespaces'
  It 'finds namespaces in orb folders'
    _orb_libraries=( spec/fixtures/functions/call/namespace.sh/lib )
    When call _orb_collect_available_namespaces
    The variable "_orb_namespaces[0]" should eq a
    The variable "_orb_namespaces[1]" should eq b
    The variable "_orb_namespaces[2]" should eq c
    The variable "_orb_namespaces[3]" should be undefined
  End

  It 'adds each once'
    _orb_libraries=( spec/fixtures/functions/call/namespace.sh/lib spec/fixtures/functions/call/namespace.sh/lib )
    When call _orb_collect_available_namespaces
    The variable "_orb_namespaces[0]" should eq a
    The variable "_orb_namespaces[1]" should eq b
    The variable "_orb_namespaces[2]" should eq c
    The variable "_orb_namespaces[3]" should be undefined
  End

  It 'adds from multiple folders'
    _orb_libraries=( spec/fixtures/functions/call/namespace.sh/lib spec/fixtures/functions/call/namespace.sh/lib2 )
    When call _orb_collect_available_namespaces
    The variable "_orb_namespaces[0]" should eq a
    The variable "_orb_namespaces[1]" should eq b
    The variable "_orb_namespaces[2]" should eq c
    The variable "_orb_namespaces[3]" should eq d
    The variable "_orb_namespaces[4]" should eq e
    The variable "_orb_namespaces[5]" should eq f
    The variable "_orb_namespaces[6]" should be undefined
  End

  It 'can collect nested namespaces for a parent namespace path'
    _orb_libraries=( spec/fixtures/functions/call/namespace.sh/lib )
    When call _orb_collect_available_namespaces c
    The variable "_orb_namespaces[0]" should eq ca
    The variable "_orb_namespaces[1]" should eq cb
    The variable "_orb_namespaces[2]" should be undefined
  End
End

# _orb_collect_namespace_files
Describe '_orb_collect_namespace_files'
  It 'stores single _orb_namespace_file and tracks directory'
    _orb_libraries=( spec/fixtures/functions/call/namespace.sh/lib )
    _orb_namespace_name=a
    _orb_namespace_path=a
    When call _orb_collect_namespace_files
    The variable "_orb_namespace_files[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/lib/namespaces/a.sh"
    The variable "_orb_namespace_files_orb_dir_tracker[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/lib"
  End
  
  It 'stores directory with _orb_namespace_files and tracks directory'
    _orb_libraries=( spec/fixtures/functions/call/namespace.sh/lib )
    _orb_namespace_name=c
    _orb_namespace_path=c
    When call _orb_collect_namespace_files
    The variable "_orb_namespace_files[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/lib/namespaces/c/c.sh"
    The variable "_orb_namespace_files_orb_dir_tracker[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/lib"
  End

  It 'stores nested namespace files from nested namespace path'
    _orb_libraries=( spec/fixtures/functions/call/namespace.sh/lib )
    _orb_namespace_name=ca
    _orb_namespace_path=c/namespaces/ca
    When call _orb_collect_namespace_files
    The variable "_orb_namespace_files[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/lib/namespaces/c/namespaces/ca/ca.sh"
    The variable "_orb_namespace_files_orb_dir_tracker[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/lib"
  End
End

# _orb_get_current_namespace
Describe '_orb_get_current_namespace'
  _orb_get_current_namespace_from_args() { echo_fn && return 3; }
  _orb_get_current_namespace_from_file_structure() { echo_fn; }

  Context 'with _orb_sourced unset'
    It 'echoes output and returns status of _orb_get_current_namespace_from_args'
      When run _orb_get_current_namespace
      The status should equal 3
      The output should equal _orb_get_current_namespace_from_args
    End
  End

  Context 'with _orb_sourced'
    _orb_sourced=true

    It 'echoes output of _orb_get_current_namespace_from_file_structure and returns 1'
      When run _orb_get_current_namespace
      The status should equal 2
      The output should equal _orb_get_current_namespace_from_file_structure
    End
  End
End

# _orb_get_current_namespace_from_args
Describe '_orb_get_current_namespace_from_args'
  Context 'when namespace defined'
    It 'returns first argument as namespace'
      _orb_libraries=( spec/fixtures/functions/call/namespace.sh/lib )
      When call _orb_get_current_namespace_from_args a 1 2
      The status should be success
      The variable _orb_namespace_name should equal a
      The variable _orb_namespace_chain_name should equal a
    End

    It 'resolves nested namespace path and chain'
      _orb_libraries=( spec/fixtures/functions/call/namespace.sh/lib )
      _orb_collect_available_namespaces
      When call _orb_get_current_namespace_from_args c ca caa my_function
      The status should be success
      The variable _orb_namespace_name should equal caa
      The variable _orb_namespace_chain_name should equal "c ca caa"
      The variable _orb_namespace_path should equal c/namespaces/ca/namespaces/caa
      The variable "_orb_namespace_chain[@]" should equal "c ca caa"
    End
  End

  Context 'when namespace undefined'
    _orb_setting_help=false
    
    Context 'when $ORB_DEFAULT_NAMESPACE defined'
      ORB_DEFAULT_NAMESPACE=def_space

      It 'returns $ORB_DEFAULT_NAMESPACE'
        When call _orb_get_current_namespace_from_args hello 1 2
        The status should equal 2
        The variable _orb_namespace_name should equal def_space
        The variable _orb_namespace_chain_name should equal def_space
      End
    End

    Context 'without $ORB_DEFAULT_NAMESPACE'
      It 'raises error unless _orb_setting_help'
        _orb_raise_error() { echo_fn && exit 1; }
        _orb_setting_help=false
        When run _orb_get_current_namespace_from_args hello 1 2
        The status should equal 1
        The output should equal _orb_raise_error
      End

      It 'succeeds if _orb_setting_help'
        _orb_setting_help=true
        When run _orb_get_current_namespace_from_args hello 1 2
        The status should be success
      End
    End
  End
End

# _orb_get_namespace_shift_steps
Describe '_orb_get_namespace_shift_steps'
  It 'returns number of namespace chain items'
    _orb_namespace_chain=( a b c )
    When call _orb_get_namespace_shift_steps
    The output should equal 3
  End

  It 'returns zero when no chain items'
    _orb_namespace_chain=()
    When call _orb_get_namespace_shift_steps
    The output should equal 0
  End
End

# _orb_get_current_namespace_from_file_structure
Describe '_orb_get_current_namespace_from_file_structure'
  It 'can get namespace from filename'
    _orb_get_current_sourcer_file_path() { echo namespaces/test_namespace.sh; }
    When call _orb_get_current_namespace_from_file_structure
    The status should be success
    The variable _orb_namespace_name should equal test_namespace
    The variable _orb_namespace_chain_name should equal test_namespace
  End

  It 'can get namespace from nested files dirname'
    _orb_get_current_sourcer_file_path() { echo namespaces/test_namespace/namespaces/sub_namespace/nest_file.sh; }
    When call _orb_get_current_namespace_from_file_structure
    The status should be success
    The variable _orb_namespace_name should equal sub_namespace
    The variable _orb_namespace_chain_name should equal "test_namespace sub_namespace"
  End

  It 'fails if not found'
    _orb_get_current_sourcer_file_path() { echo random_dir/test_namespace/nest_file.sh; }
    When call _orb_get_current_namespace_from_file_structure
    The status should be failure
  End
End

# _orb_get_current_sourcer_file_path
Describe '_orb_get_current_sourcer_file_path'
  It 'gets path of sourcer file'
    _orb_source_trace=("$_orb_root/bin/orb" parent)
    When call _orb_get_current_sourcer_file_path
    The output should equal parent
  End
End

# _orb_validate_current_namespace
Describe '_orb_validate_current_namespace'
  _orb_raise_error() { echo_fn "$@"; exit 1; }

  It 'raises if present and not variable name'
    _orb_namespace_name="--asd"
    When run _orb_validate_current_namespace
    The status should be failure
    The output should eq "_orb_raise_error not a valid namespace name"
  End

  It 'does not raise if not present'
    _orb_namespace_name=""
    When run _orb_validate_current_namespace
    The status should be success
  End

  It 'does not raise if valid var name'
    _orb_namespace_name="my_namespace"
    When run _orb_validate_current_namespace
    The status should be success
  End
End
