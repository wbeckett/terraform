variable "user_data_script" {
  type    = string
  default = <<EOF
#!/bin/bash

touch /root/.user_data
yum update -y
yum install httpd -y
systemctl enable httpd
echo "Hello New" > /var/www/htdocs/index.html

yum install docker -y
systemctl enable docker.service
systemctl start docker.service
mkdir -p /opt/prometheus/etc/


reboot

EOF

}
