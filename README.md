Flatcar and Matchbox FTW!
=========================

This repo is a demo of how to create a Kubernetes cluster using FlatCar Linux and Matchbox.

We start by building a matchbox enabled environment.

```
make build-dnsmasq
```

We proceed by cloning the forked matchbox repository (which contains fixes
for working with a modern version of FlatCar):

```
make fetch-pubkey
make build-matchbox-env
```

Compile a butane configuration to ignition file:

```
cat matchbox/examples/ignition/flatcar-install.yaml
make compile-butane
make verify-butane
```

Now, we create a 2 nodes which will install flatcar to the disk.
