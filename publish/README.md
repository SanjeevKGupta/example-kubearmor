## Publish Open Horizon service and policy

To publish Open Horizon service and policy for the KubeArmor project
1. Prepare a development host Linux machine. I used Ubuntu 22.04 LTS
2. Install following packages
   - make
     ```
     sudo apt install make
     ```
   - docker
     ```
     curl -fsSL get.docker.com | sh
     sudo usermod -aG docker <username>
     ```
   - helm
   ```
   sudo snap install helm --classic
   ```
   - hzn CLI only
     - Download, untar and install from here as of 03/27/2024 https://github.com/open-horizon/anax/releases 
    ```
    curl -LO https://github.com/open-horizon/anax/releases/download/v2.30.0-1491/horizon-agent-linux-deb-amd64.tar.gz
    tar zxvf horizon-agent-linux-deb-amd64.tar.gz
    sudo apt install ./horizon-cli*.deb
    ``` 

3. Clone this repo
4. Setup following sets of ENV variables. .
- These are Open Horizon AIO specific and will be provided by your AIO admin, or if you setup your own AIO then you will get them as part of setting it up. Change the values within `< >` based on your environment.
```
export HZN_ORG_ID=<orgid>
export HZN_EXCHANGE_USER_AUTH=<username:credential-api-key>
export HZN_EXCHANGE_URL=<open-horizon-aio-url-exchange>
export HZN_FSS_CSSURL=<open-horizon-aio-url-fss>
export HZN_AGBOT_URL=<open-horizon-aio-url-agbot>
export HZN_SDO_SVC_URL=<open-horizon-aio-url-sdo>
```
- These are application specific and used for service and policy name customization.
```
# You can change these as per your preference.
# These are prepnded to the service and policy names. These are used by `make` 
export EDGE_OWNER=<oh.edge>
export EDGE_DEPLOY=<example.kubearmor>
```


5. Run `make` to download helm-charts, publish Open Horizon service and create deployment policy that will be used with a node policy to deploy the opeartor on the edge cluster node. 
```
make
```
6. Verify
```
hzn exchange service list | grep kubearmor.helm

hzn exchange deployment listpolicy | grep kubearmor.helm
```
