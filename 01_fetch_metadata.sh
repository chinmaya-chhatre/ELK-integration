#!/bin/bash

# Function to handle errors
handle_error() {
    echo "Error encountered during: $1"
    echo "Exiting script. Please fix the issue and restart from this step."
    exit 1
}

# Install jq for JSON parsing
echo "Installing jq..."
sudo yum install -y jq || handle_error "Failed to install jq"

# Fetch metadata token for IMDSv2

echo "Fetching metadata token..."
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
if [ $? -ne 0 ] || [ -z "$TOKEN" ]; then
    handle_error "Unable to fetch metadata token. Ensure IMDSv2 is enabled and accessible."
fi

# Retrieve instance metadata using the token
echo "Retrieving instance metadata..."

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id) || handle_error "Fetching instance ID"
if [ -z "$INSTANCE_ID" ]; then
    handle_error "Instance ID not retrieved. Ensure this is run on an EC2 instance."
fi

REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region') || handle_error "Fetching instance region"
if [ -z "$REGION" ]; then
    handle_error "Region not retrieved. Ensure instance metadata service is accessible."
fi

PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4) || handle_error "Fetching public IP"
if [ -z "$PUBLIC_IP" ]; then
    handle_error "Public IP not retrieved. Ensure instance metadata service is accessible."
fi

# Debugging output for metadata
echo "Instance Metadata Retrieved:"
echo "Instance ID: $INSTANCE_ID"
echo "Region: $REGION"
echo "Public IP: $PUBLIC_IP"

# Save metadata to a temporary file for use in subsequent scripts
echo "Saving metadata to 'metadata.env' for use in other scripts..."
cat <<EOF >metadata.env
INSTANCE_ID=$INSTANCE_ID
REGION=$REGION
PUBLIC_IP=$PUBLIC_IP
EOF

echo "Metadata retrieval completed successfully."
