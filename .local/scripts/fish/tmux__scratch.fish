#!/usr/bin/fish

set session_name scratch

if tmux has-session -t $session_name
    tmux attach-session -t $session_name
else
    tmux new-session -d -s $session_name
end
