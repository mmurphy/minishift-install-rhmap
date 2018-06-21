#!/bin/bash

# login to docker
docker login

echo Enter your minishift ip only e.g. 192.168.64.4:
read IP
echo " "
echo $IP
echo " "
echo "IP address set in inventory file"

# Create inventory file and add your Minishift IP address
rm ~/minishift-example
cp minishift-example ~/minishift-example

sed -i '' "s/ip_address/${IP}/g" ~/minishift-example

# # setting the docker pull secret for any new pod
oc login https://$IP:8443 -u developer -p developer

# kill and remove existing observe process
kill $(ps aux | grep '[o]c_observe_dev' | awk '{print $2}')

chmod +x ./oc_observe_dev.sh
echo "premissions set on oc obeserve script"
oc observe projects -- ./oc_observe_dev.sh > /dev/null 2>&1 &
echo "observe project and set secret"


# Delete existing project if "./setup-rhmap.sh -c"
if [[ $1 = "-c" ]]
then
    echo "Deleting existing projects"
    oc delete project rhmap-core > /dev/null 2>&1
    oc delete project rhmap-1-node-mbaas > /dev/null 2>&1
    echo "Waiting for OpenShift to remove projects"
    i=1
    while [ "$i" -ne 11 ]
    do
        echo $i
        i=$[$i+1]
        sleep 1
    done
fi
# create the projects
oc new-project rhmap-core
oc new-project rhmap-1-node-mbaas

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