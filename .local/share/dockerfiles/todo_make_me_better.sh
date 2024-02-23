set -euf

make_container() {
	podman build --layers -t $1 . && distrobox create --nvidia -i localhost/$1 -n $1
}

cd ./base/
make_container base
cd ..

cd ./base/r
make_container r
cd ../../

cd ./base/text_editors
make_container text_editors
cd ../../
