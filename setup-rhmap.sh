#!/bin/bash

# setting the docker pull secret for any new pod
oc login -u developer -p developer

rm oc_observe_dev.sh
cat > ./oc_observe_dev.sh <<EOL             
#!/bin/bash
oc secrets new docker-pull-secret .dockerconfigjson=${HOME}/.docker/config.json --namespace=\$1 2>/dev/null
if [ \$? -eq 0 ]; then
    echo "Created secret in namespace \$1" && sleep 3
    oc secrets link default docker-pull-secret --for=pull --namespace=\$1
fi
EOL
echo "oc_observe_dev created "
chmod +x ./oc_observe_dev.sh
echo "premissions set "
oc delete secret docker-pull-secret
echo "delete old secret"
oc observe projects -- ./oc_observe_dev.sh &
echo "observe project and set secret"



# checkout the correct branch e.g. release-4.6.0-rc1
echo "enter branch/tag name e.g. release-4.6.0-rc1:"
read branch

cd /nfs/work/fh-openshift-templates
git checkout "$branch"
cd /nfs/work/fh-core-openshift-templates
git checkout "$branch"
cd /nfs/work/rhmap-ansible
git checkout "$branch"


# ansible installer for rhmap
sudo ansible-playbook -i ~/minishift-example --tags=deploy -e strict_mode=false -e core_templates_dir=/nfs/work/fh-core-openshift-templates/generated -e mbaas_templates_dir=/nfs/work/fh-openshift-templates -e mbaas_target_id=test playbooks/core.yml
sudo ansible-playbook -i ~/minishift-example --tags=deploy -e strict_mode=false -e core_templates_dir=/nfs/work/fh-core-openshift-templates/generated -e mbaas_templates_dir=/nfs/work/fh-openshift-templates -e mbaas_target_id=test playbooks/1-node-mbaas.yml

# details for mbaas
oc project 1-node-mbaas
echo " "
echo "__________________________________________________________________________________________________________________ "
echo " "
echo " "
echo " "
echo "Mbaas key : "
oc env dc/fh-mbaas --list | grep FHMBAAS_KEY
echo " "
echo "Mbaas url :"
echo "https://"$(oc get route/mbaas -o template --template {{.spec.host}})