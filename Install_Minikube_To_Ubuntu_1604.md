## Install Minikube to Ubuntu 16.04

> <https://kubernetes.io/docs/tasks/tools/install-minikube/>

### Check virtualization is supported on Linux

```
$ egrep --color 'vmx|svm' /proc/cpuinfo
```

### Install KVM

Skip

### Install KVM driver

> <https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver>

```
$ sudo apt install libvirt-bin libvirt-daemon-system qemu-kvm
$ sudo usermod -a -G libvirt $(whoami)
$ newgrp libvirt
$ curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 \
$ && sudo install docker-machine-driver-kvm2 /usr/local/bin/
```

Fix [#3206: Error creating new host: dial tcp: missing address](https://github.com/kubernetes/minikube/issues/3206)

Install Go

```
$ wget https://dl.google.com/go/go1.12.5.linux-amd64.tar.gz
$ sudo tar -C /usr/local -xzf go1.12.5.linux-amd64.tar.gz
```

Add `export PATH=$PATH:/usr/local/go/bin` to `/etc/profile`

And

```
source /etc/profile
```

Set the `GOPATH` environment variable

Add `export GOPATH=$HOME/go` to `~/.bash_profile`

And

```
source ~/.bash_profile
```

Compile and install

```
$ sudo apt install libvirt-dev
$ test -d $GOPATH/src/k8s.io/minikube || \
$ git clone https://github.com/kubernetes/minikube.git $GOPATH/src/k8s.io/minikube
$ cd $GOPATH/src/k8s.io/minikube
$ git pull
$ make out/docker-machine-driver-kvm2
$ sudo install out/docker-machine-driver-kvm2 /usr/local/bin
```

### Install kubectl

> <https://kubernetes.io/docs/tasks/tools/install-kubectl/>

```
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
$ chmod +x ./kubectl
$ sudo mv ./kubectl /usr/local/bin/kubectl
```

### Install Minikube

```
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
$ && chmod +x minikube
$ sudo cp minikube /usr/local/bin && rm minikube
```

### Set HTTP proxy

> <https://github.com/kubernetes/minikube/blob/master/docs/http_proxy.md>

```
export HTTP_PROXY=http://123.123.123.123
export HTTPS_PROXY=http://123.123.123.123
export NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,192.168.99.0/24,192.168.39.0/24
```

### Create Minikube environmenet

Since my internal network is `172.17.0.0/16`, I need append `--docker-opt=bip=172.18.0.1/16` to `dockerd`.

```
$ minikube start --vm-driver=kvm2 --docker-env=HTTP_PROXY=$HTTP_PROXY --docker-env HTTPS_PROXY=$HTTPS_PROXY --docker-env NO_PROXY=$NO_PROXY --docker-opt=bip=172.18.0.1/16
```

### Open Dashboard

Get the dashboard URL from the command below

```
$ minikube dashboard --url
```

Get real hostname (IP address) from the command below

```
$ kubectl proxy --address='0.0.0.0' --port=0 --disable-filter=true
```

Replace hostname and access the URL.