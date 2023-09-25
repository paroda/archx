status is-login
and echo hi Developer!

# eliminate redundant paths in child shell
if [ -z $path_already_set ]
   set -gx PATH $HOME/.bin $HOME/.cargo/bin /opt/jdk-17/bin $PATH
   set -gx LD_LIBRARY_PATH /home/dipu/.sdk/mkl/lib:$LD_LIBRARY_PATH
   set -x path_already_set yes
end

set -gx PICO_SDK_PATH /home/dipu/my/pico/pico-sdk

set -gx fish_term24bit 1

############################################################
### aliases

alias aws "docker run --rm -it -v ~/.aws:/root/.aws -v (pwd):/aws amazon/aws-cli "
alias ec "emacsclient -n "

alias ls "eza --color=always --icons --group-directories-first --git"
alias ll "eza --color=always --icons --group-directories-first --git --long"
alias la "eza --color=always --icons --group-directories-first --git --long --all"

alias g-clj="grep -ri --color --include='*.clj' --include='*.cljs' --include='*.cljc'  --exclude-dir='*compiled*' --exclude-dir='*target*' --exclude-dir='*.shadow-cljs*'  --exclude-dir='*data*' "
alias g-edn="grep -ri --color --include='*.edn'  --exclude-dir='*compiled*' --exclude-dir='*target*' --exclude-dir='*.shadow-cljs*'  --exclude-dir='*data*' "

############################################################
# config for vterm inside emacs
if [ "$INSIDE_EMACS" = 'vterm' ]

set -x VISUAL "emacsclient -n"

### https://github.com/akermu/emacs-libvterm/blob/master/etc/emacs-vterm.fish
###
# Some of the most useful features in emacs-libvterm require shell-side
# configurations. The main goal of these additional functions is to enable the
# shell to send information to `vterm` via properly escaped sequences. A
# function that helps in this task, `vterm_printf`, is defined below.

function vterm_printf;
    if [ -n "$TMUX" ]
        # tell tmux to pass the escape sequences through
        # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
        printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
    else if string match -q -- "screen*" "$TERM"
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$argv"
    else
        printf "\e]%s\e\\" "$argv"
    end
end

# Completely clear the buffer. With this, everything that is not on screen
# is erased.

function clear
    vterm_printf "51;Evterm-clear-scrollback";
    tput clear;
end

# This is to change the title of the buffer based on information provided by the
# shell. See, http://tldp.org/HOWTO/Xterm-Title-4.html, for the meaning of the
# various symbols.
function fish_title
    # hostname
    # echo ":"
    # pwd
    set -l d (pwd)
    if test $d = '/'
        echo '/'
    else if test $d = $HOME
        echo '~'
    else
        string replace -r '(.+)?/' '' $d
    end
end

# With vterm_cmd you can execute Emacs commands directly from the shell.
# For example, vterm_cmd message "HI" will print "HI".
# To enable new commands, you have to customize Emacs's variable
# vterm-eval-cmds.
function vterm_cmd --description 'Run an Emacs command among the ones defined in vterm-eval-cmds.'
    set -l vterm_elisp ()
    for arg in $argv
        set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
    end
    vterm_printf '51;E'(string join '' $vterm_elisp)
end

# Sync directory and host in the shell with Emacs's current directory.
# You may need to manually specify the hostname instead of $(hostname) in case
# $(hostname) does not return the correct string to connect to the server.
#
# The escape sequence "51;A" has also the role of identifying the end of the
# prompt
function vterm_prompt_end;
    vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
end

# We are going to add a portion to the prompt, so we copy the old one
functions --copy fish_prompt vterm_old_fish_prompt

function fish_prompt --description 'Write out the prompt; do not replace this. Instead, put this at end of your file.'
    # Remove the trailing newline from the original prompt. This is done
    # using the string builtin from fish, but to make sure any escape codes
    # are correctly interpreted, use %b for printf.
    printf "%b" (string join "\n" (vterm_old_fish_prompt))
    vterm_prompt_end
end

end # end of INSIDE_EMACS vterm config
############################################################

if [ "$TERM" = "dumb" ]

function fish_prompt
    echo "> "
end

function fish_right_prompt; end
function fish_greeting; end
function fish_title; end

end
