# example-apps-stack

## Introduction
Provide easy to operate all-in-one app deployments.

## Prerequisites
- Kubernetes 1.16+
- Helm 3+

## Getting Started
Update dependencies
```
./deploy.sh update example/example-apps-stack/values/kube-example-com.yaml
```

Create subdirectory on the filesystem (remember to update the value for `<FileSystemId>` and `<Env>/<Namespace>/<Component>`)
```
cat <<EOF | kubectl apply -n example -f -
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
        args: ["-c", "mkdir -p /data/<Env>/<Namespace>/<Component> && chown -R 1000:2000 /data/<Env>"]
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
./deploy.sh upgrade example/example-apps-stack/values/kube-example-com.yaml
```

Clean up
```
kubectl delete -n example pvc efs-busybox
kubectl delete -n example pv efs-busybox
kubectl delete -n example job efs-busybox
```

<!-- MARKDOWN LINKS & IMAGES -->
[example]: https://example.com/
