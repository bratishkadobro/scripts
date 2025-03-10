# 🚀 **Инструкция по установке Kubernetes с помощью скриптов**

## 📌 **Описание скриптов**
| Скрипт                      | Описание |
|-----------------------------|------------------------------------------------------------------|
| **`remove_k8s.sh`**         | Полностью удаляет Kubernetes и очищает систему от всех данных. |
| **`install_k8s_master.sh`** | Устанавливает Kubernetes на **Master**, инициализирует кластер и устанавливает `Calico`. В конце **выводит команду для подключения Worker**. |
| **`install_k8s_worker.sh`** | Устанавливает Kubernetes на **Worker** и запрашивает команду `kubeadm join`, которую нужно скопировать с Master. |

## 🔧 **Как использовать**
1. **Удаление Kubernetes (при необходимости)**  
   На **Master** и **Worker** узлах:
   ```bash
   chmod +x remove_k8s.sh
   sudo ./remove_k8s.sh
   ```
   После выполнения **перезагрузите сервер**:
   ```bash
   reboot
   ```

2. **Установка Master-ноды**  
   На **Master** узле:
   ```bash
   chmod +x install_k8s_master.sh
   sudo ./install_k8s_master.sh
   ```
   **Скопируйте команду подключения Worker**, которая появится в конце.

3. **Установка Worker-ноды**  
   На **Worker** узле:
   ```bash
   chmod +x install_k8s_worker.sh
   sudo ./install_k8s_worker.sh
   ```
   Введите команду `kubeadm join`, которую получили на Master.

4. **Настройка `kubectl` на Worker**  
   На **Worker** выполните:
   ```bash
   mkdir -p $HOME/.kube
   scp master:/etc/kubernetes/admin.conf $HOME/.kube/config
   chown $(id -u):$(id -g) $HOME/.kube/config
   ```

Готово! 🚀