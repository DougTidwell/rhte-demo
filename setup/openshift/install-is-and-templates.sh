#!/bin/bash

DG_IS='https://raw.githubusercontent.com/jboss-container-images/jboss-datagrid-7-openshift-image/654af08e2837f0c85f9e8871c0d0178cc7eb3dc6/templates/datagrid72-image-stream.json'
AMQ_IS='https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/amq-broker-71/amq-broker-7-image-streams.yaml'

info "### INSTALLING IS FOR AMQ AND RDG"
if $(oc get is/jboss-datagrid72-openshift -n openshift > /dev/null 2>&1); then
      oc replace -f $DG_IS -n openshift --as=system:admin
else
    oc create -f $DG_IS -n openshift --as=system:admin
fi

oc -n openshift import-image jboss-datagrid72-openshift:1.1 --as=system:admin > /dev/null && echo "jboss-datagrid72-openshift:1.1 image successfully imported"

if $(oc get is/amq-broker-71-openshift -n openshift > /dev/null 2>&1); then
    oc replace -f $AMQ_IS -n openshift --as=system:admin
else
    oc create -f $AMQ_IS -n openshift --as=system:admin
fi

  oc -n openshift import-image amq-broker-71-openshift:1.0 --as=system:admin > /dev/null && echo "amq-broker-71-openshift:1.0 image successfully imported"

info "### INSTALLING TEMPLATES FOR AMQ AND RDG"

if $(oc get template/datagrid72-basic -n openshift > /dev/null 2>&1); then
    oc replace -f https://raw.githubusercontent.com/jboss-container-images/jboss-datagrid-7-openshift-image/datagrid72/templates/datagrid72-basic.json -n openshift --as=system:admin
else
    oc create -f https://raw.githubusercontent.com/jboss-container-images/jboss-datagrid-7-openshift-image/datagrid72/templates/datagrid72-basic.json -n openshift --as=system:admin
fi

if $(oc get template/amq-broker-71-basic -n openshift > /dev/null 2>&1); then
    oc replace -f https://github.com/jboss-container-images/jboss-amq-7-broker-openshift-image/raw/amq-broker-71/templates/amq-broker-71-basic.yaml -n openshift --as=system:admin
else
    oc create -f https://github.com/jboss-container-images/jboss-amq-7-broker-openshift-image/raw/amq-broker-71/templates/amq-broker-71-basic.yaml -n openshift --as=system:admin
fi

# If it does not work, try:
# $ eval $(minishift docker-env)
# $ docker pull registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.2
# $ docker pull registry.access.redhat.com/jboss-datagrid-7/datagrid72-openshift:1.1
# $ docker pull registry.access.redhat.com/amq-broker-7-tech-preview/amq-broker-71-openshift:1.0

