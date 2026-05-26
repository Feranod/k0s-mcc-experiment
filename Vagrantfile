Vagrant.configure("2") do |config|
  config.vm.boot_timeout = 900
  config.vm.define "k0s" do |k0s|
      
    k0s.vm.box = "oraclelinux/10"
    k0s.vm.hostname = "k0s.aura.local"

    k0s.vm.network "private_network", ip: "192.168.56.12"
    k0s.vm.network "forwarded_port", guest: 30123, host: 30123, auto_correct: true
    k0s.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = true
    
      vb.memory = "8192"
      vb.cpus = "4"
    end
    k0s.vm.provision "shell", inline: <<-SHELL
      #dnf update -y
      dnf install vim plocate ipset kernel-uek-modules-extra-netfilter kernel-uek-modules kernel-uek-modules-extra-netfilter-6.12.0-107.59.3.3.el10uek.x86_64 -y
      modprobe ip_set
      modprobe ip_set_hash_net
      modprobe ip_set_hash_ip
      modprobe ip_vs
      cp /vagrant/configs/k0s-net.conf /etc/modules-load.d/k0s-net.conf
      updatedb
      systemctl start firewalld
      systemctl enable firewalld
      cp /vagrant/install/k0s-v1.35.4+k0s.0-amd64 /usr/local/bin/k0s
      cp /vagrant/install/helm4.1.4 /usr/local/bin/helm
      #curl -sSLf https://get.k0s.sh | sh
      mkdir -p /etc/k0s
      chmod 755 /etc/k0s
      chmod 755 /usr/local/bin/k0s
      firewall-cmd --permanent --zone=public --add-port=10250/tcp
      firewall-cmd --permanent --zone=public --add-masquerade
      firewall-cmd --permanent --zone=public --add-source=192.244.0.0/16
      firewall-cmd --permanent --zone=public --add-source=192.96.0.0/12
      firewall-cmd --permanent --zone=public --add-service=http
      firewall-cmd --reload
      /usr/local/bin/k0s config create > /etc/k0s/k0s.yaml
      cp /vagrant/configs/k0s.yaml /etc/k0s/k0s.yaml
      /usr/local/bin/k0s install controller --single -c /etc/k0s/k0s.yaml && /usr/local/bin/k0s start
      echo 'alias kubectl="/usr/local/bin/k0s kubectl"' >> ~/.bashrc
      /usr/local/bin/k0s completion bash > /etc/bash_completion.d/k0s
      mkdir -p ~/.kube
      # The K0s starting in 80s it seems that the config is generated during the starting/init process of K0s
      sleep 10
      /usr/local/bin/k0s kubeconfig admin > ~/.kube/config
      sleep 80
      /usr/local/bin/k0s kubectl apply -f /vagrant/configs/ingress.yaml
    SHELL
  end
  config.vm.define "podman" do |podman|
    podman.vm.box = "oraclelinux/10"
    podman.vm.hostname = "podman.aura.local"

    podman.vm.network "private_network", ip: "192.168.56.11"

    podman.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = true
    
      vb.memory = "4096"
      vb.cpus = "2"
    end
    podman.vm.provision "shell", inline: <<-SHELL
      #dnf update -y
      dnf install vim plocate podman -y
      systemctl start firewalld
      firewall-cmd --permanent --zone=public --add-port=80/tcp
      firewall-cmd --reload
    SHELL
  end
end
