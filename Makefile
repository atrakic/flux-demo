GITHUB_USER := atrakic
CLUSTER := my-cluster

all: sync
	kind create cluster || true
	flux bootstrap github \
	    --owner=$(GITHUB_USER) \
		--repository=$(shell basename $$PWD) \
		--branch=$(shell git branch --show-current) \
		--path=./clusters/$(CLUSTER) \
		--personal

status:
	 flux get all --all-namespaces
	 
sync reconcile:	status
	 flux reconcile kustomization flux-system --with-source
	 flux get all --all-namespaces

clean:
	kind delete cluster