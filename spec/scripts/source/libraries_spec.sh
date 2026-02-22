Include functions/call/libraries.sh
Include functions/utils/file.sh
Include functions/utils/utils.sh

Describe 'orb_libraries.sh'
  It 'Collects orb libraries and parses their .env files'
    _orb_collect_orb_libraries() { echo_fn;}
    _orb_parse_libraries_dotenv() { echo_fn;}
    When call source scripts/call/libraries.sh
    The output should equal "_orb_collect_orb_libraries
_orb_parse_libraries_dotenv"
  End
End
