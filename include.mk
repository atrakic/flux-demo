TAIL := 20

debug:
	flux get images all -n static-sample
	kubectl -n static-sample get deployment/$(APP) -o jsonpath="{$$.spec.template.spec.containers[0].image}"
	#kubectl get GitRepository,Kustomization,HelmRelease,HelmChart,OCIRepository -A

flux-debug:
	kubectl -n flux-system get all
	kubectl -n flux-system get Kustomization

controller-logs:
	kubectl -n flux-system logs deploy/source-controller | tail -n $(TAIL)
	kubectl -n flux-system logs deploy/kustomize-controller | tail -n $(TAIL)
	kubectl -n flux-system logs deploy/helm-controller | tail -n $(TAIL)

events:
	flux get all -A --status-selector ready=false
	kubectl get events -n flux-system --field-selector type=Warning

help-flux:
	flux create source git --help
	flux create kustomization --help
	flux create image update --help
