#
# Makefile
#

# Check all necessary environment variables
-include ../../env.var.app.image.mk
-include ../../env.var.app.cmd.mk

-include .hzn.json.tmp.mk

OPERATOR_DASH_NAME=kubearmor-operator
NAMESPACE=openhorizon-agent

all: helm-chart operator-tar publish-service publish-policy

helm-chart:
	helm repo add kubearmor https://kubearmor.github.io/charts
	helm repo update kubearmor
	helm template kubearmor/${OPERATOR_DASH_NAME} -n ${NAMESPACE} >> ${OPERATOR_DASH_NAME}.yaml
	wget https://raw.githubusercontent.com/kubearmor/KubeArmor/main/deployments/helm/KubeArmorOperator/crds/operator.kubearmor.com_kubearmorconfigs.yaml

operator-tar:
	tar cvfz horizon/${OPERATOR_DASH_NAME}.tar.gz ${OPERATOR_DASH_NAME}.yaml operator.kubearmor.com_kubearmorconfigs.yaml
	sed -i -e 's/.*operatorYamlArchive.*/\t"operatorYamlArchive": "${OPERATOR_DASH_NAME}.tar.gz"/' horizon/service-definition.json

publish-service:
	@echo ""
	@echo "Publishing service ... "
	hzn exchange service publish -O -f horizon/service-definition.json

publish-policy:
	@echo ""
	@echo "Publishing deployment policy ... "
	hzn exchange deployment addpolicy -f horizon/deploy-policy.json deploy-policy-${EDGE_OWNER}.${EDGE_DEPLOY}.helm.operator_$(ARCH)

# This imports the variables from oprator.json
.hzn.json.tmp.mk: horizon/hzn.json
	@ hzn util configconv -f $< > $@
