## Open Horizon with KubeArmor [ONE Summit]

Open Horizon working with `kubearmor` provides Runtime Security for your workload. To setup a demo you may follow these steps.

#### Linux host
1. Create VM to deploy your workload. In my setup I used Ubuntu 22.04 LTS (4 vCPU, 8GB)

#### Scripted install - [script]
2. Install microk8s (my example) using this [install_microk8s.sh](./script/install_microk8s.sh) script.
3. Install Open Horizon edge cluster agent using this [oh-cluster-agent-install.sh](./script/oh-cluster-agent-install.sh) script.

#### Publish Open Horizon Service and Policy - [publish]
4. Publish the kubearmor K8s operator into the Open Horizon cluster. [Publish instructions here](./publish)

#### Deploy on Edge Cluster node - [register]
5. Deploy the kubearmor K8s operator into the cluster. [Register instructions here](./register) 

#### Demo [demo]
6. Follow through these demos to see the impact.
   - [Deny package management tool execution](./demo/deny-pkg-mgmt-tool/)
   - more to come...
