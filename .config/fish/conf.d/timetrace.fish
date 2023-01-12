function tts
    echo "
    q quit
    c create      Create a new resource
    d delete      Delete a resource
    e edit        Edit a resource
    g get         Display a resource
    h help        Help about any command
    l list        List all resources
    t start       Start tracking time
    S status      Display the current tracking status
    p stop        Stop tracking your time
    "

    read -n 1 x
    switch $x
    case "q"
        return
    case "c"
        echo "
            p project     Create a new project
            r record      Create a new record
            h help
        "
        switch (read -n 1)
        case "p"
            timetrace create project (read -P "Enter Project name =module@project=: ")
        case "r"
            timetrace create record        \
                (__pick_project)           \
                (__pick_when)              \
                (__pick_time "Start time") \
                (__pick_time "End time")
        case "*"
        end
        timetrace create
    case "d"
        timetrace delete
    case "e"
        timetrace edit
    case "g"
        timetrace get
    case "h"
        timetrace help
    case "l"
        timetrace list
    case "t"
        timetrace start
    case "S"
        timetrace status
    case "p"
        timetrace stop
        case "*"
            echo "Unrecognised command, Try again"
            tts
        end
end

function __pick_project
    set projects (ls ~/.timetrace/projects/ | rev | sed 's/nosj.//' | rev)
    echo $projects | tr ' ' '\n' | fzf || \
        read -P "Type a Project Name: "
end

function __pick_when
    printf "%s\n%s" today yesterday | fzf || read -P "Enter date (YYYY-MM-DD): "
end

function _fz
    fzf --height 30 $argv

end

function __pick_time
    echo $argv
    set hour (seq 0 24 | _fz | xargs printf "%02d")
    set min (seq 0 60  | _fz | xargs printf "%02d")
    echo $hour:$min
end

# switch (read -n 1)
# case "a"
# case "*"
# end



