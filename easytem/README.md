1. Verify IP Forwarding:
Ensure that IP forwarding is enabled on the server:
   # Check if IP forwarding is enabled
   sysctl net.ipv4.ip_forward

   # If it returns 0, enable it
   echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

   # Make it persistent
   sudo nano /etc/sysctl.conf
   # Ensure this line is present and uncommented
   net.ipv4.ip_forward=1

   # Apply changes
   sudo sysctl -p

2. Check and Set Up iptables Rules:
Ensure that the iptables rules are correctly set up to allow NAT for the VPN subnet:
   # Flush existing rules
   sudo iptables -F
   sudo iptables -t nat -F

   # Set default policies
   sudo iptables -P INPUT ACCEPT
   sudo iptables -P FORWARD ACCEPT
   sudo iptables -P OUTPUT ACCEPT

   # Enable NAT for the VPN subnet
   sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o enX0 -j MASQUERADE

   # Allow traffic from and to the VPN
   sudo iptables -A FORWARD -i tun0 -o enX0 -j ACCEPT
   sudo iptables -A FORWARD -i enX0 -o tun0 -j ACCEPT

   # Save the rules (for Ubuntu/Debian)
   sudo iptables-save | sudo tee /etc/iptables/rules.v4