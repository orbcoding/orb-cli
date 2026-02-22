# orb

*In development*

`orb` is a CLI framework that helps you build self-documenting function libraries in bash. It removes the pain of parsing and validating advanced arguments and helps you organize your functions in namespaces based on a simple file structure.

`orb` can also be used to empower argument collection for individual functions in existing projects. See [individual function usage](#individual_function_usage).

`orb` is tested with [shellspec](https://github.com/shellspec/shellspec).


## Installation
```BASH
mkdir ~/.orb && cd ~/.orb
git clone https://github.com/orbcoding/orb.git

# Extend path in ~/.bashrc or ~/.zshrc
PATH=$PATH:~/.orb/orb/bin

# Now you can use the orb command
orb --help
```

## Self documenting library setup

1. Create an orb folder with a namespace file inside
```BASH
mkdir -p ~/.orb/namespaces
touch ~/.orb/namespaces/my_namespace.sh
chmod +x ~/.orb/namespaces/my_namespace.sh
```

2. Declare your function and arguments

```BASH
# ~/.orb/namespaces/my_namespace.sh

# my_function
my_function_orb=(
  "This is my function comment"

  1 = first "first inline argument"
  2 = second "second inline argument"
  -b = boolean "boolean flag"
  -f 1 = flag_arg 'flagged argument'
  -b- = block 'matches block between -b- ... -b-'
  ... = rest 'rest of arguments unless find --'
  -- = dash 'dash rest of arguments'
); function my_function() {
  echo $first
  echo $second
  echo $boolean
  echo $flag_arg
  echo "${block[@]}" # Stored in arrays
  echo "${rest[@]}"
  echo "${dash[@]}"
}
```

3. Call your function
```
$ orb my_namespace my_function arg_1 arg_2 -bf arg_f -b- my block args -b- first rest -- dash rest

arg_1
arg_2
true
arg_f
my block args
first rest
dash rest
```

4. Check documentation
```
$ orb --help my_namespace

-----------------  /home/user/.orb  
my_namespace.sh                      
  my_function                          

To show information about a function, use `orb --help "namespace" "function"`
```

```
$ orb --help my_namespace my_function

my_namespace->my_function - This is my function comment

        Required:  Default:  In:  Catch:  Multiple:  
  1     true       -         -    -       -          first inline argument
  2     true       -         -    -       -          second inline argument
  -b    false      false     -    -       -          boolean flag
  -f 1  false      -         -    -       -          flagged argument
  -b-   false      -         -    -       -          matches block between -b- ... -b-
  ...   true       -         -    -       -          rest of arguments unless find --
  --    true       -         -    -       -          dash rest of arguments
```
---

## Argument options
Here is a more advanced argument declaration

```BASH
 my_function_orb=(
  1 = first "first inline argument"
    Required: false
  2 = second "second inline argument"
    Default: accepted_value
    In: accepted_value another_accepted_value
  --verbose-flag = boolean "boolean flag"
    Required: true
    Multiple: true
  -f 1 = flag_arg 'flagged argument'
    Default: 
      IfPresent: '$var1 || $var2 || fallback'
      Help: 'Some helping text'
    Catch: any
 ); 
 function my_function() { ... }
```
 Note the available argument options
 - `Required:`
    - number, rest and dash arguments are required unless set `Required: false` or `Default:` 
    - Flag and block args are optional unless set `Required: true`
 - `In:` specifies a list of accepted values.
 - `Default:` specifies a default value. Also has nested options: 
   - `IfPresent:` Evaluates to first present variable or string.
   - `Help:` Help text for documentation.
 - `Catch:` Allows argument to assign undeclared special arguments, preventing orb from raising undeclared argument error. Available values: `any flag block dash`.

Note also:
 - If flags are single char you can pass multiple flag statements such as `-fa`.
 - Calling `orb my_function +f` sets its value to  `false`. This is useful if in combination with `Default: true`.
- Numbered args and rest args also passed as inline args to function call.
 This allows expected argument access from bash positional arguments eg: `$1`, `$2`, `$@/$*`.

---
## orb folders

  - `~/.orb` - is user global orb folder. Which can be extended by any number of the following two folders found below you in the file system. This makes it easy to add project specific libraries.
  - `.orb`
  - `_orb`

## Namespaces
Your namespaces are defined inside your orb folders. Either by a single file or a folder with multiple files
  - `.orb/namespaces/my_namespace.sh`
  - `.orb/namespaces/my_namespace/file.sh`

<!-- ### Core namespace
- `orb core --help` lists all core functions.
- All core functions can be called directly from within your own orb functions without orb prefix.

Some useful functions
- `orb_print_args` - prints received args after parsing
- `orb_pass` - pass recevied args to array if received. Useful for creating command interfaces.
- `orb_raise_error` - raises formatted error and kills script -->


  

### Presource
If using a dedicated namespace folder you can also add
  - `.orb/namespaces/my_namespace/.presource.sh` - will be sourced before functions in your namespace are called
- `.orb/.env` - will be parsed into your scripts as exported variables.
- Core uses following `.env` vars
  - `ORB_DEFAULT_NAMESPACE` - if set to `my_namespace`, you can call `orb my_function` directly.


## Functions

Functions callable through orb and listed in help - aka. "`public functions`" - have to be declared inside your namespace files with `function` prefix and `()` suffix. If not it will be considered a "`private function`" that is used internally in the file.


---

## <a name="individual_function_usage"></a> Individual function usage

```BASH
# Create a script:
touch my_script.sh && chmod +x my_script.sh

# my_script.sh
my_fn_orb=(
  1 = first
  -b = boolean
  -f 1 = flag_arg
  ... = rest
) 
function my_fn() {
  source /path/to/orb-cli/bin/orb
  echo $first
  echo $boolean
  echo $flag_arg
  echo "${rest[@]}"
}

# cmdline
# Make sure we're running bash when sourcing orb in this way
# With the library setup orb can be called from any shell
exec bash 
source my_script.sh && my_fn first -b -f flag rest of args
# =>
first
true
flag
rest of args
```



