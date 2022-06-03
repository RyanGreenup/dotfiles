// nvim (echo "${QUTE_URL}" | sd '.*id=(.*)' '$1.txt' | sd ':' '/' | tr -d '\n' |  sd '^' "$HOME/Notes/dokuwiki/data /pages/")

package main

import (
	//	"fmt"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/bitfield/script"
)


func main() {
	// Get the URL
	url := os.Getenv("QUTE_URL")
	// 	url := "http://localhost:8923/doku.php?id=university:rd2:sidebar"

	// Get the Page name
	regex := regexp.MustCompile(`.*id=(.*)`)
	path := regex.FindAllStringSubmatch(url, 1)[0][1]

	// convert path:to:page into /path/to/page.txt
	path = dw_to_path(path)
	editor := "emacsclient --create-frame"
	script.Exec(fmt.Sprintf("%s %s", editor, path)).Wait()
}

func dw_to_path(path string) string {

    // Try and get the home directory
	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}

    // replace : for / like it should be in path
	path = strings.ReplaceAll(path, `:`, `/`)

    // add the home directory and .txt
	path = fmt.Sprintf("%s/Notes/dokuwiki/data/pages/%s.txt", home, path)

    // Clean anything up
	path = filepath.Clean(path)

    // Print and return
	fmt.Println(path)
	return path
}

func open_editor(filepath string, editor string) {

	cmd := exec.Command(editor, filepath)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	err := cmd.Run()
	if err != nil {
		log.Fatal("Unable to run "+editor, err)

	}
}
