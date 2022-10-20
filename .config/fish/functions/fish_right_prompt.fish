function my_cur_dir
    set -l cur_dir (pwd)
    if test $cur_dir = '/'
        set cur_dir '/'
    else if test $cur_dir = $HOME
        set cur_dir '~'
    else
        set cur_dir (string replace -r '(.+)?/' '' $cur_dir)
    end
    echo $cur_dir
end

function my_git_prompt --description 'short status of git vcs'
    # branch with clean/staged/dirty

    set -l root_path (git rev-parse --show-toplevel 2>/dev/null)
    set -l root '~'
    test "$root_path" != $HOME
    and set root (string replace -r '(.*/)*' '' $root_path)
    set -l git_root (set_color 996)" "$root

    set -l br (git symbolic-ref --short HEAD 2>/dev/null;
    or git show-ref --head -s --abbrev | head -n1 2>/dev/null)
    set br (string replace -ar '(\w)[^/]+/' '$1/' $br)
    set -l branch (set_color 66c)" $br"

    test (git status -bs 2>/dev/null | grep -E '^[^ ?]' | wc -l) -gt 1
    and set -l has_staged

    test (git status -bs 2>/dev/null | grep -E '^.\S' | wc -l) -gt 1
    and set -l has_dirty

    if set -q has_dirty
        if set -q has_staged
            set branch (set_color c66)" $br "(set_color 6c6)" "
        else
            set branch (set_color c66)" $br "
        end
    else if set -q has_staged
        set branch (set_color 6c6)" $br "
    end

    set -l commits ''
    git rev-parse --abbrev-ref '@{upstream}' &>/dev/null; and set -l has_upstream
    if set -q has_upstream
        set -l commit_counts (git rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
        set -l commits_to_push (echo $commit_counts | cut -f 1 2>/dev/null)
        set -l commits_to_pull (echo $commit_counts | cut -f 2 2>/dev/null)

        if [ $commits_to_push != 0 ]
            set commits "$commits"(set_color 3c3) ""$commits_to_push
        end
        if [ $commits_to_pull != 0 ]
            set commits "$commits"(set_color c33) ""$commits_to_pull
        end
    end

    set -l git_repo (set_color -o 888) "" # \ue0a0 #\u2387

    test (git stash list | wc -l) -gt 0
    and set -l git_stash (set_color 696) " "  # has stash

    set -l cur_dir (readlink -f (pwd))
    if test $cur_dir = "$root_path"
        set cur_dir ""
    else
        set cur_dir " "(set_color $fish_color_cwd)" "(my_cur_dir)
    end

    echo -n -s "$git_root$cur_dir$git_repo$branch$git_stash$commits"
end

function my_vcs_prompt --description 'short status of git vcs if git'
    set -l is_git_repository (git rev-parse --is-inside-work-tree 2>/dev/null)
    if test -n "$is_git_repository"
        my_git_prompt
    else
        set -l repo (__fish_vcs_prompt)
        test "x$repo" = "x"
        or echo -n -s (set_color -o 888)""(set_color 66c)$repo" "
        echo -n -s (set_color $fish_color_cwd)" "(my_cur_dir)
    end
end

function fish_right_prompt -d "Write out the right prompt"
    set -l exit_code $status
    set -l bg 112233

    set_color $bg
    # echo -n -s \u2591\u2592\u2593
    # echo -n -s "" # \ue0b6
    # echo -n -s "" # \ue0ba
    echo -n -s "" # \ue0be
    set_color -b $bg

    # indicate if inside home or outside
    # test (count (string match -r "^$HOME(\$|/)" (pwd))) -ne 0
    # and echo (set_color green)\u2605" "
    # or echo (set_color -o yellow)\u26a0" "
    if test (count (string match -r "^$HOME(\$|/)" (pwd))) -ne 0
        echo -n -s (set_color -o 696)" "
    else
        echo -n -s (set_color -o 966)" " # " "
    end
    set_color normal
    set_color -b $bg

    # Print a yellow fork symbol when in a subshell
    set -l max_shlvl 1
    # test $TERM = "screen"; and set -l max_shlvl 3
    # test $TERM = "xterm-256color"; and set -l max_shlvl 3
    # test $TERM = "st-256color"; and set -l max_shlvl 3
    test "$INSIDE_EMACS" = "vterm"; and set -l max_shlvl 2
    if test $SHLVL -gt $max_shlvl
        echo -n -s (set_color yellow) \u2325 "  "
    end

    # Print in red exit_code for failed commands.
    if test $exit_code -ne 0
        echo -n -s (set_color red)" $exit_code "
    end

    echo -n -s (set_color normal)(set_color -b $bg)
    echo -n -s (my_vcs_prompt)(set_color normal)(set_color $bg)"" # \ue0b4
    set_color normal
end
