Include functions/argument/positional.sh
Include functions/declaration/getters.sh
Include functions/declaration/checkers.sh
Include functions/argument/getters.sh
Include functions/utils/argument.sh
Include functions/utils/utils.sh
Include scripts/call/variables.sh


# _orb_set_function_positional_args
Describe '_orb_set_function_positional_args'
  _orb_declared_params=(4 6 -f 1 5 3 ... 2)
  _orb_args_values=(first second third fourth fifth sixth rest of args)
  declare -A _orb_args_values_start_indexes=([1]=0 [2]=1 [3]=2 [4]=3 [5]=4 [6]=5 [...]=6)
  declare -A _orb_args_values_lengths=([1]=1 [2]=1 [3]=1 [4]=1 [5]=1 [6]=1 [...]=3)

  It 'sets correct values to positional'
    When call _orb_set_function_positional_args
    The variable "_orb_args_positional[@]" should equal "first second third fourth fifth sixth rest of args"
  End
End
