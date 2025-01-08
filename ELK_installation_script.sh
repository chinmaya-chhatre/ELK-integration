#!/bin/bash

# Script: ELK_installation_script.sh
# Purpose: Execute all ELK installation and configuration scripts sequentially
# Author: [Your Name]
# Date: [Date]

set -e

# Function to handle errors
handle_error() {
    echo "ERROR: $1"
    exit 1
}

echo "============================================================"
echo "ELK Installation Script"
echo "============================================================"
echo "Starting the ELK installation process..."

# STEP 1: Fetch EC2 Metadata
echo
echo "============================================================"
echo "STEP 1: Running 01_fetch_metadata.sh"
echo "============================================================"
chmod +x 01_fetch_metadata.sh || handle_error "Failed to set execute permissions for 01_fetch_metadata.sh"
./01_fetch_metadata.sh || handle_error "01_fetch_metadata.sh failed."
echo "01_fetch_metadata.sh executed successfully."
echo

# STEP 2: Create Security Group
echo "============================================================"
echo "STEP 2: Running 02_create_security_group.sh"
echo "============================================================"
chmod +x 02_create_security_group.sh || handle_error "Failed to set execute permissions for 02_create_security_group.sh"
./02_create_security_group.sh || handle_error "02_create_security_group.sh failed."
echo "02_create_security_group.sh executed successfully."
echo

# STEP 3: Prepare the System
echo "============================================================"
echo "STEP 3: Running 03_system_preparation.sh"
echo "============================================================"
chmod +x 03_system_preparation.sh || handle_error "Failed to set execute permissions for 03_system_preparation.sh"
./03_system_preparation.sh || handle_error "03_system_preparation.sh failed."
echo "03_system_preparation.sh executed successfully."
echo

# STEP 4: Install Elasticsearch
echo "============================================================"
echo "STEP 4: Running 04_install_elasticsearch.sh"
echo "============================================================"
chmod +x 04_install_elasticsearch.sh || handle_error "Failed to set execute permissions for 04_install_elasticsearch.sh"
./04_install_elasticsearch.sh || handle_error "04_install_elasticsearch.sh failed."
echo "04_install_elasticsearch.sh executed successfully."
echo

# STEP 5: Install Kibana
echo "============================================================"
echo "STEP 5: Running 05_install_kibana.sh"
echo "============================================================"
chmod +x 05_install_kibana.sh || handle_error "Failed to set execute permissions for 05_install_kibana.sh"
./05_install_kibana.sh || handle_error "05_install_kibana.sh failed."
echo "05_install_kibana.sh executed successfully."
echo

# STEP 6: Install Logstash
echo "============================================================"
echo "STEP 6: Running 06_install_logstash.sh"
echo "============================================================"
chmod +x 06_install_logstash.sh || handle_error "Failed to set execute permissions for 06_install_logstash.sh"
./06_install_logstash.sh || handle_error "06_install_logstash.sh failed."
echo "06_install_logstash.sh executed successfully."
echo

echo "============================================================"
echo "ELK Installation Completed!"
echo "============================================================"
echo "All scripts have been executed successfully. Please proceed to run the sanity check script (07_post_elk_installation_sanity_check.sh) to verify functionality."
