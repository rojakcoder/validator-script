## Installing gcloud

Install Cloud SDK first.

```bash
# https://cloud.google.com/sdk/gcloud
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$VERSION_GCLOUD-linux-x86_64.tar.gz
tar -zxvf google-cloud-sdk-$VERSION_GCLOUD-linux-x86_64.tar.gz
mv -i google-cloud-sdk ~/
./install.sh # Basically sets up the PATH.
```

### Getting started

By default, the CloudSDK has a single configuration (think of it as a _profile_) named `default`.

Properties can be set by running either `gcloud init` or `gcloud config set`.

To work with multiple projects/authorization accounts, set up multiple configurations with `gcloud config configurations create`.

Alternatively, just run `gcloud init`.

### SSH

```bash
gcloud compute os-login ssh-keys add --key-file ~/.ssh/id_rsa_aurastake_cheeze.pub
```

### New Project

If no projects exist, create a new one:

```bash
gcloud projects create
```

### Compute API

The command below shows the compute resources available.

```bash
gcloud compute instances list
```

The first time this command is run, it prompts for the API (compute.googleapis.com) to be turned on.

Note: This will require the Compute API to be turned on. Before it can be turned on, a billing account must be linked to the project (see "Prerequsites").

```bash
GCP_PROJECT_NAME=terra-col-1 #gcloud config get-value project
GCP_ZONE=asia-southeast1-b
GCP_NODE_VAL=validator1-terra
GCP_DISK_VALIDATOR=columbus-a
GCP_IAM_EMAIL=$(gcloud iam service-accounts list --format="value(email)")
MOINT_POINT=/mnt/columbus-a
GCP_REGION=asia-southeast1

# Create the validator node.
gcloud compute instances create $GCP_NODE_VAL \
    --project=$GCP_PROJECT_NAME \
    --zone=$GCP_ZONE \
    --machine-type=n2-standard-8 \
    --network-interface=network-tier=PREMIUM,subnet=default \
    --maintenance-policy=MIGRATE \
    --service-account=335875269057-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --create-disk=auto-delete=yes,boot=yes,device-name=$GCP_NODE_VAL,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20211212,mode=rw,size=10,type=projects/$GCP_PROJECT_NAME/zones/$GCP_ZONE/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any

#### Setting up the base node
gcloud compute disks create $GCP_DISK_VALIDATOR \
    --size=400GB \
    --type=pd-ssd \
    --project=$GCP_PROJECT_NAME \
    --zone=$GCP_ZONE

gcloud compute instances attach-disk $GCP_NODE_VAL --disk $GCP_DISK_VALIDATOR --zone=$GCP_ZONE

# gcloud beta compute disks create columbus-b --project=terra-col-1 --type=pd-ssd --size=800GB --zone=us-west1-b

sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,nodiscard /dev/sdb
sudo mkdir $MOUNT_POINT
sudo mount -o discard,defaults /dev/sdb $MOUNT_POINT
```

### ~~Reconfiguring disks~~

~~First check that there are no processes accessing the filesystem.~~

```bash
fuser -v $MOUNT_POINT
```

```bash
sudo umount $MOUNT_POINT
```

```bash
gcloud compute disks resize $GCP_DISK_VALIDATOR --size 500GB --zone $GCP_ZONE
```

~~Reference: https://cloud.google.com/compute/docs/disks/detach-reattach-boot-disk~~

### Resizing disks

Disks can be resized **without** unmounting them.

Reference: https://cloud.google.com/compute/docs/disks/working-with-persistent-disks#resize_pd

### Prerequisites

**The service may need to be first enabled in the Google Admin Console.**

Go to _Apps > Additional Google services > Google Cloud Platform > Cloud Resource Manager API_

Turn on _Allow users to create GCP projects_

**Billing may also need to be enabled.**

From the dashboard, go to _Billing_ from the side menu. A prompt appears to "link a billing account".

# Monitoring

## Agent installation

```bash
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
```

Reference: https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/installation

#### LEGACY

THIS IS REPLACED WITH OPS AGENT.

```bash
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh --also-install
```

Reference: https://cloud.google.com/monitoring/agent/monitoring/installation#agent-version-debian-ubuntu

# Notes

## GCP

- asia-southeast1 is the Singapore region. There are three zones: asia-southeast1-a, asia-southeast1-b, asia-southeast1-c
- Only us-west1, us-central1 and us-east1 instances of Compute Engine qualify for the free tier. (https://cloud.google.com/free/docs/gcp-free-tier?_ga=2.234681757.-2010853228.1625020273#free-tier-usage-limits)
