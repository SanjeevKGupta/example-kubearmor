## Deny package management tool execution

Deny execution of package management tools (apt/apt-get)

Referecne: https://docs.kubearmor.io/kubearmor/quick-links/deployment_guide

### Prerequisite
- Make sure that you have created the [k8s context](../README.md) as mentioned here

### Run following commands one by one 
#### Setup the test environment
```
1-setup.sh
```

#### Apply the `deny` policy
```
2-apply-policy-deny-pkg-mgmt-tool.sh
```
#### Run test to verify
```
3-test.sh
```
