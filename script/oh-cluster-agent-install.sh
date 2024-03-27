#!/bin/bash

usage() {
    echo -e "${FG_OFF}"
    echo -e "${FG_BBLACK}Description:${FG_OFF}"
    echo "A simple script to install edge cluster agent. Works as a wrapper around agent-install.sh"
    echo ""
    echo -e "${FG_BBLACK}Usage: $0 -h -c -d -h [ -e -s -i ]${FG_OFF}"
    echo "where "
    echo "   -h Help "
    echo "   -c (Required) Cluster microk8s More options (EKS, IKS, ROKS etc) will be added. "
    echo "   -d (Required) Unique node name."
    echo "   -n (Required) Namespace to install edge agent in. "
    echo "   -e (Optional) Location where edge agent related files will be saved else current directory."
    echo "   -s (Optional) Show credentials. Default hidden."
    echo "   -i (Experimental and Optional) Use internal image registry. Default user provided External. Using internal image regustry is an advanced concept and may require additional settings and will be different for different cluster such as OCP, EKS, IKS etc. Currently experimental and to be used by experienced users only,"
    echo -e "${FG_OFF}"
}    

fn_term_setup() {
    FG_OFF="\033[0m"

    FG_BLACK="\033[30m"
    FG_RED="\033[31m"
    FG_GREEN="\033[32m"
    FG_YELLOW="\033[33m"
    FG_BLUE="\033[34m"

    FG_BBLACK="\033[1;30m"
    FG_BRED="\033[1;31m"
    FG_BGREEN="\033[1;32m"
    FG_BYELLOW="\033[1;33m"
    FG_BBLUE="\033[1;34m"

    BG_BLACK="\033[40m"
    BG_RED="\033[41m"
    BG_YELLOW="\033[43m"
    BG_CYAN="\033[46m"
    BG_WHITE="\033[47m"
}

fn_check_cmd() {
    path=$(which $1)
    if [ $? = 1 ]; then 
	echo -e "${FG_BBLACK}$1 ${FG_BRED}is not installed. Please install before proceeding. ${FG_OFF} "
	exit 1
    else
	echo -e "${FG_BBLACK}$1 ${FG_BGREEN}$path ${FG_OFF}"
    fi
}

fn_check_env() {
    if [ -z "$3" ]; then
	echo -e "${FG_BBLACK}$1 ${FG_BRED}is not set. Must set with${FG_OFF} export $1=<appropriate-value>"
	exit 1
    else
	if [[ "$2" == 1 ]]; then 
	    echo -e "${FG_BBLACK}$1 ${FG_BGREEN}$3${FG_OFF}"
	else
	    echo -e "${FG_BBLACK}$1 ${FG_Black}** Hidden ** Use -s option to reveal **${FG_OFF}"
	fi
    fi
}

fn_check_prereq() {
    echo -e "${FG_BBLUE}Verifying prereq... ${FG_OFF} "
    fn_check_cmd jq
    fn_check_cmd yq
#    fn_check_cmd oc
    fn_check_cmd kubectl
    fn_check_cmd docker
    echo -e ""
}

fn_get_microk8s_storage_class() {
    echo -e "${FG_BBLUE}Confirming storageclass... ${FG_OFF} "
    CLUSTER_STORAGE_CLASS=$(microk8s.kubectl get sc microk8s-hostpath -o json | jq -r '.metadata.name')
    echo -e "${FG_BBLACK}CLUSTER_STORAGE_CLASS: ${FG_BGREEN}$CLUSTER_STORAGE_CLASS ${FG_OFF} "
    echo -e ""
}

fn_create_namespace() {
    echo -e "${FG_BBLUE}Creating NAMESPACE: ${FG_BGREEN}$1 ${FG_OFF} "
    error=$(microk8s.kubectl create namespace $1 > /dev/null 2>&1)
    if [ $? = 1 ]; then
	echo -e "${FG_BLACK}  NAMESPACE: $1 already exists. Skipping.  ${FG_OFF} "
    fi
    microk8s.kubectl config set-context --current --namespace=$1
    echo -e ""
}

