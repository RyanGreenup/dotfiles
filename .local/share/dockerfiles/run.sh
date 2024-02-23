
build_image() {
    podman build --layers -t "${1}" .
}

make_distrobox() {
    # podman prefaces images with localhost (docker doesn't :()
    distrobox create -i localhost/"${1}" -n "${2}"
}



construct_distro() {
    cd "${1}"
    image_name=$(basename $(pwd ${1}))
    distro_name=$(basename $(pwd ${1}))
    build_image ${image_name}
    distrobox rm ${distro_name}
    make_distrobox ${image_name} ${distro_name}
    cd -
}




for d in base base/r base/text_editors; do
    cd ${HOME}/Sync/Config/DotFiles/container-dockerfiles/
    construct_distro ${d}
done



