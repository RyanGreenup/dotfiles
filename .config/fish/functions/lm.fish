# Defined in - @ line 1
function lm --wraps='latexmk -f -pdfxe -interaction=nonstopmode >&2 /dev/null ; latexmk -c' --description 'alias lm=latexmk -f -pdfxe -interaction=nonstopmode >&2 /dev/null ; latexmk -c'
  latexmk -f -pdfxe -interaction=nonstopmode >&2 /dev/null ; latexmk -c $argv;
end
