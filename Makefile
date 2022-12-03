GITHUB_USER := atrakic

all:
	#kind create cluster
	flux bootstrap github --owner=$(GITHUB_USER) --repository=cncfminutes --branch=main --path=./clusters/my-cluster  --personal
