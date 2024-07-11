#!/bin/bash

# Update package list and install Apache
sudo yum update -y
sudo yum install -y httpd

# Create an HTML file
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Example HTML</title>
</head>
<body>
    <h1>Hello, World!</h1>
</body>
</html>
EOF

# Start and enable Apache to start on boot
sudo systemctl start httpd
sudo systemctl enable httpd
