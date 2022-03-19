#!/bin/bash

if [ "$(whomi)" != "root" ]
then
echo "Error : You must be root to run this command"
exit 1
fi
wget https://github.com/prometheus/prometheus/releases/download/v2.8.1/prometheus-2.8.1.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus
tar -xvzf prometheus-2.8.1.linux-amd64.tar.gz
mv prometheus-2.8.1.linux-amd64 prometheuspackage
cp prometheuspackage/prometheus /usr/local/bin/
cp prometheuspackage/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
cp -r prometheuspackage/consoles /etc/prometheus
cp -r prometheuspackage/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
echo Configurations should be added to the  “/etc/prometheus/prometheus.yml”
file1=/etc/prometheus/prometheus.yml
echo "global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']" > $file1

chown prometheus:prometheus /etc/prometheus/prometheus.yml
file2=/etc/systemd/system/prometheus.service
echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target" > $file2

systemctl daemon-reload
systemctl start prometheus
systemctl status prometheus
firewall-cmd --zone=public --add-port=9090/tcp --permanent
systemctl reload firewalld
clear
systemctl status prometheus
echo FINISH

