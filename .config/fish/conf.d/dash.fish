#!/usr/bin/fish

function dashboard
    set run_app true

    while $run_app

        set_color red
        echo "
    q quit
    "
        set_color normal
        echo "
    c link          Copy a file link to the clipboard
    "
        # Overdue?

        switch (read -n 1)
            case q
                set run_app false
            case c
                echo "
            Tags
            q    Quit
            p    PDF files
            c    anything
            h    hidden
            "
                switch (read -n 1)
                    case q
                        echo ""
                    case c
                        copy_links
                    case p
                        copy_links pdf
                    case "*"
                        echo "Unbound Key"
                end
        end
    end
end

function Q
    set run_app false
end


function copy_links
    switch $argv[1]
        case pdf
            echo a
            fd -t f '\.pdf$' | fzf | clip copy
        case hidden
            fd -HI -t f | fzf | clip copy
        case case "*"
            fd -t f | fzf | clip copy
    end
    set run_app false
end


function delete
    set file (__choose_file) && rm $file
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
    set done X # "⊠"
    set todo O # "□"
    echo "Enter Details (C-c to Skip any)" && read -p "" -n 1
    clear

    set date (task_manager makeDay $Scheduled_Dir 300)
    set time (__get_time)
    set priority (__print_alphabet | fzf)
    set title (read -P "Title: ")

    set name (printf "%s %s !%s %s.md" $todo $time $priority $title)

    if test (read -n 1 -P "Create $date/$name? (y/n) >") = y
        printf "# %s\n#+ID: %s" $title (__id) >"$date/$name"
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
    set file (fd | fzf --preview 'bat {} --color always') && nvim $file
end

function md_tree
    tree -H '.' | pandoc -f html -t markdown >tree.md
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

function clip
    if set -q WAYLAND_DISPLAY
        set display wayland
    else if test $XDG_SESSION_TYPE = wayland
        set display wayland
    else if set -q DISPLAY
        set display x11
    else if test (uname) = Darwin
        set display mac
    else
        echo "Unable to detect display"
    end

    switch $argv[1]
        case copy
            switch $display
                case wayland
                    wl-copy
                case x11
                    xclip -sel clip
                case mac
                    pbcopy
            end
        case paste
            switch $display
                case wayland
                    wl-paste
                case x11
                    xclip -sel clip -o
                case mac
                    pbpaste
            end
    end
end

function show_tags_old
    while true
        read -n 1 -P "[SPC]" && multiple_tags || break
    end
end

function show_tags
    switch (read -n 1 -P  "Q to exit, any key to query")
        case q
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
        rg $tag $file >/dev/null || echo $tag >>$file
    end
end
