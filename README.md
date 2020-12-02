## Tasks
 - Using Terraform, build the infrastructure resources such as PVC, subnets, instances, elb, security group, etc., in the most optimal way with Production Grade security measures.
 - Build a Kubernetes Cluster in this VPC in an internal subnet, You can use any tool todo this.
 - You may need to modify the application source code or configuration in order to make the application running on the Kubernetes cluster, e.g. make use ENV variables in 12Factor style, create Dockerfile.
 - You need to update the application dependencies [node modules] to last stable and compilable version, please document how you achieved this part.
 - Build the Docker image using GitHub actions / Circle CI / Drone CI etc.
 - Build the Kubernetes deployments or Helm charts for the application.
 - Deploy the MongoDB on either Kubernetes or EC2 with High Availability mode (master/slave) and configure it with the Application.
 - Deploy the Ingress controller such as Traefik / Kong and configure the Ingress accordingly.


## Solution:-


### EKS cluster deployment using kops


### Required Tools

- aws-cli      https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
- Terraform    https://www.terraform.io/downloads.html
- Kops         https://github.com/kubernetes/kops/blob/master/docs/install.md
- jq           https://stedolan.github.io/jq/download/


#### Configure AWS cli
If you don’t have configured AWS credentials see how to get Access Keys
And then execute:
```bash 
aws configure --profile my-profile
```
It will do a small quiz:
```bash
AWS Access Key ID [None]: AKIAIOS5ILYU233RPKEA
AWS Secret Access Key [None]: HIDDEN
Default region name [None]: us-east-1
Default output format [None]:
```
Then in order to select profile “my-profile” execute:
```bash 
export AWS_PROFILE=my-profile
```
Domain and project name

```bash
export DOMAIN=your.domain
export PROJECT_NAME=dev
```
### The state files
Both Terraform and Kops need a back-end to store their state. I will use s3 buckets for both.
```bash 
aws s3 mb s3://terraform-state.${DOMAIN}
aws s3 mb s3://kops-state.${DOMAIN}
```

### git clone the project
```bash
git clone https://github.com/shahzadkazama/TradelingDevOpsChallenge.git
cd TradelingDevOpsChallenge/Terraform_DevOps
```

### Terraform init

Init Terraform with specifying where it should store the state:

```bash
terraform init \
-backend-config "bucket=terraform-state.${DOMAIN}" \
-backend-config “key=file.state”
```
Create new workspace where state of the configuration will be stored:
```bash
terraform workspace new ${PROJECT_NAME}
```
Or select workspace if already created:
```bash
terraform workspace select ${PROJECT_NAME}
```

Your Terraform is ready for applying, so let’s do it
### Terraform apply
```bash
terraform apply -var "project_name=${PROJECT_NAME}" -var "domain=${DOMAIN}"
```

Your VPC has been created and ready to go. Let’s create k8s cluster on top of it with Kops.
### Configure Kops state
```bash
export KOPS_STATE_STORE=s3://kops-state.${DOMAIN}
```

### Kops create cluster
This cmd will only prepare configuration of the cluster and store it in the s3 bucket we specified via KOPS_STATE_STORE env variable.
```bash
kops create cluster \
--vpc=$(terraform output vpc_id) \
--master-zones=$(terraform output -json networks | jq -r '.[].availability_zone' | paste -sd, -) \
--zones=$(terraform output -json networks | jq -r '.[].availability_zone' | paste -sd, -) \
--subnets=$(terraform output -json subnet_ids | jq -r 'join(“,”)') \
--networking=calico \
--node-count=3 \
--master-size=t2.medium \
--node-size=t2.medium \
--dns-zone=${PROJECT_NAME}.${DOMAIN} \
--dns=private \
--name=${PROJECT_NAME}.${DOMAIN}
```

“dns=private” is set in order to disable DNS resolution verification as we don’t have real doamin name.
As you can see vpc, zones, master-zones, subnets comes from terraform output because VPC and Subnets already exist.
Also we don’t need to set “target=terraform” flag that doesn’t make sense as it would create additional Terraform configuration that would require additional “Terraform apply” and state and so forth.

### Review Kops clsuter configuration (optional)
```bash
kops edit ckuster --name ${PROJECT_NAME}.${DOMAIN}
```

### Apply Kops configuration
This will deploy k8s cluster:
```bash
kops update cluster --name ${PROJECT_NAME}.${DOMAIN} --yes
```
### Check the cluster (will fail):
```bash
kubectl cluster-infoTo further debug and diagnose cluster problems, use kubectl cluster-info dump Unable to connect to the server: dial tcp: lookup api.dev.your.domain on 8.8.8.8:53: no such host 
```

The error arose because the hosted zone that contains “api.dev.your.domain” DNS record is private and the domain name cannot be resolved.
In order to fix it get api endpoint ip from route53 in AWS console:

Fix it via hosts file:
```bash
sudo bash -c ‘echo “34.205.156.35 api.dev.your.domain” >> /etc/hosts’
```
Check cluster again:
```bash
kubectl cluster-info
Kubernetes master is running at https://api.dev.your.domain
KubeDNS is running at https://api.dev.your.domain/api/v1/namespaces/kube-system/services/kube-dns:dns/proxyTo further debug and diagnose cluster problems, use ‘kubectl cluster-info dump’.
```
Check the nodes:
```bash
kubectl get nodes
NAME                         STATUS   ROLES    AGE   VERSION
ip-10-0-0-156.ec2.internal   Ready    master   14m   v1.12.8
ip-10-0-1-234.ec2.internal   Ready    master   14m   v1.12.8
ip-10-0-2-157.ec2.internal   Ready    master   14m   v1.12.8
```

