This is for new models or features that may not be required and may break things.

## Usage

### Usage for Jupyter

this is used by:

```
~/Sync-Current-rsync/Applications/Containers/user/share/jupyter
```


#### Missing Packages

If R is missing a package, modify this `./Dockerfile` and rebuild the image.

```
podman build --layers -t r .
```

recreate the distrobox

```
distrobox create --nvidia -i localhost/r -n r
```

Note that it is not necessary to recreate the distrobox for that podman jupyter service, it is sufficient to simply


```
podman-compose down
podman-compose up -d
```

Seemed to destroy and recreate the container when I tried it, meaning the new image was used.
