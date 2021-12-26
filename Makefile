.PHONY: help
help:
	@echo "available targets -->\n"
	@cat Makefile | grep ".PHONY" | grep -v ".PHONY: _" | sed 's/.PHONY: //g'


.PHONY: docker-build
docker-build:
	docker build . -t docker.io/daxxog/ansible:latest-$$(uname -m)


.PHONY: docker-shell
docker-shell: docker-build
	docker run \
		-i \
		-t \
		--entrypoint /bin/zsh \
		docker.io/daxxog/ansible:latest-$$(uname -m)
