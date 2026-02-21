Include functions/call/namespace.sh
Include functions/utils/text.sh
Include functions/utils/utils.sh
Include functions/utils/argument.sh

# _orb_collect_namespaces
Describe '_orb_collect_namespaces'
  It 'finds namespaces in orb folders'
    _orb_extensions=( spec/fixtures/functions/call/namespace.sh/ext )
    When call _orb_collect_namespaces
    The variable "_orb_namespaces[0]" should eq namespace1
    The variable "_orb_namespaces[1]" should eq namespace2
    The variable "_orb_namespaces[2]" should eq namespace3
    The variable "_orb_namespaces[3]" should be undefined
  End

  It 'adds each once'
    _orb_extensions=( spec/fixtures/functions/call/namespace.sh/ext spec/fixtures/functions/call/namespace.sh/ext )
    When call _orb_collect_namespaces
    The variable "_orb_namespaces[0]" should eq namespace1
    The variable "_orb_namespaces[1]" should eq namespace2
    The variable "_orb_namespaces[2]" should eq namespace3
    The variable "_orb_namespaces[3]" should be undefined
  End

  It 'adds from multiple folders'
    _orb_extensions=( spec/fixtures/functions/call/namespace.sh/ext spec/fixtures/functions/call/namespace.sh/ext2 )
    When call _orb_collect_namespaces
    The variable "_orb_namespaces[0]" should eq namespace1
    The variable "_orb_namespaces[1]" should eq namespace2
    The variable "_orb_namespaces[2]" should eq namespace3
    The variable "_orb_namespaces[3]" should eq namespace21
    The variable "_orb_namespaces[4]" should eq namespace22
    The variable "_orb_namespaces[5]" should eq namespace23
    The variable "_orb_namespaces[6]" should be undefined
  End
End

# _orb_collect_namespace_files
Describe '_orb_collect_namespace_files'
  It 'stores single _orb_namespace_file and tracks directory'
    _orb_extensions=( spec/fixtures/functions/call/namespace.sh/ext )
    _orb_namespace=namespace1
    When call _orb_collect_namespace_files
    The variable "_orb_namespace_files[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/ext/namespaces/namespace1.sh"
    The variable "_orb_namespace_files_orb_dir_tracker[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/ext"
  End
  
  It 'stores directory with _orb_namespace_files and tracks directory'
    _orb_extensions=( spec/fixtures/functions/call/namespace.sh/ext )
    _orb_namespace=namespace3
    When call _orb_collect_namespace_files
    The variable "_orb_namespace_files[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/ext/namespaces/namespace3/namespace3.sh"
    The variable "_orb_namespace_files_orb_dir_tracker[@]" should eq "\
spec/fixtures/functions/call/namespace.sh/ext"
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
  _orb_namespaces=( test_namespace )

  Context 'when namespace defined'
    It 'returns first argument as namespace'
      When call _orb_get_current_namespace_from_args test_namespace 1 2
      The status should be success
      The variable _orb_namespace should equal test_namespace
    End
  End

  Context 'when namespace undefined'
    _orb_setting_help=false
    
    Context 'when $ORB_DEFAULT_NAMESPACE defined'
      ORB_DEFAULT_NAMESPACE=def_space

      It 'returns $ORB_DEFAULT_NAMESPACE'
        When call _orb_get_current_namespace_from_args hello 1 2
        The status should equal 2
        The variable _orb_namespace should equal def_space
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

# _orb_get_current_namespace_from_file_structure
Describe '_orb_get_current_namespace_from_file_structure'
  It 'can get namespace from filename'
    _orb_get_current_sourcer_file_path() { echo namespaces/test_namespace.sh; }
    When call _orb_get_current_namespace_from_file_structure
    The status should be success
    The variable _orb_namespace should equal test_namespace
  End

  It 'can get namespace from nested files dirname'
    _orb_get_current_sourcer_file_path() { echo namespaces/test_namespace/nest_file.sh; }
    When call _orb_get_current_namespace_from_file_structure
    The status should be success
    The variable _orb_namespace should equal test_namespace
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
    _orb_namespace="--asd"
    When run _orb_validate_current_namespace
    The status should be failure
    The output should eq "_orb_raise_error not a valid namespace name"
  End

  It 'does not raise if not present'
    _orb_namespace=""
    When run _orb_validate_current_namespace
    The status should be success
  End

  It 'does not raise if valid var name'
    _orb_namespace="my_namespace"
    When run _orb_validate_current_namespace
    The status should be success
  End
End
