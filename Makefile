FC_VERSION ?= 4081.2.1 

BUTANE_CMD = docker run --rm -i \
	--security-opt label=disable \
	--volume "${PWD}/matchbox:/pwd" \
	--workdir /pwd \
	quay.io/coreos/butane:release \
	--pretty --strict

update-ssh-keys:
	@if [ -z "$(GITHUBUSER)" ]; then \
		echo "Error: GITHUBUSER variable is not set"; \
		echo "Usage: GITHUBUSER=yourusername make build-matchbox-env"; \
		exit 1; \
	fi
	./scripts/fetch-ssh-pub-keys.sh $(GITHUBUSER)

build-dnsmasq:
	if [ ! -d dnsmasq ]; then git clone git@github.com:poseidon/dnsmasq.git; fi
	make -C dnsmasq image-amd64

build-matchbox-env:
	@echo "Creating matchbox environment with SSH keys of GitHub user: $(GITHUBUSER)"
	if [ ! -d matchbox ]; then git clone git@github.com:oz123/matchbox.git; fi
	cd matchbox && ./scripts/get-flatcar stable $(FC_VERSION) ./examples/assets
	cd matchbox && sudo ./scripts/devnet create flatcar-install 


compile-butane-install:
	cd matchbox && \
	$(BUTANE_CMD) \
		examples/ignition/flatcar-install.yaml > examples/ignition/flatcar-install.ign

compile-butane-flatcar:
	cd matchbox && \
	$(BUTANE_CMD) \
		examples/ignition/flatcar.yaml > examples/ignition/flatcar.ign

compile-butane-flatcar-install-k8s:
	cd matchbox && \
	$(BUTANE_CMD) \
		examples/ignition/flatcar-install-k8s.yaml > examples/ignition/flatcar-install-k8s.ign

compile-butane-flatcar-k8s-node:
	cd matchbox && \
	$(BUTANE_CMD) \
		examples/ignition/flatcar-k8s-node.yaml > examples/ignition/flatcar-k8s-node.ign

compile-butane-flatcar-k8s-master:
	cd matchbox && \
	$(BUTANE_CMD) \
		examples/ignition/flatcar-k8s-master.yaml > examples/ignition/flatcar-k8s-master.ign

compile-butane: update-ssh-keys compile-butane-flatcar compile-butane-install compile-butane-flatcar-install-k8s compile-butane-flatcar-k8s-master compile-butane-flatcar-k8s-node 
	
verify-butane:
	jq -r '.storage.files[0].contents.source' matchbox/examples/ignition/flatcar-install.ign | \
	  sed 's/^data:;base64,//' | \
	  base64 -d | \
	  gunzip

launch-vms:
	bash matchbox/scripts/libvirt create


destroy-vms:
	bash matchbox/scripts/libvirt destroy


launch-k8s:
	bash matchbox/scripts/libvirt-k8s create

destroy-k8s:
	bash matchbox/scripts/libvirt-k8s destroy
