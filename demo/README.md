## Basic demos

These demos require you to set the K8s context before running them. In this demo 
- Here `microk8s` is used as example K8s cluster. Other clusters will work similarly.
- Our resources are deployed in `openhorizon-agent` namespace. This can be changed as well. 

Run folllowing command to create the context file, if not already. Thsi will be used by the demos internally.
```
kubectl config view --raw --minify > kubeconfig-example-ka-microk8s.yaml
```
