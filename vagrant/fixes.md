# Liatrio Technical Interview Experience

### 1. Install and run this vagrant box: https://app.vagrantup.com/liatrio/boxes/jenkinsnexus/versions/0.0.1 (it's a relatively large file, it may take a little while to install)
- `mkdir -p ~/git/liatrio/interview && cd ~/git/liatrio/interview`
- `mkdir -p vagrant && cd vagrant`
- Created Vagrantfile.
- Create run.sh to track steps for later use in a CI/Task.
- vagrant up
```
➜  vagrant git:(master) ✗ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'liatrio/jenkinsnexus'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'liatrio/jenkinsnexus' is up to date...
==> default: Setting the name of the VM: vagrant_default_1526346739908_37949
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 8080 (guest) => 8080 (host) (adapter 1)
    default: 8081 (guest) => 8081 (host) (adapter 1)
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default: Warning: Connection reset. Retrying...
    default: Warning: Remote connection disconnect. Retrying...
    default: Warning: Connection reset. Retrying...
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
    default: The guest additions on this VM do not match the installed version of
    default: VirtualBox! In most cases this is fine, but in rare cases it can
    default: prevent things such as shared folders from working properly. If you see
    default: shared folder errors, please make sure the guest additions within the
    default: virtual machine match the version of VirtualBox you have installed on
    default: your host and reload your VM.
    default:
    default: Guest Additions Version: 5.0.10
    default: VirtualBox Version: 5.2
==> default: Mounting shared folders...
    default: /vagrant => /Users/mrichard/git/liatrio/interview/vagrant
➜  vagrant git:(master) ✗ vagrant ssh
Last login: Tue Dec 29 17:54:07 2015 from 10.0.2.2
----------------------------------------------------------------
  CentOS 7.1.1503                             built 2015-12-21
----------------------------------------------------------------
[vagrant@localhost ~]$ sudo -s
```


### 2. Validate that both Jenkins and Nexus are installed on the VM.

  What port? SSL? Let's explore!

```➜  vagrant git:(master) ✗ vagrant ssh
Last login: Mon May 14 06:33:45 2018 from 10.0.2.2
----------------------------------------------------------------
  CentOS 7.1.1503                             built 2015-12-21
----------------------------------------------------------------
[vagrant@localhost ~]$ sudo -s
[root@localhost vagrant]# ps -ef | grep jenkins
jenkins   2294     1  1 06:17 ?        00:00:31 /etc/alternatives/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=/var/lib/jenkins -jar /usr/lib/jenkins/jenkins.war --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --daemon --httpPort=8080 --httpListenAddress=0.0.0.0 --ajp13Port=8009 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20
root      4637  4623  0 06:45 pts/0    00:00:00 grep --color=auto jenkins
 
```

- Jenkins log shows started successfully. Confirmed in /var/log/jenkins/jenkins.log
``` ...
May 14, 2018 6:18:24 AM hudson.WebAppMain$3 run
INFO: Jenkins is fully up and running
```
#### curl test from within vagrant
```[root@localhost vagrant]# curl localhost:8080```
- confirmed, looks like jenkins

