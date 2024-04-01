## Automation scripts
These scrupts makes the process efficient and repeatable.

1. `install_microk8s.sh` - To install `microk8s` with needed add-ons on Linux host
     example: `./install_microk8s.sh -c -u ubuntu` to create a new cluster using a non-root account named "ubuntu"

2. `oh-cluster-agent-install.sh` - Wraps around original `agent-install.sh` to automate the step-by-step process.

