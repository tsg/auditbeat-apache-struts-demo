#!/usr/bin/env bash
set -e

dir=$(pwd)
user=$(whoami)

echo "Installing tomcat7 to $dir as $user"

# Install Java and Vim
apt-get update
apt-get install -y default-jdk vim

# Download Tomcat 7
# Source: https://tomcat.apache.org/download-70.cgi
curl -s -L http://mirror.jax.hugeserver.com/apache/tomcat/tomcat-7/v7.0.85/bin/apache-tomcat-7.0.85.tar.gz \
  -o tomcat.tar.gz

# Download Apache Struts Showcase
# Source: https://mvnrepository.com/artifact/org.apache.struts/struts2-showcase/2.3.12
curl -s -L http://central.maven.org/maven2/org/apache/struts/struts2-showcase/2.3.12/struts2-showcase-2.3.12.war \
  -o struts-showcase.war

# Install Tomcat
cd /
tar xf $dir/tomcat.tar.gz
mv apache-tomcat* tomcat7

# Install exploded war to Tomcat under /demo context.
mkdir /tomcat7/webapps/demo
cd /tomcat7/webapps/demo
jar xf $dir/struts-showcase.war

# Create a Tomcat User
useradd -r -s /sbin/nologin tomcat
chown -R tomcat: /tomcat7

cat << 'EOF' > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/tomcat7/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Tomcat
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat

echo "Installation complete."
echo "Tomcat installed to /tomcat7"
echo "Demo running as tomcat at http://localhost:8080/demo"
