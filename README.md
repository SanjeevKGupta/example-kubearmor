# example-kubearmor

Open Horizon working with `kubearmor` provides Runtime Security for your workload. To setup a quick demo

1. Create VM to deploy your workload. In my setup I used Ubuntu 22.04 LTS (4 vCPU, 8GB)
2. Install microk8s (my example) using this [install_microk8s.sh](./script/install_microk8s.sh) script.
3. Install Open Horizon edge cluster agent using this [oh-cluster-agent-install.sh](./script/oh-cluster-agent-install.sh) script.
4. Deploy the kubearmor K8s operator into the cluster. [Instructions here](./publish) 
5. Follow through these demos to see the impact.  
