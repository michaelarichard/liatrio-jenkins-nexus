# Liatrio Technical Interview Experience

### 1. Install and run this vagrant box: https://app.vagrantup.com/liatrio/boxes/jenkinsnexus/versions/0.0.1 (it's a relatively large file, it may take a little while to install)

- `mkdir vagrant`
- Created Vagrantfile.
- Create run.sh to track steps for later use in a CI/Task.
- `vagrant up`


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
- `curl localhost:8080`
- confirmed, looks like jenkins

#### Added portforwarding to vagrant file. 
 `vagrant reload`
 `curl localhost:8080`

### 
#
# No connectivity. Sadness.
# After further destroy/testing, this doesn't seem to happen anymore. =/ 
# Probably something network/mac related.
#
####
```
netstat -an | grep LISTEN

tcp        0      0 0.0.0.0:8081            0.0.0.0:*               LISTEN
...
tcp6       0      0 :::8009                 :::*                    LISTEN
tcp6       0      0 :::8080                 :::*                    LISTEN
```
#### Issue 1. jenkins service is not listening on ipv4

-  in /etc/sysconfig/jenkins
```
# IP address Jenkins listens on for HTTP requests.
# Default is all interfaces (0.0.0.0).
#
#JENKINS_LISTEN_ADDRESS=""
#
```


#### Issue 2. AJP port not listening on ipv4
```
# IP address Jenkins listens on for Ajp13 requests.
# Default is all interfaces (0.0.0.0).
#
#JENKINS_AJP_LISTEN_ADDRESS=""
#
```

#### OK, So let's fix it!
-  After further destroy/testing, this doesn't seem to happen anymore. =/
-  Probably something network/mac related. Noted.
- PLAN: Update Vagrantfile to enable listen interfaces for main jenkins service as well as AJP on all interfaces.
- BETTER ALTERNATIVE OPTION?: Update the original Vagrant box to fix the install for everyone! re: 0.0.2?

#### But for now, Let's fix it with repeatable code for the demo!
-  Add an inline script to Vagrantfile.
```
# Backup! /etc/sysconfig/jenkins -> /etc/sysconfig/jenkins.$(date +"%Y-%m-%d_%H%M%S")
# Update /etc/sysconfig/jenkins settings for *_LISTEN_ADDRESS
# restart services
```

- Now Jenkins is accessible on http://localhost:8080
- Now Nexus is accessible on http://localhost:8081/nexus
 - DEFAULT USER/PASS=admin:admin123

#### Step 2. Complete !
