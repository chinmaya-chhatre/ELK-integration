sudo nano elk_setup.sh
chmod +x elk_setup.sh
sudo chmod +x elk_setup.sh
./elk_setup.sh
sudo nano elk_setup.sh
clear
./elk_setup.sh
sudo rm  elk_setup.sh
sudo nano elk_setup.sh
sudo chmod +x elk_setup.sh
./elk_setup.sh 
clear
sudo nano 01_fetch_metadata.sh
sudo chmod +x 01_fetch_metadata.sh
./01_fetch_metadata.sh
curl -s http://169.254.169.254/latest/meta-data/instance-id
curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"
curl -s http://169.254.169.254/latest/meta-data/instance-id
./01_fetch_metadata.sh
rm 01_fetch_metadata.sh 
ls
sudo nano 01_fetch_metadata.sh
clear
./01_fetch_metadata.sh
sudo chmod +x 01_fetch_metadata.sh
./01_fetch_metadata.sh
sudo nano 01_fetch_metadata.sh
./01_fetch_metadata.sh
sudo nano 01_fetch_metadata.sh
clear
cat metadata.env
nano 02_create_security_group.sh
chmod +x 02_create_security_group.sh
./02_create_security_group.sh
curl -s http://169.254.169.254/latest/meta-data/iam/info
nano 02_create_security_group.sh
rm 02_create_security_group.sh 
ls
nano 02_create_security_group.sh 
chmod +x 02_create_security_group.sh
./02_create_security_group.sh
rm 02_create_security_group.sh 
nano 02_create_security_group.sh 
chmod +x 02_create_security_group.sh
./02_create_security_group.sh 
curl -s http://169.254.169.254/latest/meta-data/iam/info
curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"
clear
rm 02_create_security_group.sh 
nano 02_create_security_group.sh 
chmod +x 02_create_security_group.sh
./02_create_security_group.sh 
nano README_02_create_security_group.txt
ls
clear
nano 03_prepare_system.sh
chmod +x 03_prepare_system.sh
./03_prepare_system.sh
clear
nano 04_setup_elasticsearch.sh
chmod +x 04_setup_elasticsearch.sh
./04_setup_elasticsearch.sh
sudo systemctl status elasticsearch
clear
sudo systemctl status elasticsearch
rm 04_setup_elasticsearch.sh 
nano 04_setup_elasticsearch.sh
chmod +x 04_setup_elasticsearch.sh
./04_setup_elasticsearch.sh 
nano 02_create_security_group.sh 
nano 01_fetch_metadata.sh 
sudo nano 01_fetch_metadata.sh 
clear
ls
sudo nano 05_setup_kibana.sh
chmod +x 05_setup_kibana.sh
sudo chmod +x 05_setup_kibana.sh
./05_setup_kibana.sh
rm 05_setup_kibana.sh 
ls
sudo nano 05_setup_kibana.sh
sudo chmod +x 05_setup_kibana.sh
./05_setup_kibana.sh
clear
sudo nano 06_setup_logstash.sh
sudo chmod +x 06_setup_logstash.sh
./06_setup_logstash.sh
echo "2025-01-08 13:55:00,000 - app.py[INFO]: Application started successfully" | sudo tee -a /var/log/cloud-init.log
echo "2025-01-08 13:56:00,000 - app.py[ERROR]: Connection to database failed" | sudo tee -a /var/log/cloud-init.log
clear
curl -X GET "http://localhost:9200/system-logs-*/_search?pretty"
sudo journalctl -u logstash --no-pager | tail -n 50
sudo chown -R logstash:logstash /var/lib/logstash/queue
sudo chmod -R 755 /var/lib/logstash/queue
sudo systemctl restart logstash
clear
sudo journalctl -u logstash --no-pager | tail -n 50
clear
sudo mkdir -p /var/lib/logstash/dead_letter_queue
sudo chown -R logstash:logstash /var/lib/logstash/dead_letter_queue
sudo chmod -R 755 /var/lib/logstash/dead_letter_queue
sudo chown -R logstash:logstash /var/lib/logstash/queue
sudo chmod -R 755 /var/lib/logstash/queue
sudo systemctl restart logstash
sudo stsemctl status logstash
sudo systemctl status logstash
clear
sudo journalctl -u logstash --no-pager | tail -n 50
clear
sudo chown logstash:logstash /var/log/cloud-init.log
sudo chmod 644 /var/log/cloud-init.log
sudo systemctl restart logstash
sudo journalctl -u logstash --no-pager | tail -n 50
curl -X GET "http://localhost:9200/system-logs-*/_search?pretty"
ls
sudo nano 07_post_elk_installation_sanity_check.sh
chmod +x 07_post_elk_installation_sanity_check.sh
sudo chmod +x 07_post_elk_installation_sanity_check.sh
./07_post_elk_installation_sanity_check.sh 
clear
ls
nano README_02_create_security_group.txt 
