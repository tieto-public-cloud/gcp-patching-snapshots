# Snapshot script for GCP VMs
Usage:
    ./gcp-vm-snapshot.sh <vmName> <projectId>
        vmName - provide name of GCP VM
        projectId - provide id of GCP project that the VM belongs to

Script will look for VMs in the provided project
find the VM to create snapshots for
enumerate disks attached to the VM
checks length of snapshot name (maximum is 63 chars)
creates snapshot of each disk into same project

Snapshots naming pattern:
snap-<timemark>-<diskname>

