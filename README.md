###############################################################
#ELK Installation Script
###############################################################

# Purpose
The `ELK_installation_script.sh` is designed to automate the installation and configuration of the ELK stack (Elasticsearch, Logstash, Kibana) on an AWS EC2 instance. This script ensures that all necessary components are installed and configured step by step, providing a seamless and error-free setup.

# Pre-requisites
1. An AWS EC2 instance (preferably Amazon Linux 2 or equivalent) must be running.
2. The EC2 instance should have an attached IAM role with the following permissions:
   - `ec2:CreateSecurityGroup`
   - `ec2:AuthorizeSecurityGroupIngress`
   - `ec2:ModifyInstanceAttribute`
3. The EC2 instance must have the following tools installed:
   - `curl`
   - `jq` (JSON processor)
4. Internet connectivity is required to download and install ELK components.
5. The following scripts must be present in the same directory as `ELK_installation_script.sh`:
   - `01_fetch_metadata.sh`
   - `02_create_security_group.sh`
   - `03_system_preparation.sh`
   - `04_install_elasticsearch.sh`
   - `05_install_kibana.sh`
   - `06_install_logstash.sh`
   - `07_post_elk_installation_sanity_check.sh`

# Overview
The `ELK_installation_script.sh` is structured to execute the following steps in sequence:
1. Fetch EC2 instance metadata to obtain required configuration details.
2. Create and configure a security group for ELK stack components.
3. Prepare the system by installing required dependencies and tools.
4. Install and configure Elasticsearch.
5. Install and configure Kibana.
6. Install and configure Logstash.
7. Run the sanity check script (`07_post_elk_installation_sanity_check.sh`) to verify the ELK stack's functionality.

# Instructions
Follow these steps to execute the installation:

```bash
# Step 1: Connect to your EC2 instance via SSH
ssh -i <your-key.pem> ec2-user@<your-ec2-public-ip>

# Step 2: Update the system and install required tools
sudo yum update -y
sudo yum install -y curl jq git

# Step 3: Clone or copy all required scripts into a directory
# Ensure the following files are in the same directory:
# - ELK_installation_script.sh
# - 01_fetch_metadata.sh
# - 02_create_security_group.sh
# - 03_system_preparation.sh
# - 04_install_elasticsearch.sh
# - 05_install_kibana.sh
# - 06_install_logstash.sh
# - 07_post_elk_installation_sanity_check.sh

# Step 4: Make the main script executable
chmod +x ELK_installation_script.sh

# Step 5: Run the ELK installation script
./ELK_installation_script.sh

# Step 6: After the script completes, optionally run the sanity check
chmod +x 07_post_elk_installation_sanity_check.sh
./07_post_elk_installation_sanity_check.sh

Notes
The script uses sudo where necessary to handle permission issues.
Logs and outputs of each script are displayed during execution for transparency.
If any script fails, the main installation script halts, and the error message is displayed for troubleshooting.

Troubleshooting
Ensure all pre-requisites are met before executing the script.
Verify that all required scripts are in the same directory as ELK_installation_script.sh.
Check logs for any errors and retry the failed step if necessary.
