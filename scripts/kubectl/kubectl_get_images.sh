kubectl get pods -n static-sample '-o=custom-columns=:spec.containers[*].image'
