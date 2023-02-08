MAKEFLAGS += --silent
.DEFAULT_GOAL := help

GITHUB_USER ?= atrakic
CLUSTER ?= my-cluster
BRANCH ?= $(shell git branch --show-current)
IMAGE := ghcr.io/atrakic/go-static-site:latest
NS := static-sample
APP := static-sample

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


all: bootstrap sync status test ## Do all
	echo ":: $(green)$@$(reset) :: "

kind:
	echo ":: $(green)$@$(reset) :: "
	kind create cluster --config=config/kind.yaml || true
	kubectl cluster-info
	flux check --pre

load_image: ## Load ci image under test
	echo ":: $(green)$@$(reset) :: "
	docker pull $(IMAGE)
	kind load docker-image $(IMAGE)

status:
	echo ":: $(green)$@$(reset) :: "
	flux get all --all-namespaces
	helm list -A

version:
	echo ":: $(green)$@$(reset) :: "
	flux version

bootstrap: kind load_image ## Flux bootstrap github repo
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

sync reconcile:
	echo ":: $(green)$@$(reset) :: "
	#flux reconcile kustomization flux-system --with-source
	flux reconcile kustomization infrastructure --with-source
	flux reconcile kustomization apps --with-source
	flux get all --all-namespaces

clean:
	echo ":: $(green)$@$(reset) :: "
	kind delete cluster

test: ## Test app
	echo "::  $(green)$@$(reset) :: "
	kubectl wait --for=condition=Ready pods --timeout=300s -l "app=$(APP)" -n $(NS) --timeout=300s
	kubectl --namespace $(NS) wait deployment/$(APP) --for condition=available
	[ -f ./tests/test.sh ] && ./tests/test.sh $(APP).local

help:  ## Display this help menu
	echo ":: $(green)$@$(reset) :: "
	awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all test clean sync reconcile bootstrap kind status

-include include.mk
