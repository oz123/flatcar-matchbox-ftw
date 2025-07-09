Flatcar and Matchbox FTW!
=========================

This repo is a demo of how to create a Kubernetes cluster using FlatCar Linux and Matchbox.

First, make sure you have the following installed on your system:

 * docker
 * libvirt
 * buildah
 * jq
 * yq

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

```
make launch-vms
```

Watch matchbox logs:

```
docker logs -f matchbox
```

It should show something like:
```
time="2025-07-08T17:30:35Z" level=info msg="HTTP GET /boot.ipxe"
time="2025-07-08T17:30:35Z" level=info msg="HTTP GET /ipxe?uuid=631c0708-8237-447f-9be8-0322be9a06ee&mac=52-54-00-b2-2f-86&domain=&hostname=&serial="
time="2025-07-08T17:30:35Z" level=debug msg="Matched an iPXE config" labels="map[domain: hostname: mac:52:54:00:b2:2f:86 serial: uuid:631c0708-8237-447f-9be8-0322be9a06ee]" profile=flatcar-install
time="2025-07-08T17:30:35Z" level=info msg="HTTP GET /assets/flatcar/4081.2.1/flatcar_production_pxe.vmlinuz"
time="2025-07-08T17:30:37Z" level=info msg="HTTP GET /assets/flatcar/4081.2.1/flatcar_production_pxe_image.cpio.gz"
time="2025-07-08T17:31:04Z" level=info msg="HTTP GET /ignition?uuid=05188cbf-1d36-45b2-a28b-da3c45802c85&mac=52-54-00-a1-9c-ae"
time="2025-07-08T17:31:04Z" level=debug msg="Matched an Ignition or Container Linux Config template" group=stage-0 labels="map[mac:52:54:00:a1:9c:ae uuid:05188cbf-1d36-45b2-a28b-da3c45802c85]" profile=flatcar-install
time="2025-07-08T17:31:05Z" level=info msg="HTTP GET /ignition?uuid=631c0708-8237-447f-9be8-0322be9a06ee&mac=52-54-00-b2-2f-86"
time="2025-07-08T17:31:05Z" level=debug msg="Matched an Ignition or Container Linux Config template" group=stage-0 labels="map[mac:52:54:00:b2:2f:86 uuid:631c0708-8237-447f-9be8-0322be9a06ee]" profile=flatcar-install
time="2025-07-08T17:31:12Z" level=info msg="HTTP GET /ignition?os=installed"
```

Note about groups and profiles:

profile name is the file name!

Watch ignition logs:
```
$ ssh -F ssh-config core@master
$ sudo journalctl -t ignition
```


Installing k8s:
---------------

Understanding Ignition's "Runs Once" Nature

Ignition only runs once during the first boot of the system. This means:

For stage 0 (PXE boot installation), Ignition runs in the temporary environment. Thisn installs FlatCar to the disk.
For stage 1 (installed system), Ignition runs during the first boot of the installed system. This enables and configures a k8s cluster.
After that, Ignition doesn't run again unless explicitly triggered

This is why you need to include the Kubernetes extension configuration in your stage 1 Ignition file.


