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

# Check if the security group already exists
EXISTING_SG_ID=$(aws ec2 describe-security-groups --region "$REGION" --query "SecurityGroups[?GroupName=='$SECURITY_GROUP_NAME'].GroupId" --output text)

if [ -z "$EXISTING_SG_ID" ]; then
    echo "Creating a new security group for ELK..."
    SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name "$SECURITY_GROUP_NAME" --description "$SECURITY_GROUP_DESCRIPTION" --region "$REGION" --query 'GroupId' --output text)
else
    echo "Security group already exists. Using existing Security Group ID: $EXISTING_SG_ID"
    SECURITY_GROUP_ID=$EXISTING_SG_ID
fi


if [ $? -ne 0 ] || [ -z "$SECURITY_GROUP_ID" ]; then
    handle_error "Failed to create security group. Ensure the IAM role has the 'ec2:CreateSecurityGroup' permission."
fi

echo "Security Group ID: $SECURITY_GROUP_ID"

# Add necessary permissions to the security group
echo "Adding permissions to the security group..."
add_rule_if_not_exists() {
    local group_id=$1
    local protocol=$2
    local port=$3
    local cidr=$4
    local description=$5

    # Check if rule already exists
    RULE_EXISTS=$(aws ec2 describe-security-groups --group-ids "$group_id" --query "SecurityGroups[0].IpPermissions[?FromPort==\`$port\` && IpRanges[?CidrIp=='$cidr']].FromPort" --output text --region "$REGION")

    if [ -z "$RULE_EXISTS" ]; then
        echo "Adding rule: $description..."
        aws ec2 authorize-security-group-ingress --group-id "$group_id" --protocol "$protocol" --port "$port" --cidr "$cidr" --region "$REGION" || handle_error "Adding rule: $description"
    else
        echo "Rule already exists: $description, skipping..."
    fi
}

# Add rules only if they don't already exist
add_rule_if_not_exists "$SECURITY_GROUP_ID" "tcp" 22 "0.0.0.0/0" "Allowing SSH (22)"
add_rule_if_not_exists "$SECURITY_GROUP_ID" "tcp" 9200 "0.0.0.0/0" "Allowing Elasticsearch (9200)"
add_rule_if_not_exists "$SECURITY_GROUP_ID" "tcp" 5601 "0.0.0.0/0" "Allowing Kibana (5601)"
add_rule_if_not_exists "$SECURITY_GROUP_ID" "tcp" 443 "0.0.0.0/0" "Allowing HTTPS (443)"



# Assign the security group to the instance
echo "Assigning the security group to the instance..."
aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --groups "$SECURITY_GROUP_ID" --region "$REGION" || handle_error "Assigning security group"

# Save the security group ID for use in subsequent scripts
echo "Saving Security Group ID to 'security_group.env'..."
cat <<EOF >security_group.env
SECURITY_GROUP_ID=$SECURITY_GROUP_ID
EOF

echo "Security group setup completed successfully."
