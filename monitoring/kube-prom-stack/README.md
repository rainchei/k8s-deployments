# kube-prom-stack

## Introduction
Provide easy to operate end-to-end K8s cluster monitoring.
The chart bundles with [Grafana], [Prometheus] with [Prometheus rules] using [Prometheus Operator].

See the [kube-prometheus] README for details about components, dashboards, and alerts.

## Prerequisites
- Kubernetes 1.16+
- Helm 3+

## Getting Started
Update dependencies
```
./deploy.sh update monitoring/kube-prom-stack/values/kube-example-com.yaml
```

Expose kube-proxy metrics on `0.0.0.0` (it is a workaround for issue https://github.com/kubernetes/kubernetes/issues/74011)
```
kubectl get configmap \
  -n kube-system \
  -o yaml \
  kube-proxy-config \
  | sed 's/metricsBindAddress: 127.0.0.1:10249/metricsBindAddress: 0.0.0.0:10249/g' \
  | k apply -f -
```

Create subdirectory on the filesystem (remember to update the value for `<FileSystemId>` and `<Env>`)
```
cat <<EOF | kubectl apply -n monitoring -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-busybox
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-busybox
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: efs
  csi:
    driver: efs.csi.aws.com
    volumeHandle: <FileSystemId>
---
apiVersion: batch/v1
kind: Job
metadata:
  name: efs-busybox
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: efs-busybox
        image: busybox
        command: ["/bin/sh"]
        args: ["-c", "mkdir -p /data/<Env>/monitoring/prom/prometheus-db && chown -R 1000:2000 /data/<Env>"]
        volumeMounts:
        - name: persistent-storage
          mountPath: /data
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: efs-busybox
EOF
```

Install the chart
```
./deploy.sh upgrade monitoring/kube-prom-stack/values/kube-example-com.yaml
```

Clean up
```
kubectl delete -n monitoring job efs-busybox
kubectl delete -n monitoring pvc efs-busybox
kubectl delete -n monitoring pv efs-busybox
```

<!-- MARKDOWN LINKS & IMAGES -->
[Grafana]: https://grafana.com/
[Prometheus]: https://prometheus.io/
[Prometheus rules]: https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/
[Prometheus Operator]: https://github.com/prometheus-operator/prometheus-operator
[kube-prometheus]: https://github.com/prometheus-operator/kube-prometheus
