#!/bin/bash

# Function to handle errors
handle_error() {
    echo "Error encountered during: $1"
    echo "Exiting script. Please fix the issue and restart from this step."
    exit 1
}

# Retrieve instance metadata (for public IP and instance ID)
echo "Retrieving instance metadata..."
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) || handle_error "Fetching instance ID"
if [ -z "$INSTANCE_ID" ]; then
    handle_error "Instance ID not retrieved. Ensure this is run on an EC2 instance."
fi

# Ensure jq is installed
if ! command -v jq &>/dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo yum install -y jq || handle_error "Installing jq"
fi

REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region') || handle_error "Fetching instance region"
if [ -z "$REGION" ]; then
    handle_error "Region not retrieved. Ensure instance metadata service is available."
fi

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) || handle_error "Fetching public IP"
if [ -z "$PUBLIC_IP" ]; then
    handle_error "Public IP not retrieved. Ensure instance metadata service is available."
fi

# Debugging output for metadata
echo "Instance ID: $INSTANCE_ID"
echo "Region: $REGION"
echo "Public IP: $PUBLIC_IP"

# Create a security group
echo "Creating a security group for ELK..."
SECURITY_GROUP_NAME="ELK-Setup-SG"
SECURITY_GROUP_DESCRIPTION="Security group for ELK stack setup"
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name "$SECURITY_GROUP_NAME" --description "$SECURITY_GROUP_DESCRIPTION" --region "$REGION" --query 'GroupId' --output text) || handle_error "Creating security group"

# Add necessary permissions to the security group
echo "Adding permissions to the security group..."
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION" || handle_error "Allowing SSH (22)"
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 9200 --cidr 0.0.0.0/0 --region "$REGION" || handle_error "Allowing Elasticsearch (9200)"
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 5601 --cidr 0.0.0.0/0 --region "$REGION" || handle_error "Allowing Kibana (5601)"

# Assign the security group to the instance
echo "Assigning the security group to the instance..."
aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --groups "$SECURITY_GROUP_ID" || handle_error "Assigning security group"

# Update system packages
echo "Updating system packages..."
sudo yum update -y || handle_error "System update"

# Install Java 11
echo "Installing Java 11..."
sudo yum install -y java-11-amazon-corretto || handle_error "Java installation"
java -version || handle_error "Java verification"

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
sudo systemctl enable elasticsearch || handle_error "Enabling Elasticsearch"
sudo systemctl start elasticsearch || handle_error "Starting Elasticsearch"
sudo systemctl status elasticsearch || handle_error "Elasticsearch status check"
curl -X GET "localhost:9200" || handle_error "Elasticsearch verification"

# Install Kibana
echo "Installing Kibana..."
sudo yum install -y kibana || handle_error "Kibana installation"
sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml || handle_error "Configuring Kibana"
sudo systemctl enable kibana || handle_error "Enabling Kibana"
sudo systemctl start kibana || handle_error "Starting Kibana"
sudo systemctl status kibana || handle_error "Kibana status check"

# Install Logstash
echo "Installing Logstash..."
sudo yum install -y logstash || handle_error "Logstash installation"
logstash --version || handle_error "Logstash verification"

# Create Logstash configuration file
echo "Creating Logstash configuration file..."
cat <<EOF | sudo tee /etc/logstash/conf.d/system-logs.conf > /dev/null
input {
  file {
    path => "/var/log/cloud-init.log"
    start_position => "beginning"
  }
}
filter {
  grok {
    match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} - %{GREEDYDATA:log_message}" }
  }
}
output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "system-logs-%{+YYYY.MM.dd}"
  }
  stdout { codec => rubydebug }
}
EOF

# Test Logstash configuration
echo "Testing Logstash configuration..."
sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t || handle_error "Logstash configuration test"

# Enable and start Logstash
echo "Starting Logstash service..."
sudo systemctl enable logstash || handle_error "Enabling Logstash"
sudo systemctl start logstash || handle_error "Starting Logstash"
sudo systemctl status logstash || handle_error "Logstash status check"

# Generate dummy logs for testing
echo "Generating dummy logs..."
echo "2025-01-08 06:30:00,000 - app.py[INFO]: Application started successfully" | sudo tee -a /var/log/cloud-init.log
echo "2025-01-08 06:35:00,000 - app.py[ERROR]: Connection to database failed" | sudo tee -a /var/log/cloud-init.log
echo "2025-01-08 06:40:00,000 - app.py[DEBUG]: Running background tasks" | sudo tee -a /var/log/cloud-init.log
echo "2025-01-08 06:45:00,000 - app.py[WARNING]: Memory usage high" | sudo tee -a /var/log/cloud-init.log
echo "2025-01-08 06:50:00,000 - app.py[INFO]: Application shutdown" | sudo tee -a /var/log/cloud-init.log

# Verify logs ingestion in Elasticsearch
echo "Verifying logs ingestion in Elasticsearch..."
curl -X GET "localhost:9200/system-logs-*/_search?pretty" || handle_error "Elasticsearch logs ingestion check"

# Completion message
echo "ELK stack setup completed successfully!"
echo "Access Kibana at: http://$PUBLIC_IP:5601"
