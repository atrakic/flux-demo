MAKEFLAGS += --silent
.DEFAULT_GOAL := help

GITHUB_USER ?= atrakic
CLUSTER ?= my-cluster
BRANCH ?= $(shell git branch --show-current)

# Required by flux-cli
ifndef GITHUB_TOKEN
$(error GITHUB_TOKEN is not set)
endif

all: kind bootstrap sync test status ## Do all

kind:
	kind create cluster --config=config/kind.yaml || true
	flux check --pre

load_image: ## Load ci image under test
	docker pull kennethreitz/httpbin:latest
	kind load docker-image kennethreitz/httpbin:latest

status:
	 flux get all --all-namespaces

bootstrap: kind load_image ## Flux bootstrap github repo
	flux bootstrap github \
		--components-extra=image-reflector-controller,image-automation-controller \
		--owner=$(GITHUB_USER) \
		--repository=$(shell basename $$PWD) \
		--branch=$(BRANCH) \
		--path=./clusters/$(CLUSTER) \
		--private=false \
		--personal
	kubectl -n flux-system wait gitrepository/flux-system --for=condition=ready --timeout=1m
	flux version

sync reconcile:
	 flux reconcile kustomization flux-system --with-source
	 flux get all --all-namespaces

clean:
	kind delete cluster

test: ## Test app
	#kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=300s
	[ -f ./tests/test.sh ] && ./tests/test.sh

help:  ## Display this help menu
	awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all test clean sync reconcile bootstrap kind status

-include include.mk
