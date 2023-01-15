#!/usr/bin/fish

set TASKS_DIR        "$HOME/Agenda/Agenda_Maybe/"
set Scheduled_Dir    $TASKS_DIR/Scheduled
set Projects_Dir     $TASKS_DIR/Projects
set ndays             300

function t
    cd $Scheduled_Dir
    set run_app true

    while $run_app

    set_color red
    echo "
    q quit
    "
    set_color normal
    echo "
    l tags          list available tags
    s Start         Start Zellij instance
    b broot         Start Zellij instance
    f files         Start lf
    y mdTree        Build a Markdown Tree
    e edit          Edit a task
    u Query         Query Tags
    a Add           Add a task
    c clean         Clean up empty directories
    m MakeDay       Make a directory for a day
    r reschedule    Reschedule a day
    d archive       Archive a task
    "
# Overdue?

        switch (read -n 1)
        case "q"
            set run_app false
        case "l"
            get_tags
        case "s"
            start
        case "b"
            cd $Scheduled_Dir
            br
        case "f"
            lfcd
        case "y"
            md_tree
        case "e"
            edit
        case "u"
            show_tags
        case "a"
            add
        case "c"
            __clear_tasks
        case "m"
            task_manager makeDay $Scheduled_Dir 300
        case "r"
            task_manager reschedule date (__choose_file) $Scheduled_Dir 300
        case "p"
            echo "
            t    tag       Re-tag all the tasks under the Projects Dir
            r    Refile    Refile a given task back into it's project
            "
            switch (read -n 1)
            case "t"
                task_manager project retag $Projects_Dir
            case "r"
                task_manager project refile (__choose_file) $Projects_Dir
            end
            case "d"
            task_manager archive (__choose_file)
            case "*"
            echo "Unbound Key"
        end
    end
end




function delete
    set file (__choose_file) && \
        rm $file
end

function overdue
echo "This is overdue"
end

function __id
    date -u "+%y%m%d%H%M"
end

# This clears any directories that are empty [1]
function __clear_tasks
    cd $TASKS_DIR
    find Scheduled -type d -empty -delete
end

# creates a new tafzf file
function add
    set done "X" # "⊠"
    set todo "O" # "□"
    echo  "Enter Details (C-c to Skip any)" && read -p "" -n 1; clear

    set date     (task_manager makeDay $Scheduled_Dir 300)
    set time     (__get_time)
    set priority (__print_alphabet | fzf)
    set title    (read -P "Title: ")

    set name (printf "%s %s !%s %s.md" $todo $time $priority $title)

    if test (read -n 1 -P "Create $date/$name? (y/n) >") = "y"
        printf "# %s\n#+ID: %s" $title (__id) > "$date/$name"
        nvim "$date/$name"
    end
end

function __print_alphabet
    for n in (seq 101 105  )
        printf '%b\n' \\$n
    end
end

function __get_time
    for b in (seq 5 20)
        printf "%02d00\n%02d30\n" $b $b
    end | fzf
end

function __choose_file
    cd $Scheduled_Dir
    fd -t f | fzf --preview 'bat {} --color always'
end

function get_id
    set file (__choose_file)
    grep '#+ID: ' $file | sed 's/#+ID: //g'
end

# taks a list of files and returns the unique tags
function get_tags
    cd $Scheduled_Dir
    set files (fd -t f)
    cat $files | rg ':([\w^:]+):' -r '$1' -o | sort -u
end

# Takes a list of tags and returns the files containing all of them
function get_files
set tags $argv
set files (rg -l ":$tag:")
for tag in $tags
    set files (cat $files | rg -l ":$tag:")
end
end

function query_tags
get_files (get_tags | fzf -m)
end

# show_tags_of_item
# show_items_with_tag
# Remove_tag_from_item

function edit
    set file (fd | fzf --preview 'bat {} --color always') && \
    nvim  $file
end

function md_tree
    tree -H '.' | pandoc -f html -t markdown  > tree.md
end

function start
    zellij --layout $TASKS_DIR/tool/agenda.kdl
end




## Showing Tags
set pattern '^:([\w\s/]+):'

function single_tags
    cd $TASKS_DIR
    # Single
    set tag (cat (fd -t f) | rg ':([\w^:]+):' -r '$1' -o | sort -u | fzf) && rg ":$tag:" -l | tree --fromfile
end

function multiple_tags
    cd $TASKS_DIR
    # set pattern ':([\w^:]+):'
    # Multiple
    # Choose possible tags
    set tags (cat (fd -t f '\.md$') | rg $pattern -r '$1' -o | sort -u | fzf -m)

    # Apply pattern for tags recursively
    printf "Selected tags:\n"
    set files (fd -t f)
    for tag in $tags
        printf "\r:$tag:\n"
        set files (rg ":$tag:"  $files -l)
    end

    # Use a loop to add new lines and print it with tree
    for file in $files
        echo $file
    end | tree --fromfile -CA

    # Print tags that are in those files as well
    printf "\nConcurrent Tags\n"
    # Get tags in those files
    cat $files | sort -u | rg $pattern -r '$1' -o
end


function show_tags_old
    while true
        read -n 1 -P "[SPC]" && multiple_tags || break
    end
end

function show_tags
    switch (read -n 1 -P  "Q to exit, any key to query")
    case "q"
        set run_app false
    case "*"
        task_manager tags query $Scheduled_Dir
    end
end

function add_tags
    cd $TASKS_DIR
    # Choose a file
    set file (__choose_file) && \
    # Choose some tags
    set tags (get_tags | fzf -m || read)

    # For each tag
    for tag in $tags
        # Put the colons around it
        set tag "\n:"$tag":"
        # Append only if the tag isn't in there
        rg $tag $file >/dev/null || \
            echo $tag >> $file
    end
end
