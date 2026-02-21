Include functions/call/extensions.sh
Include functions/utils/file.sh
Include functions/utils/utils.sh

Describe 'orb_extensions.sh'
  It 'Collects orb extensions and parses their .env files'
    _orb_collect_orb_extensions() { echo_fn;}
    _orb_parse_env_extensions() { echo_fn;}
    When call source scripts/call/extensions.sh
    The output should equal "_orb_collect_orb_extensions
_orb_parse_env_extensions"
  End
End
