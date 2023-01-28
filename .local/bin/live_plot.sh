#!/bin/sh


# use fzf to choose a file and return the string in a variable x
x=$(fd '\.dat$' /tmp | fzf --preview 'gnuplot -e "set terminal dumb; plot '{}' with lines"')
echo "$x"

# Have gnuplot make a plot of the file
gnuplot_file="/tmp/live_plot.gnuplot"
printf "plot '%s' with lines; pause 0.1; reread" "$x" > "${gnuplot_file}"
gnuplot "${gnuplot_file}"

echo


