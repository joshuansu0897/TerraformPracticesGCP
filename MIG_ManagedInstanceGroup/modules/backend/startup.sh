#!/bin/bash
apt-get update
apt-get install -y nginx

# Fetch instance metadata from GCP Metadata server
export NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
export IP=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
export ZONE_URI=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
export ZONE=$(basename $ZONE_URI)
export REGION=${ZONE%-[a-z]}

# Create a json response for Nginx
cat << EOF > /var/www/html/index.html
{
  "name": "$NAME",
  "ip": "$IP",
  "zone": "$ZONE",
  "region": "$REGION"
}
EOF

# Ensure Nginx serves the new page
systemctl restart nginx
