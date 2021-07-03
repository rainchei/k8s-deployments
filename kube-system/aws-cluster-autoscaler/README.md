# aws-cluster-autoscaler

## Introduction
Scales Kubernetes worker nodes within autoscaling groups.

## Prerequisites
1. Helm 3+
2. Kubernetes 1.8+
3. An existing IAM OIDC provider for your cluster. To determine whether you have one, or to create one if you don't, see [Create an IAM OIDC provider for your cluster].
4. Node groups with Auto Scaling groups tags - The Cluster Autoscaler requires the following tags on your Auto Scaling groups so that they can be auto-discovered.

Key                                      | Value
-----------------------------------------|------
k8s.io/cluster-autoscaler/cluster-name   | owned
k8s.io/cluster-autoscaler/enabled        | true

## Installation
Save the following contents to a file named `cluster-autoscaler-policy.json`
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

Create an IAM policy
```
aws iam create-policy \
  --policy-name AmazonEKSClusterAutoscalerPolicy \
  --policy-document file://cluster-autoscaler-policy.json
```

Create an IAM role and attach the IAM policy created above on AWS Management Console.

1. Open the IAM console at https://console.aws.amazon.com/iam/.
2. In the navigation panel, choose **Roles**, **Create Role**.
3. In the Select type of trusted entity section, choose **Web identity**.
4. In the **Choose a web identity provider** section:
    1. For **Identity provider**, choose the URL for your cluster.
    2. For **Audience**, choose `sts.amazonaws.com`.
5. Choose **Next: Permissions**.
6. In the **Attach Policy** section, select the `AmazonEKSClusterAutoscalerPolicy` policy that you created above to use for your service account.
7. Choose **Next: Tags**.
8. On the **Add tags (optional)** screen, you can add tags for the account. Choose **Next: Review**.
9. For **Role Name**, enter a name for your role, such as `AmazonEKSClusterAutoscalerRole`, and then choose **Create Role**.
10. After the role is created, choose the role in the console to open it for editing.
11. Choose the **Trust relationships** tab, and then choose **Edit trust relationship**.
12. Find the line that looks similar to the following:

`"oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E:aud": "sts.amazonaws.com"`

13. Change the line to look like the following line. Replace <EXAMPLED539D4633E53DE1B716D3041E> with your cluster's OIDC provider ID and replace <region-code> with the Region code that your cluster is in.

`"oidc.eks.<region-code>.amazonaws.com/id/<EXAMPLED539D4633E53DE1B716D3041E>:sub": "system:serviceaccount:kube-system:aws-cluster-autoscaler"`

14. Choose **Update Trust Policy** to finish.

Deploy the Cluster Autoscaler
```
./deploy.sh upgrade kube-system/aws-cluster-autoscaler/values/kube-example-com.yaml
```

<!-- MARKDOWN LINKS & IMAGES -->
[Create an IAM OIDC provider for your cluster]: https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
