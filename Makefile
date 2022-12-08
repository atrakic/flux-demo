GITHUB_USER := atrakic

all:
	kind create cluster || true
	flux bootstrap github --owner=$(GITHUB_USER) \
		--repository=$(shell basename $$PWD) \
		--branch=$(shell git branch --show-current) \
		--path=./clusters/my-cluster \
		--personal

status:
	 flux get sources all --all-namespaces
	 flux get helmreleases --all-namespaces
	 # TODO

clean:
	kind delete cluster
