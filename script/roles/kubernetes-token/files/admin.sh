#! /bin/bash

saName=$1
cat <<EOF | {{ bin_dir }}/kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: "${saName}"
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: "${saName}"
subjects:
  - kind: ServiceAccount
    name: "${saName}"
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io 
EOF


secretName=$(kubectl get secret -n kube-system | grep ${saName} | awk '{print $1}')

token=$(kubectl get secret -n kube-system ${secretName} -o jsonpath={.data.token} | base64 -d)

echo $token

