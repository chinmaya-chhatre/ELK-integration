###############################################################
# ELK Installation Script
###############################################################

# Purpose
The `ELK_installation_script.sh` is designed to automate the installation and configuration of the ELK stack (Elasticsearch, Logstash, Kibana) on an AWS EC2 instance. This script ensures that all necessary components are installed and configured step by step, providing a seamless and error-free setup.

# Pre-requisites
**Step 1: Create an IAM Role**
1. Go to the **AWS IAM Console** → **Roles**.
2. Click **Create Role**.
3. **Select Trusted Entity**:
   - Choose **AWS Service** → **EC2**.
4. Click **Next**.

**Step 2: Attach Required Managed Policies**
Attach the following **2 AWS-managed policies** to the role:

**AmazonEC2FullAccess** – Provides full EC2 control.  
**IAMReadOnlyAccess** – Allows read-only access to IAM for verification.  

1. After selecting these policies, click **Next**.
2. Name the role **`ELK-setup-role`**.
3. Click **Create Role**.

**Step 3: Add an Inline Policy for Security Group Management**
1. In the **IAM Console**, go to **Roles** → Search for **`ELK-setup-role`**.
2. Click on the role and go to the **Permissions** tab.
3. Click **"Add permissions" → "Create inline policy"**.
4. Select the **JSON** tab and paste the following:
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs"
            ],
            "Resource": "*"
        }
    ]
}
5. Click **Next**, name it **`ELK-Setup-SecurityGroup-Policy`**, and click **Create Policy**.
6. The inline policy is now attached to the role.

**Step 4: Attach the IAM Role to an EC2 Instance**

1. Go to the **EC2 Console** → **Instances**.
2. Select your EC2 instance.
3. Click **Actions** → **Security** → **Modify IAM Role**.
4. Choose **`ELK-setup-role`** and click **Update IAM Role**.

**Step 5: Verify IAM Role is Attached to the EC2 Instance**
curl -s http://169.254.169.254/latest/meta-data/iam/info
If attached correctly, you'll see the **Instance Profile ARN**.

**Step 6: Verify Permissions**
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::<AWS_ACCOUNT_ID>:role/ELK-setup-role --action-names "ec2:CreateSecurityGroup"
- If `"EvalDecision": "allowed"` appears, the setup is correct.

Now your IAM role is **properly configured for ELK installation!** 

# Overview
The `ELK_installation_script.sh` is structured to execute the following steps in sequence:
1. Fetch EC2 instance metadata to obtain required configuration details.
2. Create and configure a security group for ELK stack components.
3. Prepare the system by installing required dependencies and tools.
4. Install and configure Elasticsearch.
5. Install and configure Kibana.
6. Install and configure Logstash.
7. Run the sanity check script (`07_post_elk_installation_sanity_check.sh`) to verify the ELK stack's functionality.

# Instructions
Follow these steps to execute the installation:

```bash
# Step 1: Connect to your EC2 instance via SSH
ssh -i <your-key.pem> ec2-user@<your-ec2-public-ip>

# Step 2: Update the system and install required tools
sudo yum update -y
sudo yum install -y curl
sudo yum install -y jq
sudo yum install -y git

# Step 3: Clone or copy all required scripts into a directory
git clone https://github.com/chinmaya-chhatre/ELK-integration.git

# Browse into the cloned directory
cd ELK-integration/
# Ensure the following files are in the same directory:
# - ELK_installation_script.sh
# - 01_fetch_metadata.sh
# - 02_create_security_group.sh
# - 03_system_preparation.sh
# - 04_install_elasticsearch.sh
# - 05_install_kibana.sh
# - 06_install_logstash.sh
# - 07_post_elk_installation_sanity_check.sh

# Step 4: Make the main script executable
chmod +x ELK_installation_script.sh

# Step 5: Run the ELK installation script
./ELK_installation_script.sh

# Step 6: After the script completes, optionally run the sanity check
chmod +x 07_post_elk_installation_sanity_check.sh
./07_post_elk_installation_sanity_check.sh

Notes
The script uses sudo where necessary to handle permission issues.
Logs and outputs of each script are displayed during execution for transparency.
If any script fails, the main installation script halts, and the error message is displayed for troubleshooting.

Troubleshooting
Ensure all pre-requisites are met before executing the script.
Verify that all required scripts are in the same directory as ELK_installation_script.sh.
Check logs for any errors and retry the failed step if necessary.
