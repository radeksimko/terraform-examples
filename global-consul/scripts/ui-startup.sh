# Install UI
curl -f -L -s https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip > /tmp/consul-web-ui.zip
unzip /tmp/consul-web-ui.zip -d /tmp/

# Setup the join address
cat >/etc/service/consul-join << EOF
export CONSUL_JOIN="${JOIN_ADDRS}"
EOF

# Write the flags to a temporary file
cat >/etc/service/consul << EOF
export CONSUL_FLAGS="-data-dir /tmp/ -ui-dir /tmp/dist -client=0.0.0.0 -dc=$DC_NAME"
EOF

echo "Starting Consul..."
start consul
