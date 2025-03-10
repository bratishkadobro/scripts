#!/bin/bash

set -e  # Останавливаем скрипт при ошибке

echo -e "\n🔥 \033[1;31mУдаление Kubernetes и очистка системы...\033[0m"

# Подтверждение от пользователя
read -p "⚠️  ВНИМАНИЕ: Это действие удалит ВСЕ данные Kubernetes! Продолжить? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "\n❌ Операция отменена."
    exit 1
fi

echo -e "\n🔻 \033[1;33mОстановка Kubernetes и всех его компонентов...\033[0m"
systemctl stop kubelet || true
systemctl stop containerd || true

echo -e "\n🔻 \033[1;33mПринудительное завершение всех контейнеров...\033[0m"
crictl stop $(crictl ps -aq) || true
crictl rm $(crictl ps -aq) || true
ps aux | grep -E 'kube|etcd|containerd' | grep -v grep | awk '{print $2}' | xargs kill -9 || true

echo -e "\n🔻 \033[1;33mСнятие hold с пакетов Kubernetes...\033[0m"
apt-mark unhold kubeadm kubectl kubelet containerd || true

echo -e "\n🔻 \033[1;33mПолный сброс kubeadm...\033[0m"
kubeadm reset -f || true

echo -e "\n🔻 \033[1;33mОчистка системы от Kubernetes...\033[0m"
rm -rf ~/.kube
rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet /etc/cni/net.d /var/lib/cni
rm -rf /var/lib/containerd /etc/containerd /var/run/containerd /var/run/kubernetes
rm -rf /var/lib/docker /etc/docker

echo -e "\n🔻 \033[1;33mОчистка iptables и IPVS...\033[0m"
iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X
ipvsadm --clear || true

echo -e "\n🔻 \033[1;33mУдаление старых пакетов Kubernetes и containerd...\033[0m"
apt-get remove --purge -y --allow-change-held-packages kubeadm kubectl kubelet containerd
apt-get autoremove -y

echo -e "\n✅ \033[1;32mУдаление завершено! Готово для чистой установки.\033[0m"
