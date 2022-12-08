GITHUB_USER := atrakic

all:
	kind create cluster || true
	flux bootstrap github --owner=$(GITHUB_USER) \
		--repository=$(shell basename $$PWD) \
		--branch=$(shell git branch --show-current) \
		--path=./clusters/my-cluster \
		--personal

clean:
	kind delete cluster