fn_create_resource_directory() {
    echo -e "${FG_BBLUE}Creating a resource directory with NAMESPACE name to hold agent specific files in location: ${FG_BGREEN}$1 ${FG_OFF} "
    mkdir -p $1 > /dev/null 2>&1
    if [ $? == 1 ]; then
	echo -e "Can not create directory at this location $1"
	echo -e "Make sure that location is writable."
	exit 1
    fi
    cd $1
    echo -e ""
}

fn_configure_microk8s_registry() {
    echo -e "${FG_BBLUE}Configuring microk8s cluster container registry...  ${FG_OFF} "
    export REGISTRY_ENDPOINT=localhost:32000
    export REGISTRY_IP_ENDPOINT=$(microk8s.kubectl get service registry -n container-registry -o json | jq -r '.spec.clusterIP')
    export IMAGE_ON_EDGE_CLUSTER_REGISTRY=$REGISTRY_ENDPOINT/openhorizon-agent/amd64_anax_k8s

    echo -e "${FG_BBLACK}REGISTRY_ENDPOINT: ${FG_BGREEN}$REGISTRY_ENDPOINT ${FG_OFF} "
    echo -e "${FG_BBLACK}REGISTRY_IP_ENDPOINT: ${FG_BGREEN}$REGISTRY_IP_ENDPOINT ${FG_OFF} "
    echo -e ""

    echo -e "${FG_BBLUE}Updating docker access to container registry...${FG_OFF} /etc/docker/daemon.json   "
    sudo echo "{ 
      \"insecure-registries\": [ \"$REGISTRY_ENDPOINT\", \"$REGISTRY_IP_ENDPOINT\" ]
}" > /etc/docker/daemon.json

    echo -e ""
    echo -e "${FG_BBLUE}Restarting docker... ${FG_OFF} "
    sudo systemctl restart docker
    echo -e ""
}

fn_confirm_agent_install_HZN_params() {
    echo -e "${FG_BBLUE}Checking user provided HZN parameters...Must run as sudo -s -E option ${FG_OFF} "
    fn_check_env HZN_EXCHANGE_USER_AUTH $SHOW_CRED $HZN_EXCHANGE_USER_AUTH 
    fn_check_env HZN_ORG_ID 1 $HZN_ORG_ID 
    fn_check_env HZN_AGBOT_URL 1 $HZN_AGBOT_URL 
    fn_check_env HZN_EXCHANGE_URL 1 $HZN_EXCHANGE_URL
    fn_check_env HZN_FSS_CSSURL 1 $HZN_FSS_CSSURL
    echo -e ""
}

fn_get_agent_install_script() {
    echo -e "${FG_BBLUE}Getting agent install script from mgmt hub...  ${FG_OFF} "
    cd $EDGE_AGENT_FILES_LOCATION
    curl -sSLO https://github.com/open-horizon/anax/releases/latest/download/agent-install.sh
    chmod +x agent-install.sh
    echo -e ""
}

fn_install_agent() {
    echo -e "${FG_BBLUE}Ready to install edge agent...  ${FG_OFF} "

    export AGENT_NAMESPACE=$1
    export EDGE_CLUSTER_STORAGE_CLASS=$CLUSTER_STORAGE_CLASS

    if [[ "$SHOW_CRED" == 1 ]]; then 
	echo -e ${FG_BBLACK}HZN_EXCHANGE_USER_AUTH${FG_OFF}=$HZN_EXCHANGE_USER_AUTH
    else
	echo -e ${FG_BBLACK}HZN_EXCHANGE_USER_AUTH${FG_OFF}="** Hidden ** Use -s option to reveal **"
    fi
    echo -e ${FG_BBLACK}HZN_ORG_ID${FG_OFF}=$HZN_ORG_ID
    echo -e ${FG_BBLACK}HZN_EXCHANGE_URL${FG_OFF}=$HZN_EXCHANGE_URL
    echo -e ${FG_BBLACK}HZN_AGBOT_URL${FG_OFF}=$HZN_AGBOT_URL
    echo -e ${FG_BBLACK}HZN_FSS_CSSURL${FG_OFF}=$HZN_FSS_CSSURL
    echo -e ${FG_BBLACK}EDGE_CLUSTER_STORAGE_CLASS${FG_OFF}=$EDGE_CLUSTER_STORAGE_CLASS
    echo -e ${FG_BBLACK}USE_EDGE_CLUSTER_REGISTRY${FG_OFF}=true
    echo -e ${FG_BBLACK}AGENT_NAMESPACE${FG_OFF}=$AGENT_NAMESPACE
    echo -e ${FG_BBLACK}IMAGE_ON_EDGE_CLUSTER_REGISTRY${FG_OFF}=$IMAGE_ON_EDGE_CLUSTER_REGISTRY
    read -p "Continue? (Y/N)" yn
    case $yn in
	[Yy]* ) ;;
	[Nn]* ) exit;;
    esac
    echo -e ""

