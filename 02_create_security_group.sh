#!/bin/bash

# Function to handle errors
handle_error() {
    echo "Error encountered during: $1"
    echo "Exiting script. Please fix the issue and restart from this step."
    exit 1
}

# Load metadata from the previous step
if [ ! -f metadata.env ]; then
    handle_error "Metadata file 'metadata.env' not found. Please run '01_fetch_metadata.sh' first."
fi
source metadata.env

# Debugging output for metadata
echo "Loaded metadata:"
echo "Instance ID: $INSTANCE_ID"
echo "Region: $REGION"
echo "Public IP: $PUBLIC_IP"

# Ensure jq is installed
if ! command -v jq &>/dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo yum install -y jq || handle_error "Installing jq"
fi

# Fetch IMDSv2 token
echo "Fetching IMDSv2 token..."
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") || handle_error "Unable to fetch IMDSv2 token"

# Check if IAM role is attached
echo "Checking for IAM role..."
IAM_ROLE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/info | jq -r '.InstanceProfileArn' 2>/dev/null)
if [ -z "$IAM_ROLE" ]; then
    handle_error "No IAM role detected. Please attach a role with necessary permissions."
fi
echo "IAM Role Attached: $IAM_ROLE"

# Create a security group
echo "Creating a security group for ELK..."
SECURITY_GROUP_NAME="ELK-Setup-SG"
SECURITY_GROUP_DESCRIPTION="Security group for ELK stack setup"
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name "$SECURITY_GROUP_NAME" --description "$SECURITY_GROUP_DESCRIPTION" --region "$REGION" --query 'GroupId' --output text 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$SECURITY_GROUP_ID" ]; then
    handle_error "Failed to create security group. Ensure the IAM role has the 'ec2:CreateSecurityGroup' permission."
fi

echo "Security Group ID: $SECURITY_GROUP_ID"

# Add necessary permissions to the security group
echo "Adding permissions to the security group..."
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION" || handle_error "Allowing SSH (22)"
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 9200 --cidr 0.0.0.0/0 --region "$REGION" || handle_error "Allowing Elasticsearch (9200)"
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 5601 --cidr 0.0.0.0/0 --region "$REGION" || handle_error "Allowing Kibana (5601)"
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 443 --cidr 0.0.0.0/0 --region "$REGION" || handle_error "Allowing HTTPS (443)"


# Assign the security group to the instance
echo "Assigning the security group to the instance..."
aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --groups "$SECURITY_GROUP_ID" --region "$REGION" || handle_error "Assigning security group"

# Save the security group ID for use in subsequent scripts
echo "Saving Security Group ID to 'security_group.env'..."
cat <<EOF >security_group.env
SECURITY_GROUP_ID=$SECURITY_GROUP_ID
EOF

echo "Security group setup completed successfully."
