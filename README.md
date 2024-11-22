Setup for Challenger Demo

Initial Setup on clean Ubuntu 24.04 LTS Desktop Installation

1) Run initial-setup/install_prereqs.sh and reboot when  prompted
2) Run initial-setup/add_gcr.sh with service_account.json file provided separately
3) Optional: Run initial-setup/find_axis.sh to find Axis cameras on the same subnet as the demo system

Running the Demo

1) Run start.sh to start the demo software, containers will pull from private registry first time the script is run.
2) Run stop.sh to stop the demo software

Maintenance Operations

1) maint-scripts/remove_images.sh will delete the local images so new versions can be pulled
2) maint-scripts/remove_images_volumes.sh will remove the container images and the persistent volumes resetting the demo software

Demo Configuration

<Coming Soon>
