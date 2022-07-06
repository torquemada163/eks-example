# eks-example

Requirements:
+ aws-cli > 2.7.1
+ aws-iam-authenticator
+ helm
+ kubectl

Deployment (infra):
- ```terraform plan```
- ```terraform apply```
- ```aws eks update-kubeconfig --kubeconfig ~/.kube/config --region us-west-2 --name eks-example``` (for console access)
(https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
- Create DNS Record pointing to Load balancer


Deployment (app):
- ```cd app```
- ```docker build -t <registry_name/image_name> .```
- ```docker push <registry_name/image_name>```
- if needed create k8s secret for private Docker registry:
  - ```kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>```   
  (https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
- ```kubectl apply -f manifests/sample-app.yml```

Destroy:
- ```kubectl delete -f manifests/sample-app.yml```
- ```terraform destroy```