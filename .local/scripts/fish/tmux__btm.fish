#!/usr/bin/fish

set session_name system-monitor

if tmux has-session -t $session_name 
    tmux attach-session -t $session_name 
else
    tmux new-session -d -s $session_name
    # run btm in the first window
    tmux send-keys -t $session_name 'htop' Enter
    # create a new window and run htop in it
    tmux new-window -t $session_name 
    tmux send-keys -t $session_name 'btm' Enter 
    tmux attach-session -t $session_name 
end
