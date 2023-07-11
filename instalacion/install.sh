# Prerequisitos:

## Desactivar la swap
sudo swapoff -a # En el inicio de sesion actual
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab # en futuros inicios de máquina

# Montar un gestor de contenedores compatible con Kubernetes - crio

## Activando algunos modulos del kernel de linux, para el trabajo con redes virtuales
sudo modprobe overlay
sudo modprobe br_netfilter

# Configuramos esos módulos del kernel

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

## Aplicamos la configuración
sudo sysctl --system

# Instalar crio:

## Dar de alta los repos de CRIO y su clave 
export OS=xUbuntu_18.04
export CRIO_VERSION=1.24

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

sudo apt update

# Instalacion de crio
sudo apt install cri-o cri-o-runc -y
apt-cache policy cri-o

# Configurar crio como servicio que arranque con el host
sudo systemctl daemon-reload
sudo systemctl enable crio --now

## TODO LISTO para instalar kubernetes!

# Instalar Kubernetes

## Alta de repos y clave:
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update

## Instalamos 3 herramientas
sudo apt install kubeadm kubelet kubectl -y
# Kubeadm es la herramienta que nos permite gestionar clusters de kubernetes: crear, borrar cluster y añadir/eliminar máquinas del cluster
# kubelet es un servicio (demonio) que queda arrancado en todos los nodos del cluster. 
#         Es el responsable de comunicarse con el gestor de contenedores local de cada nodo (crio)
# kubectl Es un cliente de kubernetes. Nos permite interactuar con el cluster.

# Fijar las versiones de esas herramienats
sudo apt-mark hold kubelet kubeadm kubectl

# SOLO en un nodo del cluster, creamos el cluster. Es el nodo que se fija como nodo del plano de control.
sudo kubeadm init --pod-network-cidr=10.10.0.0/16
                    # Pool de ips para los pods que usará la futura red virtual

# El programa anterior, aparte de montar los pods del plano de control (BBDD de kubernetes, servidor dns...etc)
# Crea el fichero de confioguración de conexción al cluster.
# Ese fichero es requerido po kubectl... y lo buscará dentro de la carpeta ~/.kube/config

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl get nodes
# Despliegue de la red virtual
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
# En este fichero recien descargado, editamos el poolIp para que coincida con el que hemos declarado al crear el cluster
kubectl apply -f custom-resources.yaml 

#Then you can join any number of worker nodes by running the following on each as root:

sudo kubeadm join 172.31.43.62:6443 --token whlf08.6s7jsbj0pbcyb4k2 \
        --discovery-token-ca-cert-hash sha256:828b8ced3c5b9baad76d914aa5e52e1d316dca858c2715fdf37dfb045ec6e825 
