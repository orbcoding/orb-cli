_orb_root=$(pwd)
Include functions/call/help_function.sh
Include functions/utils/utils.sh
Include scripts/initialize.sh
Include functions/utils/text.sh

Describe '_orb_print_function_help'
  Include "$_orb_root/scripts/call/variables.sh"

  It 'prints full help output with all sections and all types of parameters'
    _orb_function_descriptor='docker -> start'

    # Massive declaration with extremes
    _orb_function_declaration=(
      "Start docker containers"
      
      Description: "Start docker containers with various options"

      1 = action
        "action to perform"
        Required: true
        Default: start
        In: start stop restart

      -e\|--environment 1 = env
        "environment"
        Default: IfPresent: '$ORB_DEFAULT_ENV || development'
        In: production staging development

      -b = force
        "force mode"
        Default: true

      -i = idle
        "idle mode"
        Default: false

      -r = restart
        "restart mode"
        Required: true

      -t 2 = tags
        "tags list"
        Multiple: true
        Default: alpha beta

      -d- = compose_opts
        "docker compose opts"
        Multiple: true
        Default: '--ansi never'

      -o-\|--up-options-- = up_opts
        "docker compose up options"
        Multiple: false

      -- = passthrough
        "passthrough opts"
        Default: '--verbose'

      ... = rest
        "remaining args"
        Catch: any
        Default: IfPresent: '$ORB_REST_DEFAULT || --fallback'

      # Extreme cases
      -x = experimental
        "experimental flag"
        Default: false

      -y 1 = yes_flag
        "yes flag with one value"
        Multiple: false
        Default: yes

      -z 3 = z_values
        "z multi-value test"
        Multiple: true
        Default: a b c
    )

    parse() {
      _orb_parse_function_declaration
      _orb_print_function_help
    }

    When call parse
    # Sections
    The output should equal 'NAME
    orb docker start - Start docker containers

SYNOPSIS
    orb docker start action -r [-bix] [-e <env>] [-t <tags>{2}...] [-y <yes_flag>] [-z <z_values>{3}...] [-d- <compose_opts>... -d-]... [-o- <up_opts>... -o-] [args...] [-- <passthrough>]

DESCRIPTION
    Start docker containers with various options

PARAMETERS
    action
        action to perform
        Required:  yes
        Default:   start
        In:        start | stop | restart

    -r
        restart mode
        Required:  yes

    -b
        force mode
        Default:  true

    -i
        idle mode

    -x
        experimental flag

    -e, --environment <env>
        environment
        Default:  development
        Resolve:  $ORB_DEFAULT_ENV || development
        In:       production | staging | development

    -t <tag>{2}
        tags list
        Default:   alpha beta
        Multiple:  yes

    -y <yes_flag>
        yes flag with one value
        Default:  yes

    -z <z_value>{3}
        z multi-value test
        Default:   a b c
        Multiple:  yes

    -d- <compose_opts> -d-
        docker compose opts
        Default:   --ansi never
        Multiple:  yes

    -o-, --up-options-- <up_opts> -o-
        docker compose up options

    ...
        remaining args
        Required:  yes
        Default:   --fallback
        Resolve:   $ORB_REST_DEFAULT || --fallback

    --
        passthrough opts
        Default:  --verbose'
  End
End
