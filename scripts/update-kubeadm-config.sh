
#!/bin/bash
# Generate a random token
TOKEN=$(openssl rand -hex 3).$(openssl rand -hex 8)
export TOKEN
yq eval '(select(documentIndex == 0) | .bootstrapTokens[0].token) = env(TOKEN)' -i matchbox/examples/k8s/kubeadm.config

yq eval '.discovery.bootstrapToken.token = env(TOKEN)' -i matchbox/examples/k8s/kubeadm.node.config
