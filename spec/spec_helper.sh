# shellcheck shell=sh

# Defining variables and functions here will affect all specfiles.
# Change shell options inside a function may cause different behavior,
# so it is better to set them here.
# set -eu

# This callback function will be invoked only once before loading specfiles.
spec_helper_precheck() {
  # Available functions: info, warn, error, abort, setenv, unsetenv
  # Available variables: VERSION, SHELL_TYPE, SHELL_VERSION
  : minimum_version "0.28.1"
  if [ "$SHELL_TYPE" != "bash" ]; then
    abort "Only bash is supported."
  fi
}

# This callback function will be invoked after a specfile has been loaded.
spec_helper_loaded() {
  :
}

# This callback function will be invoked after core modules has been loaded.
spec_helper_configure() {
  # Available functions: import, before_each, after_each, before_all, after_all
  : import 'support/custom_matcher'
}

# _orb_root=''
spec_orb='spec/fixtures/.orb'
_orb_root=$spec_orb/orb
spec_proxy='spec/fixtures/proxy.sh'

echo_fn() {
  local output=("${FUNCNAME[1]}")
  (( "$#" >= 0 )) && output+=("$@")
  echo "${output[@]}"
}

_orb_in_running_test=true
