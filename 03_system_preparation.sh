#!/bin/bash

# Function to handle errors
handle_error() {
    echo "Error encountered during: $1"
    echo "Exiting script. Please fix the issue and restart from this step."
    exit 1
}

# Ensure metadata and security group setup is completed
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

# Update system packages
echo "Updating system packages..."
sudo yum update -y || handle_error "System update"

# Install Java 11 (required for Elasticsearch)
echo "Installing Java 11..."
sudo yum install -y java-11-amazon-corretto || handle_error "Java installation"

# Verify Java installation
echo "Verifying Java installation..."
java -version || handle_error "Java verification"

# Install jq for JSON parsing (if not already installed)
if ! command -v jq &>/dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo yum install -y jq || handle_error "Installing jq"
fi

# Completion message
echo "System preparation completed successfully. The system is now ready for ELK setup."
