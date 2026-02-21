Include functions/utils/text.sh

Describe 'orb_upcase'
  It 'upcases text'
    When call orb_upcase text
    The output should equal TEXT
  End
End
