#!/bin/bash


echo "Installing OpenVPN..."
apt update && apt -y install openvpn easy-rsa wget unzip curl jq

echo "Setting up Easy-RSA for certificate management..."
make-cadir ~/openvpn-ca
cd ~/openvpn-ca


echo "Configuring Easy-RSA..."
cp vars.example vars
echo 'set_var EASYRSA_REQ_COUNTRY "US"' >> vars
echo 'set_var EASYRSA_REQ_PROVINCE "California"' >> vars
echo 'set_var EASYRSA_REQ_CITY "San Francisco"' >> vars
echo 'set_var EASYRSA_REQ_ORG "MyOrg"' >> vars
echo 'set_var EASYRSA_REQ_EMAIL "email@example.com"' >> vars
echo 'set_var EASYRSA_REQ_OU "MyOrgUnit"' >> vars
echo 'set_var EASYRSA_KEY_SIZE 2048' >> vars


echo "Building the CA..."
./easyrsa init-pki
./easyrsa build-ca nopass


echo "Generating server certificates..."
./easyrsa build-server-full server nopass
./easyrsa gen-dh

echo "Copying certificates to OpenVPN directory..."
cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/


echo "Creating OpenVPN server configuration..."
cat << EOF > /etc/openvpn/server.conf
port 1194
proto tcp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn-status.log
log-append /var/log/openvpn.log
verb 3
EOF


echo "Starting OpenVPN service..."
systemctl start openvpn@server
systemctl enable openvpn@server


echo "Generating client certificates using the same CA..."
./easyrsa build-client-full client1 nopass


echo "Installing ngrok..."
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O /tmp/ngrok.tgz
tar -xvzf /tmp/ngrok.tgz -C /usr/local/bin/
rm /tmp/ngrok.tgz


echo "Authenticating ngrok..."
ngrok authtoken #[Your authroken here]

echo "Starting ngrok to tunnel OpenVPN..."
ngrok tcp 1194 &


sleep 5 
NGROK_URL=$(curl --silent http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' | sed 's/tcp:\/\///')

echo "Ngrok tunnel established at: $NGROK_URL"
SERVER_IP=$(echo $NGROK_URL | cut -d: -f1)
SERVER_PORT=$(echo $NGROK_URL | cut -d: -f2)


echo "Creating client configuration..."
cat << EOF > ~/client1.ovpn
client
dev tun
proto tcp
remote $SERVER_IP $SERVER_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
ca [inline]
cert [inline]
key [inline]
remote-cert-tls server
cipher AES-256-CBC
verb 3
EOF


echo "<ca>" >> ~/client1.ovpn
cat ~/openvpn-ca/pki/ca.crt >> ~/client1.ovpn
echo "</ca>" >> ~/client1.ovpn

echo "<cert>" >> ~/client1.ovpn
cat ~/openvpn-ca/pki/issued/client1.crt >> ~/client1.ovpn
echo "</cert>" >> ~/client1.ovpn

echo "<key>" >> ~/client1.ovpn
cat ~/openvpn-ca/pki/private/client1.key >> ~/client1.ovpn
echo "</key>" >> ~/client1.ovpn

echo "Client configuration file created at ~/client1.ovpn"

echo "Setup complete! Use the generated client1.ovpn file to connect to the OpenVPN server."
