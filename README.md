# k8s-deployments

## Introduction
A place for DevOps to easily deploy necessary applications to any K8s cluster.
All deployment should be implemented using [helm]. However, if it is not applicable, 
one should at least write a README.md. So other team members could easily follow up.

## Prerequisites
- Kubernetes 1.16+
- Helm 3+
  - [helm-diff]

## Getting Started
Use [deploy.sh] to run [helm commands] for charts in namespace.

Usage for [deploy.sh]:
```
./deploy.sh <helm-command> <namespace>/<chart> [<extra-arg1=v1,extra-arg2=v2...>]
```

Options for [helm commands] includes: `update`, `lint`, `diff`, `upgrade`, `uninstall`

For example. To run `helm upgrade` for chart `kube-prom-stack` in namespace `monitoring`, while overriding the chart name to `kube-prom-stack`
```
./deploy.sh diff monitoring/kube-prom-stack kube-prometheus-stack.nameOverride=kube-prom-stack
```

While adding new charts, must include an instruction within, like [monitoring/kube-prom-stack].


<!-- MARKDOWN LINKS & IMAGES -->
[helm]: https://helm.sh
[helm-diff]: https://github.com/databus23/helm-diff
[helm commands]: https://helm.sh/docs/helm/
[deploy.sh]: ./deploy.sh
[monitoring/kube-prom-stack]: ./monitoring/kube-prom-stack/README.md
