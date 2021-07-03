# AWS Load Balancer Controller

## Introduction
AWS Load Balancer controller manages the following AWS resources
- Application Load Balancers to satisfy Kubernetes ingress objects
- Network Load Balancers in IP mode to satisfy Kubernetes service objects of type LoadBalancer with NLB IP mode annotation

## Security updates
**Note**: Deployed chart does not receive security updates automatically. You need to manually upgrade to a newer chart.

## Prerequisites
- Kubernetes 1.9+ for ALB, 1.20+ for NLB IP mode, or EKS 1.18
- IAM permissions

The controller runs on the worker nodes, so it needs access to the AWS ALB/NLB resources via IAM permissions. The
IAM permissions can either be setup via IAM roles for ServiceAccount or can be attached directly to the worker node IAM roles.

## Installation
Follow the instructions on [Installing the Chart] to install the Chart.


<!-- MARKDOWN LINKS & IMAGES -->
[Installing the Chart]: https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller#setup-iam-for-serviceaccount
