#!/bin/bash
# Don't forget to adjust the permissions with:
#chmod +x ~/somecrazyfolder/script1
TEMP_DIR="/tmp/cadmus_rofi_preview"
mkdir -p "${TEMP_DIR}"


readonly script_name=$(basename "${0}")
script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly script_dir=$(realpath "${script_dir}""/""${script_name}" | xargs dirname)

## Program


### Description
# This will print 'Hello World' to the STDOUT.

### Code
#!/bin/bash
cd /tmp/
main () {
	local selected
	local string
	selected="${1}"

	schemes="$(i3-instant-layout --list)"
	lines=$(printf '%s\n' "${schemes}" | wc -l)
	menu=$(printf '%s\n' "${schemes}"  | rofi -matching fuzzy -width -30 -location 1 -kb-row-up "" -kb-row-down "" -kb-custom-1 "Up" -kb-custom-2 "Down" -format 'd:s' -dmenu -selected-row $selected)

	exit_code=$?

	selected="${menu%:*}"
	string="${menu##*:}"
	PRINT_OUT () {
	    i3-instant-layout "${@:-}"
	}

	# I took this bit from https://github.com/davatorium/rofi/issues/997
		#  Not totally sure how it works but it does :shrug

	case "${exit_code}" in
		"1") echo "${FILEPATH}" && exit 0;;
		"0") PRINT_OUT "${string}" ;;
		"10")
			if [[ $selected == "1" ]]; then
				foo_selected="${lines}"
				call="3"
			else
				foo_selected="$(echo -e $(( ${selected} - 1 )))";
				call=$(echo $(( ${selected} - 2 )))
			fi
			foo="$(printf '%s' "${schemes}" | sed -n "${foo_selected}"p)";
			PRINT_OUT "${foo}" ;;
		"11")
			if [[ "${selected}" -ge "${lines}" ]]; then
				foo_selected="1"
				call="0"
			else
				foo_selected="$(echo -e $(( ${selected} + 1 )))";
				call="${selected}"
			fi
			foo="$(printf '%s' "${schemes}" | sed -n "${foo_selected}"p)";
			PRINT_OUT "${foo}"
	esac

	main "${call}"
}

main 0
	echo "${string}"


## vim:fdm=expr:fdl=0
## vim:fde=getline(v\:lnum)=~'^##'?'>'.(matchend(getline(v\:lnum),'##*')-2)\:'='

