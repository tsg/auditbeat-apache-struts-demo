Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-9.3"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--cpuexecutioncap", 100]
    v.customize ["modifyvm", :id, "--memory",          512]
  end

  config.vm.network "forwarded_port", guest: 8080, host: 8180

  config.vm.provision "shell", path: "provision-tomcat7.sh"
  config.vm.provision "shell", path: "provision-auditbeat.sh"
end
