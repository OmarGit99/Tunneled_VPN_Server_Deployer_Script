# Tunneled_VPN_Server_Deployer_Script (WIP)
This project is a comprehensive implementation of a secure VPN tunnel using OpenVPN, designed specifically to overcome obstacles posed by Carrier Grade NAT (CGNAT) and Deep Packet Inspection (DPI) security mechanisms. The primary goal is to create a reliable and encrypted network pathway that maintains privacy and accessibility, even in restrictive network environments.
- Provides a workaround for CGNAT using an intermediary tunneling service
- Basic DPI evasion using encrypted tunneling
- Custom certificate management scripts for manual or semi-automated client-server authentication.

# TODO
- Improve overall security of certificate authorities
- Implement obfuscation
- Add passwords to certificate issuing
- Implement alternatives to ngrok
- Seperate functionalities between files into two, certificate generation and server deployment

# HOW TO
- Get AuthToken from NGROK and enter into script
- Run script
- Use the .ovpn client config file by importing it to your openvpn client
- Do not expose serverside keys/certs 
