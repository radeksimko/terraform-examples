# Setup the join address
cat >/etc/service/consul-join << EOF
export CONSUL_JOIN="${JOIN_ADDRS}"
EOF

PUBLIC_IP=$(curl -sf ipinfo.io/ip | tr -d '\n')

# Write the flags to a temporary file
cat >/etc/service/consul << EOF
export CONSUL_FLAGS="-server -bootstrap-expect=${SERVER_COUNT} -data-dir=/mnt/consul -dc=${DC_NAME}"
EOF

echo "Starting Consul..."
start consul