# anax: will by default pull from the latest which is 2.31 as of 3/24/2024
# with 2.31
#    sudo -s -E ./agent-install.sh -D cluster -i 'anax:' -d $2 --namespace-scoped

# And 2.30 hub will not work with 2.31 agent. SO have to force the agent code as below
# with 2.30 - currently in use.
    sudo -s -E ./agent-install.sh -D cluster -i 'https://github.com/open-horizon/anax/releases/tag/v2.30.0-1491' -d $2
}

fn_microk8s_agent_install() {
    echo -e "Will install on ${FG_BBLACK}microk8s${FG_OFF} cluster in Namespace: ${FG_BBLACK}$1${FG_OFF} using internal container registry.${FG_OFF}"
    echo -e ""
    export KUBECTL=microk8s.kubectl
    fn_check_prereq
    fn_confirm_agent_install_HZN_params 
    fn_get_microk8s_storage_class
    fn_create_namespace $1
    fn_create_resource_directory $EDGE_AGENT_FILES_LOCATION
    fn_configure_microk8s_registry
    fn_get_agent_install_script
    fn_install_agent $1 $2
}

fn_roks_agent_install_ICR_internal() {
    echo -e "${FG_BRED}ROKS: ICR_internal - in development"
    usage
}

fn_roks_agent_install_ICR_external() {
    echo -e "${FG_BRED}ROKS: ICR_external - in development"
    usage
}

fn_iks_agent_install_ICR_external() {
    echo -e "${FG_BRED}IKS: ICR_external - in development"
    usage
}


fn_term_setup

SHOW_CRED=0

echo -e ""

while getopts 'c:d:e:n:his' option; do
  case "$option" in
    h) usage
       exit 1
       ;;
    c) CLUSTER=$OPTARG
       ;;
    d) NODE_NAME=$OPTARG
       ;;
    n) NAMESPACE=$OPTARG
       ;;
    e) EDGE_AGENT_FILES_LOCATION=$OPTARG
       ;;
    i) INTERNAL_REGISTRY=1
       ;;
    s) SHOW_CRED=1
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       usage
       exit 1
       ;;
    \?)printf "illegal option: -%s\n" "$OPTARG" >&2
       usage
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))


if [ -z $CLUSTER ]; then
    echo -e "${FG_BRED}Must provide a valid cluster to install on"
    usage
elif [ -z $NODE_NAME ]; then
    echo -e "${FG_BRED}Must provide a valid NODE_NAME to install in"
    usage
elif [ -z $NAMESPACE ]; then
    echo -e "${FG_BRED}Must provide a valid NAMESPACE to install in"
    usage
else
    if [ -z $EDGE_AGENT_FILES_LOCATION ]; then
	EDGE_AGENT_FILES_LOCATION=${PWD}/$NAMESPACE
    else
	EDGE_AGENT_FILES_LOCATION=$EDGE_AGENT_FILES_LOCATION/$NAMESPACE
    fi

    if [[ "$CLUSTER" = "ROKS" ]]; then
	if [[ "$INTERNAL_REGISTRY" == 1 ]]; then
	    fn_roks_agent_install_ICR_internal $NAMESPACE $NODE_NAME
	else # defaukt
	    fn_roks_agent_install_ICR_external $NAMESPACE $NODE_NAME
	fi
    elif [[ "$CLUSTER" = "microk8s" ]]; then
	fn_microk8s_agent_install $NAMESPACE $NODE_NAME
    elif [[ "$CLUSTER" = "IKS" ]]; then
	fn_iks_agent_install_ICR_external $NAMESPACE $NODE_NAME
    else
	echo -e "${FG_BRED}Invalid cluster option"
	usage
    fi
fi
