Sample copmmads
```
kubectl exec -it agent-6cb5459b64-lrgt9 -n openhorizon-agent -- hzn policy ls
cat edge-cluster-node-policy.json | kubectl exec -it agent-6cb5459b64-lrgt9 -n openhorizon-agent -- hzn policy update -f-
kubectl exec -it agent-6cb5459b64-lrgt9 -n openhorizon-agent -- hzn policy ls
kubectl exec -it agent-6cb5459b64-lrgt9 -n openhorizon-agent -- hzn agreement  ls
kubectl exec -it agent-6cb5459b64-lrgt9 -n openhorizon-agent -- hzn eventlog ls
kubectl get pods -A
```
