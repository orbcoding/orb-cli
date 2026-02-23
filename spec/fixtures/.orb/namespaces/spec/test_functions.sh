test_orb_print_args_orb=(
  "test_orb_print_args comment"
  flag = -f
  flagged_arg = -a 1
  verbose_flag = --verbose-flag 
  verbose_flagged_arg = --verbose-flagged 1 
  block = -b-
  dash_args = --  
  rest = ... Optional
); function test_orb_print_args() {
  source "$_orb_bin"
  orb_print_args
}

test_orb_print_args_input_args=( 
  -f 
  -a "Value flag" 
  --verbose-flag
  --verbose-flagged-arg "Verbose value flag"
  -b- block args -b-
  rest args
  -- dash args
)

# hej=function # another
# dude=caspita # dude

# test_orb_print_args_output='([--verbose-flag]="true" [-b-]="true" ["-a arg"]="flag" ["*"]="true" [-f]="true" ["-- *"]="true" ["--verbose-value flag"]="flagged_arg" )
# [-b-]=block args
# [*]=rest args
# [-- *]=dash rest args'

