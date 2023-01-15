#!/usr/bin/fish

function main
    find_sync_con | bat
    echo "Remove Files y/n"
    if [ (read -n 1) = "y" ]
        rm (find_sync_con)
        echo "files removed"
    else
        echo "Skipped"
    end


    find_sync_tmp | bat
    echo "Remove Files y/n"
    if [ (read -n 1) = "y" ]
        rm (find_sync_tmp)
        echo "files removed"
    else
        echo "Skipped"
    end
end



function find_sync_tmp
    cd $HOME
    fd -H '\.syncthing.*tmp$'
end

function find_sync_con
    cd $HOME
    fd -H sync-conflict
end


main


## rm (fd -H sync-conflict)
## rm -f (fd -H '\.syncthing.*tmp$')
