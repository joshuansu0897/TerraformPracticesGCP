#!/bin/bash
apt-get update
apt-get install -y nginx curl

# Install Node.js 18.x and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Create the backend proxy app
mkdir -p /opt/backend
cd /opt/backend
npm init -y
npm install express cors

cat << 'EOF' > /opt/backend/server.js
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/call', async (req, res) => {
    const { ip } = req.body;
    if (!ip) {
        return res.status(400).json({ error: 'IP is required' });
    }
    try {
        const response = await fetch(`http://${ip}`);
        const data = await response.text();
        res.json({ success: true, data: data });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Node backend running on port ${PORT}`);
});
EOF

# Setup systemd service for Node backend
cat << 'EOF' > /etc/systemd/system/node-backend.service
[Unit]
Description=Node.js Proxy Backend
After=network.target

[Service]
ExecStart=/usr/bin/node /opt/backend/server.js
Restart=always
User=root
Environment=PATH=/usr/bin:/usr/local/bin
Environment=NODE_ENV=production
WorkingDirectory=/opt/backend

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node-backend
systemctl enable node-backend

# Configure Nginx to serve the site and proxy /api/ to the Node backend
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Fetch instance metadata from GCP Metadata server
export NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
export IP=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
export ZONE_URI=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
export ZONE=$(basename $ZONE_URI)
export REGION=${ZONE%-[a-z]}

# Create a custom landing page for Nginx
cat << EOF > /var/www/html/index.html
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Hello from $NAME</title>
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 50px; background-color: #f7f9fc; }
        h1 { color: #1a73e8; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: inline-block; margin-top: 20px; text-align: left; }
        input { padding: 8px; width: 250px; border: 1px solid #ccc; border-radius: 4px; }
        button { padding: 8px 16px; background: #1a73e8; color: white; border: none; border-radius: 4px; cursor: pointer; margin-left: 10px; }
        button:hover { background: #1557b0; }
        #result { margin-top: 15px; background: #2d2d2d; color: #fff; padding: 15px; border-radius: 4px; display: none; white-space: pre-wrap; word-wrap: break-word; max-width: 600px; }
    </style>
</head>
<body>
    <h1>Welcome to Google Cloud Compute Engine!</h1>
    <p>Served from Instance Name: <strong>$NAME</strong></p>
    <p>Instance IP Address: <strong>$IP</strong></p>
    <p>Zone: <strong>$ZONE</strong></p>
    <p>Region: <strong>$REGION</strong></p>

    <div class="card">
        <h3>Call Internal Backend IP</h3>
        <div>
            <input type="text" id="ipInput" placeholder="Enter remote IP (e.g. 10.0.x.x)">
            <button onclick="callBackend()">Send Request</button>
        </div>
        <div id="result"></div>
    </div>

    <script>
        async function callBackend() {
            const ip = document.getElementById('ipInput').value;
            const resultDiv = document.getElementById('result');
            
            if (!ip) {
                alert('Please enter an IP address');
                return;
            }

            resultDiv.style.display = 'block';
            resultDiv.innerText = 'Loading...';

            try {
                // Request goes to Nginx proxy -> Node.js Backend -> Target IP
                const response = await fetch('/api/call', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ ip: ip })
                });
                const data = await response.json();
                resultDiv.innerText = JSON.stringify(data, null, 2);
            } catch (err) {
                resultDiv.innerText = 'Error: ' + err.message;
            }
        }
    </script>
</body>
</html>
EOF

# Ensure Nginx serves the new page
systemctl restart nginx
