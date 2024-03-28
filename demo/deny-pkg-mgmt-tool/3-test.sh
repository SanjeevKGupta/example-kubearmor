#!/bin/bash

. ../kubeconfig-namespace-context

POD=$(kubectl get pod -l app=nginx -o name)
kubectl exec -it $POD -- bash -c "apt update && apt install masscan"
