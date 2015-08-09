# Setup the join address
cat >/etc/service/consul-join << EOF
export CONSUL_JOIN="${JOIN_ADDRS}"
EOF

PUBLIC_IP=$(curl -sf ipinfo.io/ip | tr -d '\n')

# Write the flags to a temporary file
cat >/etc/service/consul << EOF
export CONSUL_FLAGS="-server -bootstrap-expect=${SERVER_COUNT} -advertise-wan=${PUBLIC_IP} -data-dir=/mnt/consul -dc=${DC_NAME} $JOIN_WAN"
EOF

echo "Starting Consul..."
start consul

echo "Joining WAN cluster..."
# TODO: if WAN_JOIN_ADDR != nil
# consul join -wan ${WAN_JOIN_ADDR}