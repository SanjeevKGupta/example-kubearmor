#
# Makefile
#

# Check all necessary environment variables
-include ../../env.var.app.image.mk
-include ../../env.var.app.cmd.mk

-include .hzn.json.tmp.mk

OPERATOR_DASH_NAME=kubearmor-operator
OPEARTOR_NAMESPACE=openhorizon-agent

all: helm-chart operator-tar publish-service publish-policy

helm-chart:
	mkdir -p tmp/config/crd/bases
	mkdir -p tmp/config/samples
	helm repo add kubearmor https://kubearmor.github.io/charts
	helm repo update kubearmor
	helm template kubearmor/${OPERATOR_DASH_NAME} -n ${OPEARTOR_NAMESPACE} > ./tmp/${OPERATOR_DASH_NAME}.yaml
	wget https://raw.githubusercontent.com/kubearmor/KubeArmor/main/deployments/helm/KubeArmorOperator/crds/operator.kubearmor.com_kubearmorconfigs.yaml
	mv operator.kubearmor.com_kubearmorconfigs.yaml ./tmp/config/crd/bases/.
	wget https://raw.githubusercontent.com/kubearmor/KubeArmor/main/pkg/KubeArmorOperator/config/samples/sample-config.yml
	sed -i -e 's/.*namespace: kubearmor/  namespace: ${OPEARTOR_NAMESPACE}/' sample-config.yml
	mv sample-config.yml ./tmp/config/samples/sample-config.yaml

operator-tar:
	cd tmp; \
	tar -cf ${OPERATOR_DASH_NAME}.tar   ${OPERATOR_DASH_NAME}.yaml; \
	tar -f ${OPERATOR_DASH_NAME}.tar -r config/crd/bases/operator.kubearmor.com_kubearmorconfigs.yaml; \
	tar -f ${OPERATOR_DASH_NAME}.tar -r config/samples/sample-config.yaml; \
	gzip ${OPERATOR_DASH_NAME}.tar; \
	mv ${OPERATOR_DASH_NAME}.tar.gz ../horizon/.
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
