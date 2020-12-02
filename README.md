## Tasks
 - Using Terraform, build the infrastructure resources such as PVC, subnets, instances, elb, security group, etc., in the most optimal way with Production Grade security measures.
 - Build a Kubernetes Cluster in this VPC in an internal subnet, You can use any tool todo this.
 - You may need to modify the application source code or configuration in order to make the application running on the Kubernetes cluster, e.g. make use ENV variables in 12Factor style, create Dockerfile.
 - You need to update the application dependencies [node modules] to last stable and compilable version, please document how you achieved this part.
 - Build the Docker image using GitHub actions / Circle CI / Drone CI etc.
 - Build the Kubernetes deployments or Helm charts for the application.
 - Deploy the MongoDB on either Kubernetes or EC2 with High Availability mode (master/slave) and configure it with the Application.
 - Deploy the Ingress controller such as Traefik / Kong and configure the Ingress accordingly.


## EKS cluster deployment using kops


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
