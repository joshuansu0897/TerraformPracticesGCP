#!/bin/bash
apt-get update
apt-get install -y nginx

# Fetch instance metadata from GCP Metadata server
export NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
export IP=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
export ZONE_URI=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
export ZONE=$(basename $ZONE_URI)
export REGION=${ZONE%-[a-z]}

# Create a custom landing page for Nginx
cat << EOF > /var/www/html/index.html
<!doctype html>
<html lang=en>
<head>
    <meta charset=utf-8>
    <title>Hello from $NAME</title>
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 50px; }
        h1 { color: #1a73e8; }
    </style>
</head>
<body>
    <h1>Welcome to Google Cloud Compute Engine!</h1>
    <p>Served from Instance Name: <strong>$NAME</strong></p>
    <p>Instance IP Address: <strong>$IP</strong></p>
    <p>Zone: <strong>$ZONE</strong></p>
    <p>Region: <strong>$REGION</strong></p>
</body>
</html>
EOF

# Ensure Nginx serves the new page
systemctl restart nginx
