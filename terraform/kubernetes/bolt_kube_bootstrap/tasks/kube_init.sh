#!/bin/bash

networking=$PT_networking

function gencreds {
  mkdir -p $HOME/.kube
  sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

case $networking in

  calico)
    echo -n "Calico networking"
    kubeadm init --pod-network-cidr=192.168.0.0/16
    gencreds
    kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
    ;;

  cilium)
    echo -n "Cilium networking"
    kubeadm init --pod-network-cidr=10.217.0.0/16
    gencreds
    kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.5/examples/kubernetes/1.14/cilium.yaml
    ;;

  flannel)
    echo -n "Flannel networking"
    kubeadm init --pod-network-cidr=10.244.0.0/16
    gencreds
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml
    ;;
esac
