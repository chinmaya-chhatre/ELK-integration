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

# Install Kibana
echo "Installing Kibana..."
sudo yum install -y kibana || handle_error "Kibana installation"

# Configure Kibana to be accessible externally
echo "Configuring Kibana..."
sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml || handle_error "Updating Kibana configuration"

# Enable and start Kibana
echo "Enabling and starting Kibana..."
sudo systemctl enable kibana || handle_error "Enabling Kibana"
sudo systemctl start kibana || handle_error "Starting Kibana"

# Check Kibana status without interactive mode
echo "Checking Kibana status..."
sudo systemctl status kibana --no-pager || handle_error "Kibana status check"

# Verify Kibana is accessible with retries
echo "Verifying Kibana setup..."
RETRIES=5
for i in $(seq 1 $RETRIES); do
    echo "Attempt $i of $RETRIES: Checking if Kibana is accessible..."
    curl -X GET "http://localhost:5601" && {
        echo "Kibana setup completed successfully! Access Kibana at: http://$PUBLIC_IP:5601"
        exit 0
    }
    echo "Kibana is not ready yet. Retrying in 10 seconds..."
    sleep 10
done

handle_error "Kibana verification failed after $RETRIES attempts"
