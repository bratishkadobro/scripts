#!/bin/bash

set -e  # Остановить скрипт при ошибке

echo -e "\n🚀 \033[1;34mУстановка Kubernetes Worker Node...\033[0m"

# Подтверждение от пользователя
read -p "⚠️  ВНИМАНИЕ: Будет установлен Worker Node. Продолжить? (y/N): " CONFIRM
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

echo -e "\n🔗 \033[1;34mВведите команду для подключения к кластеру (скопируйте с Master):\033[0m"
read -p "> " JOIN_COMMAND

echo -e "\n🚀 \033[1;33mПодключение Worker Node к кластеру...\033[0m"
$JOIN_COMMAND

echo -e "\n✅ \033[1;32mWorker Node успешно подключён к кластеру!\033[0m"
