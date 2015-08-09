echo "Installing dependencies..."
echo "deb http://us.archive.ubuntu.com/ubuntu vivid main universe" > /etc/apt/sources.list.d/universe.list
apt-get update -y
apt-get install -y unzip jq

echo "Fetching Consul..."
cd /tmp
wget https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip -O consul.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
mv consul /usr/local/bin/consul
mkdir -p /etc/consul.d
mkdir -p /mnt/consul
mkdir -p /etc/service

echo "Installing Upstart service..."
curl -f -s https://raw.githubusercontent.com/hashicorp/consul/master/terraform/aws/scripts/ubuntu/upstart.conf > /tmp/upstart.conf
curl -f -s https://raw.githubusercontent.com/hashicorp/consul/master/terraform/aws/scripts/ubuntu/upstart-join.conf > /tmp/upstart-join.conf
mv /tmp/upstart.conf /etc/init/consul.conf
mv /tmp/upstart-join.conf /etc/init/consul-join.conf

# Write it to the full service file
touch /etc/service/consul
touch /etc/service/consul-join
chmod 0644 /etc/service/consul
chmod 0644 /etc/service/consul-join

echo "Installing Consul KV"
curl -Lfs https://github.com/CiscoCloud/consulkv/releases/download/v0.1.1/consulkv_0.1.1_linux_amd64.tar.gz > /tmp/consulkv.tar.gz
tar -xvf /tmp/consulkv.tar.gz
mv /tmp/consulkv_*_linux_amd64/consulkv /usr/local/bin/consulkv
