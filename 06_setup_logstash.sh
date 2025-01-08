#!/bin/bash

# Function to handle errors
handle_error() {
    echo "Error encountered during: $1"
    echo "Exiting script. Please fix the issue and restart from this step."
    exit 1
}

# Ensure previous steps are completed
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

# Install Logstash
echo "Installing Logstash..."
sudo yum install -y logstash || handle_error "Logstash installation"

# Create a Logstash configuration file
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

# Verify Logstash configuration
echo "Verifying Logstash configuration..."
sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t || handle_error "Logstash configuration test"

# Enable and start Logstash
echo "Enabling and starting Logstash..."
sudo systemctl enable logstash || handle_error "Enabling Logstash"
sudo systemctl start logstash || handle_error "Starting Logstash"

# Check Logstash status without interactive mode
echo "Checking Logstash status..."
sudo systemctl status logstash --no-pager || handle_error "Logstash status check"

# Completion message
echo "Logstash setup completed successfully!"
