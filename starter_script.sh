echo "Starting OpenVPN service..."
systemctl start openvpn@server
systemctl enable openvpn@server

echo "Authenticating ngrok..."
ngrok authtoken [authtoken]

echo "Starting ngrok to tunnel OpenVPN..."
ngrok tcp 1194 --region=in --log=stdout &