#### More fixes for localhost
 - Add portforwarding to vagrant file for 8080 and 8081
 - Also Disabled guest updates for now. (They're old, kernel-devel package is missing, requires install below) 
```
...
+  config.vbguest.auto_update = false
+  config.vm.network "forwarded_port", guest: 8080, host: 8080
+  config.vm.network "forwarded_port", guest: 8081, host: 8081
...
```
-  `vagrant reload`
-  `curl localhost:8080`

### Troubleshooting.
#### No connectivity. Sadness.
- On local workstation, ensure 8080 and 8081 are available for use.
```
➜  vagrant git:(master) ✗ netstat -an | grep 8080
➜  vagrant git:(master) ✗ netstat -an | grep 8081
➜  vagrant git:(master) ✗ netstat -an | grep 80
udp4       0      0  *.61808                *.*
udp6       0      0  *.58064                *.*
udp4       0      0  *.58064                *.*
84bbeeb7c4a98269 stream      0      0                0 84bbeeb7c4a980d9                0                0 /var/run/mDNSResponder
84bbeeb7c4a980d9 stream      0      0                0 84bbeeb7c4a98269                0                0
84bbeeb7c4a98011 stream      0      0                0 84bbeeb7c4a99529                0                0 /var/run/mDNSResponder
84bbeeb7c4a99529 stream      0      0                0 84bbeeb7c4a98011                0                0
84bbeeb7c0827f49 stream      0      0                0 84bbeeb7c0828011                0                0 /var/run/mDNSResponder
84bbeeb7c0828011 stream      0      0                0 84bbeeb7c0827f49                0                0
84bbeeb7c0827e81 dgram       0      0                0 84bbeeb7bce90209                0 84bbeeb7c08280d9
84bbeeb7c08280d9 dgram       0      0                0 84bbeeb7bce90209                0 84bbeeb7c0828331
```
- on vagrant box, (using `vagrant ssh`) check that ports are available for use, and services are listening.
```
netstat -an | grep LISTEN

tcp        0      0 0.0.0.0:8081            0.0.0.0:*               LISTEN
...
tcp6       0      0 :::8009                 :::*                    LISTEN
tcp6       0      0 :::8080                 :::*                    LISTEN
```
#### Possible Issue 1. jenkins service is not listening on ipv4?
-  in /etc/sysconfig/jenkins
```
...
[root@localhost vagrant]# cat /etc/sysconfig/jenkins | grep -B4 JENKINS_LISTEN
#
# IP address Jenkins listens on for HTTP requests.
# Default is all interfaces (0.0.0.0).
#
JENKINS_LISTEN_ADDRESS=""
```
#### Possible Issue 2. AJP port not listening on ipv4?
```
...
[root@localhost vagrant]# cat /etc/sysconfig/jenkins | grep -B4 JENKINS_AJP_LISTEN
#
# IP address Jenkins listens on for Ajp13 requests.
# Default is all interfaces (0.0.0.0).
#
JENKINS_AJP_LISTEN_ADDRESS=""
...
```
 - After further destroy/testing, this hasn't happened anymore. =/ I believe it was probably something network or my personal mac related, like my docker container port clashing on my local machine.
 - OPTION: Update Vagrantfile to enable listen interfaces for main jenkins service as well as AJP on all interfaces.
 - OPTION: (Depends on security) Update the original Vagrant box to fix the install to wide open listen for everyone! re: 0.0.2?
 - OPTION: Dockerize/compartmentalize on priv_networks in containerspace to avoid local developer/workstation troubleshooting/setup time.
 - OPTION: Private Static IP's for all the things. Might clash later with other things. 

#### EXAMPLES: Add an inline script to Vagrantfile to fix broken guest utils ufor mounting of /vagrant share
```
$kernel_update = <<-KERNEL
yum update kernel -y
yum install kernel-devel -y
shutdown -r
KERNEL
...
  config.vm.provision "shell", inline: $kernel_update
...
```

 - tweak listen address issues
```
$script = <<-SCRIPT
cp /etc/sysconfig/jenkins /etc/sysconfig/jenkins.$(date +"%Y-%m-%d_%H%M%S")
sed -i 's/JENKINS_LISTEN_ADDRESS=.*/JENKINS_LISTEN_ADDRESS=\"0.0.0.0\"/' /etc/sysconfig/jenkins
sed -i 's/JENKINS_AJP_LISTEN_ADDRESS=.*/JENKINS_AJP_LISTEN_ADDRESS=\"0.0.0.0\"/' /etc/sysconfig/jenkins
service jenkins restart
SCRIPT
...
  config.vm.provision "shell", inline: $script
...
```
#### Minimal Vagrantfile
```
Vagrant.configure("2") do |config|
  config.vm.box = "liatrio/jenkinsnexus"
  config.vm.box_version = "0.0.1"
  config.vbguest.auto_update = false
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 8081, host: 8081
end
```
- Now Jenkins is accessible on http://localhost:8080
- Now Nexus is accessible on http://localhost:8081/nexus
 - DEFAULT USER/PASS=admin:admin123

#### Step 2. Complete !
