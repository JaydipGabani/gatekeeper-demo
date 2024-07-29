#!/bin/bash

. ../demo-magic/demo-magic.sh

DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

clear

PROMPT_TIMEOUT=0
wait

PROMPT_TIMEOUT=1

kubectl apply -f preq_res.yaml

p "Deploy the constraint template"

pe "kubectl apply -f template.yaml"

p "View Constraint template to see a new engine and CEL rules are added"

pe "cat template.yaml"

pe "kubectl apply -f constraint.yaml"

pe "cat constraint.yaml"

p "Let's test the policy"

pe "kubectl apply -f bad_pod.yaml"

p "Note the bad pod was blocked by the Gatekeeper webhook as evaluated by the new CEL rules"

p "To ensure the ValidatingAdmissionPolicy feature is enabled for the cluster"

pe "kubectl api-resources | grep ValidatingAdmissionPolicy"

p "Now lets update gatekeeper to use the ValidatingAdmissionPolicy feature"

TYPE_SPEED=300

pe "/mount/d/go/src/github.com/open-policy-agent/gatekeeper/.staging/helm/linux-amd64/helm upgrade gatekeeper /mount/d/go/src/github.com/open-policy-agent/gatekeeper/manifest_staging/charts/gatekeeper --namespace gatekeeper-system --debug --wait --set image.repository=gatekeeper-e2e --set image.crdRepository=gatekeeper-crds --set image.release=latest --set postInstall.labelNamespace.image.repository=gatekeeper-crds --set postInstall.labelNamespace.image.tag=latest --set postInstall.labelNamespace.enabled=true --set postInstall.probeWebhook.enabled=true --set emitAdmissionEvents=true --set emitAuditEvents=true --set admissionEventsInvolvedNamespace=true --set auditEventsInvolvedNamespace=true --set disabledBuiltins={http.send} --set logMutations=true --set logLevel=DEBUG --set enableK8sNativeValidation=true --set defaultCreateVAPForTemplates=false --set defaultCreateVAPBindingForConstraints=false --set mutationAnnotations=true --set defaultCreateVAPForTemplates=true --set defaultCreateVAPBindingForConstraints=true --set enableK8sNativeValidation=true"

TYPE_SPEED=100

p "Since the generation in on, let's check if the ValidatingAdmissionPolicy resources are generated"

pe "kubectl get ValidatingAdmissionPolicy"

pe "kubectl get ValidatingAdmissionPolicyBinding"

TYPE_SPEED=50

p "Let's test the policy"

PROMPT_TIMEOUT=2

pe "kubectl apply -f bad_pod.yaml"

p "Note the bad pod was blocked by the ValidatingAdmissionPolicy admission controller"

PROMPT_TIMEOUT=2

p "Let's do a shift left validation even before we deploy the bad pod with the same CEL code using gator"

pe "gator test --experimental-enable-k8s-native-validation --filename=template.yaml --filename=constraint.yaml --filename=bad_pod.yaml"

p "Let's check if there are any bad pods already running in cluster before we deployed gatekeeper"

pe "kubectl get constraint all-must-have-label"

p "Let's look at constraint status to find out details about the violations"

pe "kubectl get constraint all-must-have-label -ojson | jq .status.violations"

TYPE_SPEED=100

PROMPT_TIMEOUT=1

p "Let's see what happens if a deployment creates a bad pod"

pe "kubectl apply -f bad_deployment.yaml"

p "Note the bad deployment was not blocked by the admission controller"

pe "kubectl get pod -n agile-bank"

pe "kubectl get deployment bad-deployment -n agile-bank -ojson | jq .status.conditions"

pe "kubectl delete -f bad_deployment.yaml"

pe "cat expansion_template.yaml"

pe "kubectl apply -f expansion_template.yaml"

pe "kubectl apply -f bad_deployment.yaml"

p "Notice that now the bad deployment was blocked by the gatekeeper admission webhook"

p "Let's use gator cli to test deployments before they are deployed for the policies applicable to pods"

pe "gator expand --filename=expansion_template.yaml --filename=bad_deployment.yaml | gator test --experimental-enable-k8s-native-validation --filename=constraint.yaml --filename=template.yaml"

kubectl delete constrainttemplates --all

kubectl delete -f preq_res.yaml

p "THE END"
