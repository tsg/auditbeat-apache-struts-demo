#!/usr/bin/env bash
set -x

curl -s -L https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-6.2.1-amd64.deb -o auditbeat.deb
dpkg -i auditbeat.deb

cat << 'EOF' > /etc/auditbeat/auditbeat.yml
auditbeat.modules:

- module: file_integrity
  paths:
  - /tomcat7
  - /etc
  - /usr
  - /bin
  - /sbin
  recursive: true

- module: auditd
  audit_rules: |
    -a always,exit -F arch=b32 -S all -F key=32bit-abi

    ## Executions.
    -a always,exit -F arch=b64 -S execve,execveat -k exec

    ## External access (warning: these can be expensive to audit).
    -a always,exit -F arch=b64 -S accept,bind,connect -F key=external-access

    ## Identity changes.
    -w /etc/group -p wa -k identity
    -w /etc/passwd -p wa -k identity
    -w /etc/gshadow -p wa -k identity

    ## Unauthorized access attempts.
    -a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -k access
    -a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -k access

output.elasticsearch:
  hosts:
  - '${ES_HOST:http://elastic:changeme@10.0.2.2:9200}'

logging.json: true
EOF

systemctl restart auditbeat
