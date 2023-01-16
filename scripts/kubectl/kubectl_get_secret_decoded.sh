kubectl -n flux-system get secret flux-system -o json | jq '.data | map_values(@base64d)'
