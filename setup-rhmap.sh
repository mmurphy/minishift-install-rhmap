#!/bin/bash

# login to docker
docker login

# setting the docker pull secret for any new pod
oc login -u developer -p developer

# kill and remove existing observe process
rm oc_observe_dev.sh
kill $(ps aux | grep '[o]c_observe_dev' | awk '{print $2}')

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
oc observe projects -- ./oc_observe_dev.sh > /dev/null 2>&1 &
echo "observe project and set secret"


# Delete existing project if "./setup-rhmap.sh -c"
if [[ $1 = "-c" ]]
then
    echo "Deleting existing projects"
    oc delete project rhmap-core
    oc delete project rhmap-1-node-mbaas
fi
# create the projects
oc new-project rhmap-core
oc new-project rhmap-1-node-mbaas

# Create inventory file and add your Minishift IP address
rm ~/minishift-example
cp minishift-example ~/minishift-example
echo Enter your Minishift IP address :
read IP
echo " "
echo $IP
echo " "
echo "IP address set in inventory file"
sed -i "s/ip_address/${IP}/g" ~/minishift-example

# checkout the correct branch e.g. release-4.6.0-rc1
echo "enter branch/tag name e.g. release-4.6.0-rc1:"
read branch

cd ~/work/fh-openshift-templates
git checkout master 
git pull upstream master
git fetch upstream master --prune --tags
git checkout "$branch"
cd ~/work/fh-core-openshift-templates
git checkout master 
git pull upstream master
git fetch upstream master --prune --tags
git checkout "$branch"
cd ~/work/rhmap-ansible
git checkout master 
git pull upstream master
git fetch upstream master --prune --tags
git checkout "$branch"


# ansible installer for rhmap
sudo ansible-playbook -i ~/minishift-example --tags=deploy -e strict_mode=false -e core_templates_dir=~/work/fh-core-openshift-templates/generated -e mbaas_templates_dir=~/work/fh-openshift-templates -e mbaas_target_id=test playbooks/core.yml
sudo ansible-playbook -i ~/minishift-example --tags=deploy -e strict_mode=false -e core_templates_dir=~/work/fh-core-openshift-templates/generated -e mbaas_templates_dir=~/work/fh-openshift-templates -e mbaas_target_id=test playbooks/1-node-mbaas.yml

# details for mbaas
oc project rhmap-1-node-mbaas
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