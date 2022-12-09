GITHUB_USER := atrakic
CLUSTER := my-cluster
	
kind:
	kind create cluster --config=config/kind.yaml || true

bootstrap: kind
	flux bootstrap github \
	    --owner=$(GITHUB_USER) \
		--repository=$(shell basename $$PWD) \
		--branch=$(shell git branch --show-current) \
		--path=./clusters/$(CLUSTER) \
		--personal

status:
	 flux get all --all-namespaces
	 
sync reconcile:
	 flux reconcile kustomization flux-system --with-source
	 flux get all --all-namespaces

clean:
	kind delete cluster
