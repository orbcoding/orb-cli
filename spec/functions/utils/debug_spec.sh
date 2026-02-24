Include functions/utils/debug.sh

Describe 'orb_ee'
	It 'outputs to stderr'
    When call orb_ee text
    The error should equal text
  End
End

Describe 'orb_print_args'
  spec_fn_orb=(
    1 = first "first comment"
      Required: false
    -f = flag "flag comment"
    -a 1 = flag_arg "flag arg comment"
    -b- = block "block comment"
    --verbose-flag = verbose_flag "verbose flag comment"
    ... = rest "rest comment"
      Required: false
    -- = dash "dash comment"
      Required: false
  )
  spec_fn() {
    source "$_orb_bin"
    orb_print_args
  }

  It 'prints args'
    When call spec_fn
    The line 4 of output should include "  1               first"
    The line 5 of output should include "  -f              flag          false"
    The line 6 of output should include "  -a 1            flag_arg"
    The line 7 of output should include "  -b-             block"
    The line 8 of output should include "  --verbose-flag  verbose_flag  false"
    The line 9 of output should include "  ...             rest"
    The line 10 of output should include "  --              dash"
  End
End
