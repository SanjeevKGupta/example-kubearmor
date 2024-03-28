#!/bin/bash
#
# Setup and deploy nginx as a test server
#

. ../kubeconfig-namespace-context

kubectl create deployment nginx --image=nginx
