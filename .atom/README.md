# Atom Config

I think atom is still using `~/.atom` for personal config stuff even though there
appears to be some stuff under `~/.config/Atom`. This is likely a symptom of 
not being maintained.


## Packages

The packages are managed with `apm`, there is a script: `my_package_list/sync_atom_packages.py`
this will install packages listed in  `my_package_list/atomPackages.txt` and/or write them
to it:

```bash
# Inspect the help
my_package_list/sync_atom_packages.py -h

# Install packages listed in the file
my_package_list/sync_atom_packages.py -i

# Write all packages that have been installed back to the file
my_package_list/sync_atom_packages.py -w
```


