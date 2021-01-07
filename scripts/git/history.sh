declare -A forget_args=(
  ['1']='file to forget'
); function forget() { # Forget file from history
	is_git_repo || exit 0
	path=${args[0]}
	if [ -z $path ]; then
		echo 'No path supplied'
		exit 1
	elif [ -e "$path" ]; then
		echo -n "Forget ${path}? y/n: "
		read reply
	else
		echo 'File does not exist'
		exit 1
	fi;

	if [[ $reply == 'y' ]]; then
		echo "Forgetting ${path}"
		git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch ${path}" HEAD
	fi
}