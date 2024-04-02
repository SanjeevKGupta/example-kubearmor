#!/bin/bash
#
# microk8s
#

usage() {
    echo "Usage: $0 -h -i -c -d -n"
    echo ""
    echo -e "${FG_BBLUE}Deploys microk8s cluster in a vm ${FG_OFF}"
    echo -e "${FG_BBLACK}User running this must have sudo privilege on the host.${FG_OFF}"
    echo ""
    echo "where "
    echo "   -h help "
    echo "   -c Create microk8s cluster"
    echo "   -d Delete microk8s cluster"
    echo "   -n Non-root userid"
    echo ""
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

fn_update_vm() {
    sudo apt update
}

fn_install_microk8s() {
    sudo snap install microk8s --classic --channel stable
    sudo microk8s status --wait-ready
    sudo microk8s enable hostpath-storage registry
}

fn_add_user() {
    sudo usermod -a -G microk8s $1
    echo ""
    echo "Logout twice and log back in for the new grpup to become active."
    echo ""
    newgrp microk8s
}

fn_uninstall() {
    sudo microk8s stop
    sudo snap disable microk8s

    for mnt in $(findmnt -l | grep /var/snap/microk8s/ | awk '{ print $1 }')
    do
	sudo umount $mnt
    done

    sudo snap remove microk8s --purge
}


fn_term_setup

while getopts 'hcdn:' option; do
  case "$option" in
    h) usage
       exit 1
       ;;
    c) CLUSTER_CREATE=1
       ;;
    d) CLUSTER_DELETE=1
       ;;
    n) CLUSTER_USER=$OPTARG
       ;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       usage
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

if [ ! -z "$CLUSTER_CREATE" ]; then
  if [ ! -z "$CLUSTER_USER" ]; then
     fn_update_vm
     fn_install_microk8s
     fn_add_user $CLUSTER_USER
  else
    echo -e "${FG_RED}Error: Missing non-root user.  Use -n option to specify non-root user.${FG_OFF}"
    usage
    exit 1
  fi
elif [ ! -z "$CLUSTER_DELETE" ]; then
    echo -e ""
    echo -e "${FG_BRED}Delete cluster install ${FG_OFF} "
    echo -e ""
    read -p "Continue? (Y/N)" yn
    case $yn in
	[Yy]* ) ;;
	[Nn]* ) exit 1;;
    esac
    echo -e ""

    fn_uninstall
else
    echo -e "${FG_RED}Error: Missing CLUSTER_CREATE. Use option -c to create or -d to delete microk8s cluster.${FG_OFF}"
    usage
    exit 1
fi
