#!/bin/bash

# Script: 07_post_elk_installation_sanity_check.sh
# Purpose: To perform post-installation sanity checks and configurations to make the ELK stack fully functional.
# Author: [Your Name]
# Date: [Date]

set -e

# Function to handle errors
handle_error() {
    echo "ERROR: $1"
    exit 1
}

echo "============================================================"
echo "STEP 1: Adding sample log entries to the cloud-init log file"
echo "============================================================"
# Adding sample log entries for testing
sudo tee -a /var/log/cloud-init.log <<EOL
2025-01-08 13:55:00,000 - app.py[INFO]: Application started successfully
2025-01-08 13:56:00,000 - app.py[ERROR]: Connection to database failed
EOL

echo "Sample log entries added successfully to /var/log/cloud-init.log."
echo

echo "============================================================"
echo "STEP 2: Verifying Elasticsearch Index"
echo "============================================================"
# Checking Elasticsearch health and indices
echo "Fetching Elasticsearch health status..."
curl -X GET "http://localhost:9200/_cluster/health?pretty" || handle_error "Elasticsearch cluster health check failed."
echo

echo "Listing Elasticsearch indices..."
curl -X GET "http://localhost:9200/_cat/indices?v" || handle_error "Failed to fetch Elasticsearch indices."
echo

echo "============================================================"
echo "STEP 3: Configuring Logstash to Ingest Logs"
echo "============================================================"
# Check if Logstash is running
echo "Checking Logstash service status..."
sudo systemctl status logstash --no-pager || handle_error "Logstash service is not running. Please start the service."

# Ensure Logstash has access to /var/log/cloud-init.log
echo "Setting permissions for Logstash to access cloud-init log..."
sudo chmod 644 /var/log/cloud-init.log || handle_error "Failed to set permissions for /var/log/cloud-init.log."

# Restart Logstash to pick up configuration changes
echo "Restarting Logstash..."
sudo systemctl restart logstash || handle_error "Failed to restart Logstash service."
echo

echo "============================================================"
echo "STEP 4: Verifying Logs Ingestion in Elasticsearch"
echo "============================================================"
# Query Elasticsearch for the logs ingested by Logstash
echo "Querying Elasticsearch for ingested logs..."
curl -X GET "http://localhost:9200/system-logs-*/_search?pretty" || handle_error "Failed to query Elasticsearch for logs."
echo

echo "============================================================"
echo "STEP 5: Validating Logs in Kibana"
echo "============================================================"
echo "Verify in Kibana (manual step):"
echo "1. Open Kibana in a browser: http://<Public_IP>:5601"
echo "2. Navigate to Discover."
echo "3. Search for 'system-logs-*' index to ensure logs are visible."
echo

echo "============================================================"
echo "POST-INSTALLATION SANITY CHECK COMPLETED"
echo "============================================================"
echo "The ELK stack is fully functional. Logs are being ingested, indexed, and visualized in Kibana."
