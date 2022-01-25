#!/bin/bash
# reads arguments - 1. instance name, 2. project id
instanceName=$1
projectId=$2

# set the timemark

timemark=$(date +%Y%m%d%H%M)

# get list of instances in the project
instancesList=$(gcloud compute instances list --project $projectId --format="csv(name,zone)")
if [[ $instancesList == "" ]]; then
    echo "Could not find the $projectId project, exiting!"
    exit 1
fi

# get requested VM and find the zone that it belongs to
instanceZone=$(echo "$instancesList" | grep $instanceName | cut -d "," -f2)
if [[ $instanceZone == "" ]]; then
    echo "Could not find the $instanceName in project $projectId, exiting!"
    exit 1
fi
echo "Processing snapshots on instance $instanceName in zone: $instanceZone"

# get list of disks attached to the instance
disks=$(gcloud compute instances describe $instanceName --zone=$instanceZone --project $projectId | sed -n -e '/disks/,/id:/ p' | grep source | cut -d "/" -f 11)
if [[ $disks == "" ]]; then
    echo "Could not enumerate disks for $instanceName VM, exiting!"
    exit 1
fi
for disk in $disks
do
    snapshotName="snap-$timemark-$disk"
    if [[ ${#snapshotName} -gt 63 ]]; then
        echo "ERROR: Cannot proceed as disk $disk snapshot name exceeds allowed 63 characters ($snapshotName), please do snapshot manually with a shorter name!"
        exit 1
    fi
done
echo "Will create snapshots of following disks:"
echo "$disks"
for disk in $disks
do
    # snapshot each disk
    gcloud compute disks snapshot $disk --zone=$instanceZone --project=$projectId --snapshot-names="snap-$timemark-$disk"
    if [ $? != "0" ]; then
        echo "Could not create snapshot for $disk, exiting!"
        exit 1
    fi
done