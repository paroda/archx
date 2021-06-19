function fish_prompt --description 'Write out the prompt'
    #echo -n -s $normal "   "
    # echo $normal " "
    set -l fg f6f
    set -l bg 112233 # 03d
    set -l lg 3399ff
    echo -n -s (set_color $bg)""
    # echo -n -s (set_color $bg)""
    echo -n -s (set_color -o -b $bg $lg)"  "
    # echo -n -s (set_color -b normal $bg)" "
    echo -n -s (set_color -b normal $bg)""
    # echo -n -s (set_color -b normal $bg)""
    # echo -n -s (set_color $fg)"λ"
    echo -n -s (set_color normal)" "
end
