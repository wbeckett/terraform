#!/bin/bash

set -ex

WORKDIR=/opt/prometheus/
# Some bacis prep
yum update -y
yum install docker -y
systemctl enable docker.service
systemctl start docker.service
mkdir -p $WORKDIR
cd $WORKDIR

cat <<EOF>data.tml
# User supplied data in data.tml
global:
    scrape_interval: 15s
    external_labels:
      monitor: 'prometheus'

scrape_configs:
    - job_name: 'prometheus'
      static_configs:
       - targets: ['localhost:8000']
EOF

cat <<EOF>header.tml
# from header.tml
remote_write:
    -
      url: ${ amp_1 }/api/v1/remote_write
      queue_config:
          max_samples_per_send: 1000
          max_shards: 200
          capacity: 2500
      sigv4:
           region: ${ region }
EOF

cat <<'EOF'>init_prometheus.sh
set -ex
CONFIG=$( mktemp /opt/prometheus/XXXXXXXX )
cd /opt/prometheus
cat header.tml > $CONFIG
cat data.tml >> $CONFIG
[ -e prometheus.yml ] && rm -f prometheus.yml
mv $CONFIG prometheus.yml
chmod 644 prometheus.yml

docker run -d -ti --restart unless-stopped --network=host -v /opt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.retention.size=2GB \
  --log.level=debug
EOF

bash init_prometheus.sh

sleep 60

reboot
