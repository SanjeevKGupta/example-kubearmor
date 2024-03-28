## Deploy workload on the Edge Cluster node
In this case we will deploy the kubarmor operator on the edge cluster node. We assume that the edge cluster agent was installed in `openhorizon-agent` namespace.

1. Verify that the Edge Cluster node is registered with the Open Horizon AIO mgmt hub
```
kubectl exec -it <agent-pod> -n openhorizon-agent -- hzn node ls
```
2. View current node policy
```
kubectl exec -it <agent-pod> -n openhorizon-agent -- hzn policy ls
```
3. Apply node policy to deploy the workload
```
cat edge-cluster-node-policy.json | kubectl exec -it <agent-pod> -n openhorizon-agent -- hzn policy update -f-
```
4. View updated node policy
```
kubectl exec -it <agent-pod> -n openhorizon-agent -- hzn policy ls
```
5. View the agreement as it forms
```
kubectl exec -it <agent-pod> -n openhorizon-agent -- hzn agreement  ls
```
6. Optionally view the eventlog
```
kubectl exec -it <agent-pod> -n openhorizon-agent -- hzn eventlog ls
```
7. Verifu the deployed pod
```
kubectl get pods -n openhorizon-agent

NAME                                        READY   STATUS    RESTARTS   AGE
agent-577b45db8d-76486                      1/1     Running   0          5h1m
kubearmor-operator-6dc4d675c6-xksd9         1/1     Running   0          4m29s
kubearmor-relay-847bbc4896-p5jvm            1/1     Running   0          4m8s
kubearmor-apparmor-containerd-f0a8b-z6rm5   1/1     Running   0          3m47s
kubearmor-controller-5cf5b8d7b5-7hg67       2/2     Running   0          3m3s
auto-upgrade-cronjob-28527699-pgs9d         1/1     Running   0          8s

```
