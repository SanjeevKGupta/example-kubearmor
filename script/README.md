## Automation scripts
These scrupts makes the process efficient and repeatable.

1. `install_microk8s.sh` - To install `microk8s` with needed add-ons on Linux host
   - You should be logged in as a `non-root` user having `sudo` privilege.
     
     Example:
     ```
     ./install_microk8s.sh -c -n <non-root-user>
     ```
2. `oh-cluster-agent-install.sh` - Wraps around original `agent-install.sh` to automate the step-by-step process.
    - You should be logged in as a `non-root` user having `sudo` privilege.
    - Have made sure that all HZN environment variables are correctly set. Otherwise script will guide you. 

      Example:
      ```
      sudo -s -E ./oh-cluster-agent-install.sh -c microk8s -d <edge-node-name> -n openhorizon-agent
      ```
