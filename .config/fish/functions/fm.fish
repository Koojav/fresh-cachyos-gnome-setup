# Simple file browser that utilizes lists

function fm
    while true
        set selected (ls -al | fzf --ansi | awk '{print $NF}')
        if test -z "$selected"
            return 0
        end
        if test -d "$selected"
            cd $selected
        else
            nano $selected
        end
    end
end
