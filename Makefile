MAKEFLAGS += --silent
.DEFAULT_GOAL := help

GITHUB_USER ?= atrakic
CLUSTER ?= kind
BRANCH ?= $(shell git branch --show-current)
IMAGE := ghcr.io/atrakic/go-static-site:latest
NS := static-site
APP := static-site

# Required by flux-cli
ifndef GITHUB_TOKEN
$(error GITHUB_TOKEN is not set)
endif

ifneq ($(TERM),)
    green := $(shell tput setaf 2)
    reset := $(shell tput sgr0)
else
    green := ""
    reset := ""
endif

.PHONY: kind load_image bootstrap sync status test

all: kind load_image bootstrap sync status test ## Do all
	echo ":: $(green)$@$(reset) :: "

kind: ## Install kind
	echo ":: $(green)$@$(reset) :: "
	kind create cluster --config=config/kind.yaml || true
	kubectl cluster-info
	flux check --pre

load_image: ## Load ci image under test
	echo ":: $(green)$@$(reset) :: "
	docker pull $(IMAGE)
	kind load docker-image $(IMAGE)

status: ## Print Flux status
	echo ":: $(green)$@$(reset) :: "
	flux get all --all-namespaces
	helm list -A

version: ## Print version
	echo ":: $(green)$@$(reset) :: "
	flux version

bootstrap: ## Flux bootstrap github repo
	echo ":: $(green)$@$(reset) :: "
	flux bootstrap github \
		--components-extra=image-reflector-controller,image-automation-controller \
		--owner=$(GITHUB_USER) \
		--repository=$(shell basename $$PWD) \
		--branch=$(BRANCH) \
		--path=./clusters/$(CLUSTER) \
		--private=false \
		--personal
	kubectl -n flux-system wait gitrepository/flux-system --for=condition=ready --timeout=1m
	$(MAKE) version

sync reconcile: ## Sync
	echo ":: $(green)$@$(reset) :: "
	flux reconcile kustomization infrastructure --with-source
	flux reconcile kustomization apps --with-source
	flux get all --all-namespaces

clean: ## Clean up
	echo ":: $(green)$@$(reset) :: "
	kind delete cluster

test: ## Test demo app
	echo "::  $(green)$@$(reset) :: "
	#kubectl --namespace $(NS) wait --for=condition=Ready pods -l "app=$(APP)" --timeout=300s
	#kubectl --namespace $(NS) wait deployment/$(APP) --for condition=available
	[ -f ./tests/test.sh ] && ./tests/test.sh

release: ## Release (eg. V=0.0.1)
	 @[ "$(V)" ] \
		 && read -p "Press enter to confirm and push tag v$(V) to origin, <Ctrl+C> to abort ..." \
		 && git tag v$(V) -m "chore: v$(V)" \
		 && git push origin v$(V) -f \
		 && git fetch --tags --force --all -p \
		 && if [ ! -z "$(GITHUB_TOKEN)" ] ; then \
			curl \
			  -H "Authorization: token $(GITHUB_TOKEN)" \
				-X POST	\
				-H "Accept: application/vnd.github.v3+json"	\
				https://api.github.com/repos/$(GITHUB_USER)/$(shell basename $$PWD)/releases \
				-d "{\"tag_name\":\"$(V)\",\"generate_release_notes\":true}"; \
			fi;

help:  ## Display this help menu
	echo ":: $(green)$@$(reset) :: "
	awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all test clean release sync reconcile bootstrap kind status

-include include.mk
