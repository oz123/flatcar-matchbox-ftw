FC_VERSION ?= 4081.2.1 



build-dnsmasq:
	if [ ! -d dnsmasq ]; then git clone git@github.com:poseidon/dnsmasq.git; fi
	make -C dnsmasq image-amd64

build-matchbox-env:
	@if [ -z "$(GITHUBUSER)" ]; then \
		echo "Error: GITHUBUSER variable is not set"; \
		echo "Usage: GITHUBUSER=yourusername make build-matchbox-env"; \
		exit 1; \
	fi
	@echo "Creating matchbox environment with SSH keys of GitHub user: $(GITHUBUSER)"
	if [ ! -d matchbox ]; then git clone git@github.com:oz123/matchbox.git; fi
	./scripts/fetch-ssh-pub-keys.sh $(GITHUBUSER)
	cd matchbox && ./scripts/get-flatcar stable $(FC_VERSION) ./examples/assets
	cd matchbox && sudo ./scripts/devnet create flatcar-install 


compile-butane:
	cd matchbox && \
	docker run --rm -i \
		--security-opt label=disable \
		--volume "${PWD}/matchbox:/pwd" \
		--workdir /pwd \
		quay.io/coreos/butane:release \
		--pretty --strict \
		examples/ignition/flatcar-install.yaml > examples/ignition/flatcar-install.ign


verify-butane:
	jq -r '.storage.files[0].contents.source' matchbox/examples/ignition/flatcar-install.ign | \
	  sed 's/^data:;base64,//' | \
	  base64 -d | \
	  gunzip
