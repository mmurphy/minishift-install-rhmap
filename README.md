# Readme minishift-install-rhmap

## About

The script does the following
- Logs into Openshift
- Adds a docker secret to all new projects
- Prompts user for branch or tag and git checkout
- Runs ansible script for installing rhmap-core and mbaas
- Outputs the mbaas key and url


## Prerequisites
- Docker installed and logged into
- [Minishift installed](https://github.com/fheng/help/blob/master/new_hires/new_hire_chapter_2.2.md#install-minishift-locally) 
- An inventory file for your cluster in your home directory e.g. [minishift-example](https://github.com/fheng/help/blob/master/new_hires/new_hire_chapter_2.2.md#create-a-minishift-inventory-file)
- The following repos cloned to your home/work directory
  - [fh-core-openshift-templates](https://github.com/fheng/fh-core-openshift-templates)
  - [fh-openshift-templates](https://github.com/fheng/fh-openshift-templates)
  - [rhmap-ansible](https://github.com/fheng/rhmap-ansible)

## Usage
- Clone the repo `git clone https://github.com/austincunningham/minishift-install-rhmap.git`
- Change to directory `cd minishift-install-rhmap`
- Make the script runable `chmod 775 setup-rhmap.sh`
- Run the script `./setup-rhmap.sh`

## Issues
Make sure the paths in the script match you local directory structure

## More information
For more detailed information on this process see this [guide](https://github.com/fheng/help/blob/master/new_hires/new_hire_chapter_2.2.md)
