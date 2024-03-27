cmd_var_check =$(if $($1),,$(error $1 not defined. Must pass $1 $2))
