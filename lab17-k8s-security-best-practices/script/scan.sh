# install trivy first before running the script.

# curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
# sudo mv bin/trivy /usr/local/bin/
# trivy version


#!/bin/bash
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u > images.txt

while read i; do
  echo "Scanning $i"
  trivy image --severity HIGH,CRITICAL $i
done < images.txt
