# Get data
JOIN_ADDRS=$(gcloud compute instances list -r $INSTANCE_MASK --format=json | jq --raw-output .[].networkInterfaces[0].networkIP | tr '\n' ' ')
ZONE=$(curl -sf http://metadata/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google" | awk -F/ '{print $4}' 2>/dev/null)
DC_NAME="gce-${ZONE}"
