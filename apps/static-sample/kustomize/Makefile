APP := static-sample
IMAGE := ghcr.io/atrakic/go-static-site
NS := $(APP)

all: clean
	 kubectl create ns $(NS) --dry-run=client -oyaml > namespace.yaml
	 kubectl -n $(NS) create deployment $(APP) --image=$(IMAGE) --replicas=3 --dry-run=client -oyaml > deployment.yaml
	 kubectl -n $(NS) create service clusterip $(APP) --tcp=80:8080 --dry-run=client -oyaml > service.yaml
	 kubectl -n $(NS) create ingress $(APP) --class=nginx --rule="$(APP).local/*=$(APP):80" --dry-run=client -oyaml > ingress.yaml
	 kustomize create --autodetect

clean:
	rm -rf *.yaml *.yml


