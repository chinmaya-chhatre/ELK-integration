#!/bin/bash

# Function to handle errors
handle_error() {
    echo "Error encountered during: $1"
    echo "Exiting script. Please fix the issue and restart from this step."
    exit 1
}

# Ensure system preparation is completed
if [ ! -f metadata.env ]; then
    handle_error "Metadata file 'metadata.env' not found. Please run '01_fetch_metadata.sh' first."
fi
if [ ! -f security_group.env ]; then
    handle_error "Security group file 'security_group.env' not found. Please run '02_create_security_group.sh' first."
fi

# Load metadata
source metadata.env

# Debugging output for metadata
echo "Loaded metadata:"
echo "Instance ID: $INSTANCE_ID"
echo "Region: $REGION"
echo "Public IP: $PUBLIC_IP"

# Import Elasticsearch GPG key
echo "Importing Elasticsearch GPG key..."
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch || handle_error "Importing GPG key"

# Add Elasticsearch repository
echo "Adding Elasticsearch repository..."
cat <<EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo > /dev/null
[elasticsearch]
name=Elasticsearch repository
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

# Install Elasticsearch
echo "Installing Elasticsearch..."
sudo yum install -y elasticsearch || handle_error "Elasticsearch installation"

# Enable and start Elasticsearch
echo "Enabling and starting Elasticsearch..."
sudo systemctl enable elasticsearch || handle_error "Enabling Elasticsearch"
sudo systemctl start elasticsearch || handle_error "Starting Elasticsearch"

# Check Elasticsearch status without interactive mode
echo "Checking Elasticsearch status..."
sudo systemctl status elasticsearch --no-pager || handle_error "Elasticsearch status check"

# Verify Elasticsearch is running
echo "Verifying Elasticsearch setup..."
curl -X GET "http://localhost:9200" || handle_error "Elasticsearch verification"

# Completion message
echo "Elasticsearch setup completed successfully!"
