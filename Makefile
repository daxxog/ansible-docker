SHELL := /bin/bash


.PHONY: help
help:
	@printf "available targets -->\n\n"
	@cat Makefile | grep ".PHONY" | grep -v ".PHONY: _" | sed 's/.PHONY: //g'


env:
	python3 -m venv env
	if [ -f requirements.txt ]; then \
		bash -c 'source env/bin/activate && set -x && python3 -m pip install -r requirements.txt'; \
	fi


requirements.in:
	echo "pip-tools" > requirements.in
	echo "zest.releaser" >> requirements.in
	if git status requirements.in | grep -q requirements.in; then \
		git add requirements.in; \
		git commit -m 'new file:   requirements.in'; \
	fi


requirements.txt: requirements.in env
	bash -c 'source env/bin/activate && set -x && python3 -m pip install -r requirements.in && pip-compile --generate-hashes --resolver=backtracking'
	if git status requirements.txt | grep -q requirements.txt; then \
		git add requirements.txt; \
		git commit -m 'generated:   requirements.txt'; \
	fi


CHANGES.md:
	if [ ! -f CHANGES.md ]; then \
		touch CHANGES.md; \
		git add CHANGES.md; \
		git commit -m 'new file:   CHANGES.md'; \
	fi


VERSION:
	if [ ! -f VERSION ]; then \
		echo "0.0.1" > VERSION; \
		git add VERSION; \
		git commit -m 'new file:   VERSION'; \
	fi


.PHONY: release
release: env CHANGES.md VERSION requirements.txt
	bash -c 'source env/bin/activate && set -x && fullrelease'
