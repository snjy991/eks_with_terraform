# Introduction 
This terraform template is use for creating a new eks cluster. 

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process- Using CI/CD Pipeline in azure devops or directly using terraform init, plan, apply command can launch the eks cluster
2.	Software dependencies
    1. Terraform state lock mechanism needs to be installed
    2. If basic network like vpc, subnets, nat gateway and internet gateway is not required then comment out vpc_module.tf, vpc_outputs.tf. And in eks.tf supply private subnet list in order to launch eks cluster in that network, same goes with private_nodegroup.tf.
    refer terraform/example
3. feature provides-
    1. Can create 3 tier VPC network, make neccessary change in vpc_module, uncomment the database subnet if required
    2. Can create EKS cluster with private node group, can also change the k8 api endpoint access by changing the variable cluster_endpoint_private_access, cluster_endpoint_public_access, cluster_endpoint_public_access_cidrs
    3. EKS Cluster with IRSA for more
