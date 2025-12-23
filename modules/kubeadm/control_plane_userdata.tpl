#!/bin/bash
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/

swapoff -a

hostnamectl set-hostname ${hostname}

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

sleep 30 # wait for network
apt-get update
apt-get install -y curl yamllint containerd unzip
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i.bak 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

apt-get install -y apt-transport-https ca-certificates gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${kubernetes_version}/deb/Release.key | gpg --no-tty --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${kubernetes_version}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet=${kubernetes_version_full} kubeadm=${kubernetes_version_full} kubectl=${kubernetes_version_full} etcd-client
apt-mark hold kubelet kubeadm kubectl

kubeadm init --apiserver-cert-extra-sans $(ec2metadata --public-ipv4)
useradd ssm-user -d /home/ssm-user
echo "ssm-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ssm-agent-users
mkdir -p /home/ssm-user/.kube /home/ssm-user/pki
cp /etc/kubernetes/admin.conf /home/ssm-user/.kube/config
cp /etc/kubernetes/pki/apiserver-etcd-client.* /home/ssm-user/pki/
cp /etc/kubernetes/pki/etcd/ca.crt /home/ssm-user/pki/
chown -R ssm-user:ssm-user /home/ssm-user/.kube
echo "export KUBECONFIG=/home/ssm-user/.kube/config" >> /home/ssm-user/.bashrc
echo "set -o vi" >> /home/ssm-user/.bashrc
echo "syntax on" > /home/ssm-user/.vimrc
echo "set tabstop=4" >> /home/ssm-user/.vimrc
echo "set shiftwidth=4" >> /home/ssm-user/.vimrc
echo "set expandtab" >> /home/ssm-user/.vimrc
echo "autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab" >> /home/ssm-user/.vimrc
echo "export ETCDCTL_API=3" >> /home/ssm-user/.bashrc
echo "export ETCDCTL_CACERT=/home/ssm-user/pki/ca.crt" >> /home/ssm-user/.bashrc
echo "export ETCDCTL_CERT=/home/ssm-user/pki/apiserver-etcd-client.crt" >> /home/ssm-user/.bashrc
echo "export ETCDCTL_KEY=/home/ssm-user/pki/apiserver-etcd-client.key" >> /home/ssm-user/.bashrc

aws ssm put-parameter --region ${region} --name /k8s-lab/kubeadm/join-string --value "$(kubeadm token create --print-join-command)" --overwrite

CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$${CILIUM_CLI_VERSION}/cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-$${CLI_ARCH}.tar.gz.sha256sum
tar xzvfC cilium-linux-$${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}
sudo -u ssm-user cilium install

curl -O https://get.helm.sh/helm-v3.19.0-linux-amd64.tar.gz
tar xzf helm-v3.19.0-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx

aws ssm put-parameter --region ${region} \
    --name /k8s-lab/kubectl/certificate-authority-data \
    --value "$(grep certificate-authority-data /etc/kubernetes/admin.conf  | awk -F': ' '{print $2}')" --overwrite
aws ssm put-parameter --region ${region} \
    --name /k8s-lab/kubectl/client-certificate-data \
    --value "$(grep client-certificate-data /etc/kubernetes/admin.conf  | awk -F': ' '{print $2}')" --overwrite
aws ssm put-parameter --region ${region} \
    --name /k8s-lab/kubectl/client-key-data \
    --value "$(grep client-key-data /etc/kubernetes/admin.conf  | awk -F': ' '{print $2}')" --overwrite
