echo "Starting OpenVPN service..."
systemctl start openvpn@server
systemctl enable openvpn@server

echo "Authenticating ngrok..."
ngrok authtoken 2miMwVP1kei9yC1UDWCU5YBit84_5ixXt1q2ZwnS32X5ac8qH

echo "Starting ngrok to tunnel OpenVPN..."
ngrok tcp 1194 --region=in --log=stdout &
