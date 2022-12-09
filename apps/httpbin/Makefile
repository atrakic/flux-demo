APP := httpbin
IMAGE := kennethreitz/$(APP)

all: clean
	 kubectl create deployment $(APP) --image=$(IMAGE) --replicas=3 --dry-run=client -oyaml > deployment.yaml
	 kubectl create service clusterip $(APP) --tcp=80:80 --dry-run=client -oyaml > service.yaml
	 kubectl create ingress $(APP) --class=nginx --rule="$(APP).local/*=$(APP):80" --dry-run=client -oyaml > ingress.yaml
	 kustomize create --autodetect

clean:
	rm -rf *.yaml *.yml


