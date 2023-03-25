### RESET CLUSTER

Use somente quando necessário!

```bash
sudo kubeadm reset cleanup-node
```

```text
[reset] Deleting contents of stateful directories: [/var/lib/etcd /var/lib/kubelet /var/lib/dockershim /var/run/kubernetes /var/lib/cni]

The reset process does not clean CNI configuration. To do so, you must remove /etc/cni/net.d

The reset process does not reset or clean up iptables rules or IPVS tables.
If you wish to reset iptables, you must do so manually by using the "iptables" command.

If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
to reset your system's IPVS tables.

The reset process does not clean your kubeconfig files and you must remove them manually.
Please, check the contents of the $HOME/.kube/config file.
```

```bash
sudo rm -f /etc/cni/net.d/10-flannel.conflist
sudo rm -f /opt/cni/bin/flannel
```

```bash
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
```

```bash
sudo rm -f $HOME/.kube/config
```
