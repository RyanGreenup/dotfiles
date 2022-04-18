# Defined in - @ line 1
function b --wraps=echo\ -e\ \"enter\ brightness:\\n\"\;\ read\ val\;\ xrandr\ \ --output\ DP-2\ --brightness\ \$val\ --output\ HDMI-0\ --brightness\ \$val\ --output\ HDMI-1\ \ --brightness\ \$val --description alias\ b=echo\ -e\ \"enter\ brightness:\\n\"\;\ read\ val\;\ xrandr\ \ --output\ DP-2\ --brightness\ \$val\ --output\ HDMI-0\ --brightness\ \$val\ --output\ HDMI-1\ \ --brightness\ \$val
  echo -e "enter brightness:\n"; read val; xrandr  --output DP-2 --brightness $val --output HDMI-0 --brightness $val --output HDMI-1  --brightness $val $argv;
end
