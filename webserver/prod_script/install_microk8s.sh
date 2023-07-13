sudo snap install microk8s --classic
sudo usermod -a -G microk8s $USER
newgrp microk8s
sudo ufw allow in on cni0 && sudo ufw allow out on cni0
sudo ufw default allow routed
microk8s enable dns dashboard storage
microk8s kubectl get all --all-namespaces
token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl -n kube-system describe secret $token
microk8s dashboard-proxy
