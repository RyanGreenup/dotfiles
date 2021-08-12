#!/bin/bash
# * Preamble
    readonly script_name=$(basename "${0}")
             script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    readonly script_dir=$(realpath "${script_dir}""/""${script_name}" | xargs dirname)
# * Check Arguments and write Permissions

if [[ "${1}" == "--help" || "${1}" == "-h" ]]; then
    echo -e "First argument should be a HTML File in the current directory"
    echo -e "Second argument is optional and should be the namespace HTML File"
    echo -e "\tDownloaded with Firefox Worked for me"
    echo -e "This script will take a HTML file and return a data directory that can be merged"
    echo -e "with dokuwiki such that relative path images will work"
    exit 0
elif [[ "${1}" == "" ]]; then
    echo -e "\n Please provide the HTML File as the first argument\n"
    "${script_dir}"/"${script_name}" -h
    exit 0
elif [[ ! -f "${1}" ]]; then
    echo "Cannot detect any file by that name in this directory"
    exit 0
else
    # Make a working directory
    DIR="$(mktemp -d)"

    # Fix the name if it has whitespace or caps
    NAME="$(echo "${1}" | tr '\ ' '_' | tr 'A-Z' 'a-z' | cut -f 1 -d '.')"

    # Set the namespace var
    if [[ -z "${2}" ]]; then
        NSPC=""
    else
        NSPC="$(echo ${2} | tr '\ ' '_' | tr 'A-Z' 'a-z')"
    fi

    # Get the Name of the Input File
    INPUT_NAME_ORIG="$(basename "${1}")"
fi

#############################################################
# * Convert the Material
#############################################################
# ** Copy the HTML into a Rel Dir
# Extract the media of th HTML File
# Change into the directory of the Input file or pandoc won't find relative media
cd "$(dirname "${1}")"
pandoc "${INPUT_NAME_ORIG}" --extract-media="${DIR}" -o "${DIR}/${NAME}.html"
cd "${DIR}"
# ** Convert the HTML File into Dokuwiki
# Call Pandoc
pandoc "${NAME}.html" --extract-media='./' -f html -t dokuwiki -o "${NAME}.txt" && rm "${NAME}.html" || { echo "Pandoc Error" ; exit 0; }

# Make the Directories
mkdir -p data/media/ data/pages

# Move the Text File into the Directory
mv "${NAME}.txt" data/pages/

# Move Everything else into the Media Directory
find ./ -maxdepth 1  -not -type 'd' -exec mv {} data/media/ \;

# Print the Directory and Layout
pwd
tree
##############################################################
# * Copy the data into Dokuwiki
##############################################################
# ** Should the user continue?
echo -e "Would you like to sudo copy this file into /srv/http/dokuwiki? as root"
echo -e "This will alsow chown -R http:http /srv/http/dokuwiki \n"
echo -e "Press y to continue and any other key to exit"
read -d '' -s -n1 continueQ
if [ ! "${continueQ}" == "y" ]; then
echo -e "Exported Data Directory Available in:\n ${DIR}"
    exit 0
fi
# ** Copy the files across
# Merge the data directory with the dokuwiki one
sudo chown http:http -R data
sudo cp -r data/ /srv/http/dokuwiki/

## ** Reindex the pages
sudo php /srv/http/dokuwiki/bin/indexer.php     && echo "Re-indexed Dokuwiki Pages"

# Print Success
echo -e "\nMake sure to run:\n"
echo -e "sudo chown -R http:http /srv/http/dokuwiki \n"
echo "Successfully imported HTML File into Dokuwiki"

exit 0
