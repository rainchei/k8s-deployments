# aws-persistent-storage

## Introduction
Use persistent storage in Amazon Elastic Kubernetes Service (Amazon EKS) using [Amazon EFS CSI Driver].

## Prerequisites
Before you complete the steps in either section, you must:

1. [Install the AWS CLI].
2. Set AWS Identity and Access Management (IAM) permissions for creating and attaching a policy to the Amazon EKS worker node role NodeInstanceRole.
3. Create your Amazon EKS cluster and join your worker nodes to the cluster.
   Note: To verify that your worker nodes are attached to your cluster, run the `kubectl get nodes` command.

## Installation
1. Deploy the Amazon EFS CSI driver
```
./deploy.sh upgrade kube-system/aws-persistent-storage/values.yaml
```

2. Get the VPC ID for your Amazon EKS cluster
```
aws eks describe-cluster --name <cluster_name> --query "cluster.resourcesVpcConfig.vpcId" --output text
```

3. Get the CIDR range for your VPC cluster
```
aws ec2 describe-vpcs --vpc-ids vpc-xxx --query "Vpcs[].CidrBlock" --output text
```

4. Create a security group that allows inbound network file system (NFS) traffic for your Amazon EFS mount points
```
aws ec2 create-security-group --description <description> --group-name <sg_name> --vpc-id vpc-xxx
```

5. Add an NFS inbound rule to enable resources in your VPC to communicate with your Amazon EFS file system
```
aws ec2 authorize-security-group-ingress --group-id sg-xxx --protocol tcp --port 2049 --cidr x.x.x.x/x
```

6. Create an Amazon EFS system for your Amazon EKS cluster (could skip this if already have one)
```
aws efs create-file-system --creation-token <efs_name> --tags Key=Name,Value=<efs_name>
```

7. Create a mount target for the EFS, run the following command in **ALL** the Availability Zones where your worker nodes are running
```
aws efs create-mount-target --file-system-id fs-xxx --subnet-id <subnet-az-a> --security-group sg-xxx
aws efs create-mount-target --file-system-id fs-xxx --subnet-id <subnet-az-b> --security-group sg-xxx
aws efs create-mount-target --file-system-id fs-xxx --subnet-id <subnet-az-c> --security-group sg-xxx
```

8. Disable the default StorageClass that is created for certain Cloud Providers, including AWS, GCE, OpenStack, and vSphere.
The default StorageClass behavior will override manual storage provisioning, preventing PersistentVolumeClaims from automatically binding to manually created PersistentVolumes.
```
kubectl annotate storageclass gp2 storageclass.kubernetes.io/is-default-class=false --overwrite
```

The Amazon EFS file system and its mount targets are now running and should be accessible by pod in the EKS cluster.


<!-- MARKDOWN LINKS & IMAGES -->
[Amazon EFS CSI Driver]: https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/README.md#amazon-efs-csi-driver
[Install the AWS CLI]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
