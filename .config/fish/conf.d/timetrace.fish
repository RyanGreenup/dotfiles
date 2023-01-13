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
                (__pick_time) \
                (__pick_time)
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
    case "r"
        echo "
        Generate a Report

        r all
        p Project
        d Dates"
        switch (read -n 1)
        case "r"
            timetrace report
        case "p"
            timetrace report --project (__pick_project)
        case "d"
            echo "Enter Start date"
            set s (__pick_date)
            echo "Enter end date"
            set e (__pick_date)
            timetrace report \
                --start  $s\
                --end    $e
        case "*"
        end
        case "*"
            echo "Unrecognised command, Try again"
            tts
    end
end

# TODO creating a new project with spaces leads to the creation of two projects
function __pick_project
    ls ~/.timetrace/projects/ | grep -v '.bak' | rev | sed 's/nosj.//' | rev | _fz || \
        read -P "Type a Project Name: "
end

function __pick_when
    printf "%s\n%s" today yesterday | fzf || read -P "Enter date (YYYY-MM-DD): "
end

function _fz
    fzf --height 30 $argv

end

function __pick_time
    set hour (seq 0 24 | _fz | xargs printf "%02d")
    set min (seq 0 60  | _fz | xargs printf "%02d")
    echo $hour:$min
end

function __pick_date
    set n_d 90
    set inc 86400 # (24 * 60 * 60)

    set now (date "+%s") ## TODO n_d days ago
    set now (math "$now - $n_d * $inc")
    set end (math "($n_d * 2 * $inc) + $now")

    for d in (seq  $now $inc $end)
        echo (date -d "@"$d "+%Y-%m-%d")
    end |  _fz --preview 'cal -w --color=always {}'
end

# switch (read -n 1)
# case "a"
# case "*"
# end


