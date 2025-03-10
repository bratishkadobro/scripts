#!/bin/bash

set -e  # Остановить скрипт при ошибке

echo -e "\n🚀 \033[1;34mУстановка Kubernetes Master Node...\033[0m"

# Подтверждение от пользователя
read -p "⚠️  ВНИМАНИЕ: Будет установлен Kubernetes Master Node. Продолжить? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "\n❌ Операция отменена."
    exit 1
fi

echo -e "\n🔄 \033[1;33mОбновление системы...\033[0m"
apt-get update && apt-get upgrade -y

echo -e "\n📥 \033[1;33mУстановка зависимостей...\033[0m"
apt-get install -y apt-transport-https ca-certificates curl

echo -e "\n📥 \033[1;33mУстановка containerd...\033[0m"
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

echo -e "\n🔄 \033[1;33mПерезапуск containerd...\033[0m"
systemctl restart containerd
systemctl enable containerd
systemctl status containerd --no-pager

echo -e "\n📥 \033[1;33mДобавление репозитория Kubernetes...\033[0m"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

echo -e "\n📥 \033[1;33mУстановка Kubernetes...\033[0m"
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo -e "\n🚫 \033[1;33mОтключение swap...\033[0m"
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo -e "\n🚀 \033[1;33mИнициализация Kubernetes Master...\033[0m"
kubeadm init --pod-network-cidr=192.168.0.0/16 | tee /root/kubeadm-init.log

echo -e "\n🔗 \033[1;33mНастройка kubectl для пользователя root...\033[0m"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo -e "\n🌐 \033[1;33mУстановка сетевого плагина Calico...\033[0m"
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml --validate=false

echo -e "\n✅ \033[1;32mMaster Node успешно установлен! Проверяем статус...\033[0m"
kubectl get nodes
kubectl get pods -n kube-system

echo -e "\n🔗 \033[1;34mКоманда для подключения Worker-узлов:\033[0m"
kubeadm token create --print-join-command | tee /root/join-command.txt
