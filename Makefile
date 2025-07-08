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
