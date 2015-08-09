apt-get install -y awscli

# Get data
REGION=$(curl -sf http://169.254.169.254/latest/dynamic/instance-identity/document | jq --raw-output .region)
JOIN_ADDRS=$(aws --region=$REGION ec2 describe-instances --filters "Name=tag:Group,Values=consul" "Name=instance-state-name,Values=pending,running" | jq --raw-output .Reservations[].Instances[].PrivateIpAddress | tr '\n' ' ')
ZONE=$(curl -sf http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)
DC_NAME="aws-${ZONE}"
