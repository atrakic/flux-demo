GITHUB_USER := atrakic
CLUSTER := my-cluster

status:
	 flux get all --all-namespaces

kind:
	kind create cluster --config=config/kind.yaml || true
	flux check --pre

bootstrap: kind
	flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=$(shell basename $$PWD) \
		--branch=$(shell git branch --show-current) \
		--path=./clusters/$(CLUSTER) \
		--private=false \
		--personal

sync reconcile:
	 flux reconcile kustomization flux-system --with-source
	 flux get all --all-namespaces

clean:
	kind delete cluster

test: ## Test app
	[ -f ./tests/test.sh ] && ./tests/test.sh

.PHONY: test clean sync reconcile bootstrap kind status

-include include.mk
