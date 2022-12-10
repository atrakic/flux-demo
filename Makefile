GITHUB_USER := atrakic
CLUSTER := my-cluster

status:
	 flux get all --all-namespaces
	 kubectl get GitRepository,Kustomization,HelmRelease,HelmChart,OCIRepository -A

kind:
	kind create cluster --config=config/kind.yaml || true

bootstrap: kind
	flux bootstrap github \
	    --owner=$(GITHUB_USER) \
		--repository=$(shell basename $$PWD) \
		--branch=$(shell git branch --show-current) \
		--path=./clusters/$(CLUSTER) \
		--personal

sync reconcile:
	 flux reconcile kustomization flux-system --with-source
	 flux get all --all-namespaces

controller-logs: 
	kubectl -n flux-system logs deploy/source-controller | tail -n 20
	kubectl -n flux-system logs deploy/kustomize-controller | tail -n 20
	kubectl -n flux-system logs deploy/helm-controller | tail -n 20

clean:
	kind delete cluster

