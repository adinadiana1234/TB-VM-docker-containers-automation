# Resource Manager Thingsboard automation stack

## ORM Stack to deploy a VM.Standard.E4.Flex shape on an Oracle Linux E4.Flex shape
- This script automates the setup and configuration of Docker and Docker Compose, including creating and starting services for Zookeeper, Kafka, and ThingsBoard with specific configurations and dependencies.
- this is an ORM stack to deploy Thingsboard CE on a compute with a VM.Standard.E4.Flex shape on an Oracle Linux E4.Flex shape
- it requires a VCN and a subnet where the VM will be deployed; ports TCP 22,80,443,1883 and UDP 5683 need to be open. 

## Cloudinit script

The cloudinit will perform all the steps necessary to deploy Thingsboard with Docker:
- removes exitsing docker packages
- installs docker
- starts and enables docker service
- group management: checks if the 'docker' group exists, adds the 'opc' user to the 'docker' group 
- docker compose configuration - creates the 'docker-compose.yml' file at /home/opc/docker-compose.yml with the following services: Zookeeper, Kafka, Thingsboard(mytb)
- sets ownership for the 'docker-compose.yml' file to the user 'opc'
- sets permissions for the newly created data directories /home/opc/.mytb-data and /home/opc/.mytb-logs. Ownership is set to '799'(which corresponds to the ThingsBoard service).
- runs Docker Compose as user 'opc' to start the services defined in 'docker-compose.yml'.

The docker-compose.yml file contains images for kafka and thingsboard/tb-postgres (Thingsboard using PostgreSQL database),  as described in the Thingsboard documentation here: https://thingsboard.io/docs/user-guide/install/docker/?ubuntuThingsboardQueue=kafka



The Thingsboard interface can be accessed on: http://<public_VM_IP>:8080.

You can check installation progress once logged on the VM with:
```
tail -f /var/log/cloud-init-output.log
```
You can also check that the containers were started with:
```
docker ps
```
Run this to see the logs of 'mytb':
```
docker compose logs -f mytb
```
or logs of the 'thingsboard/tb-postgres' container:
```
docker logs <container_ID>
```

**Notes: 
- the opc user is added to the docker group in the process, which allows you to run the docker command without sudo in front of it. For this change to take effect a logout/login is required in general, so if you find the above docker commands not working for you, it means you started a session with the VM before this step of the cloudinit script has run. In that case, start a new session and try again.
- the 'thingsboard/tb-postgres' is used for this installation - Recommended option for small servers with at least 1GB of RAM and minimum load (few messages per second). 2-4GB is recommended. Other options are thingsboard/tb-cassandra and thingsboard/tb. In that case the image name should be modifies in the docker-compose.yml file.

# Initial login credentials:
  - System Administrator: sysadmin@thingsboard.org / sysadmin
  - Tenant Administrator: tenant@thingsboard.org / tenant
  - Customer User: customer@thingsboard.org / customer

