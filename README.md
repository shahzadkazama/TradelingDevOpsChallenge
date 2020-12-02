## TODO Application

### setup
```
yarn install
```

### configuration

Application can be configured through the /config files or through the env variables.

### Run the application
```
yarn run start
```

## Instructions
Using Terraform, build the infrastructure resources such as PVC, subnets, instances, elb, security group, etc., in the most optimal way with Production Grade security measures.
Build a Kubernetes Cluster in this VPC in an internal subnet, You can use any tool todo this.
You may need to modify the application source code or configuration in order to make the application running on the Kubernetes cluster, e.g. make use ENV variables in 12Factor style, create Dockerfile.
You need to update the application dependencies [node modules] to last stable and compilable version, please document how you achieved this part.
Build the Docker image using GitHub actions / Circle CI / Drone CI etc.
Build the Kubernetes deployments or Helm charts for the application.
Deploy the MongoDB on either Kubernetes or EC2 with High Availability mode (master/slave) and configure it with the Application.
Deploy the Ingress controller such as Traefik / Kong and configure the Ingress accordingly.
