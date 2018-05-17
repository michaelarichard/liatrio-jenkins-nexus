#!/bin/bash
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppet-agent git
sudo /opt/puppetlabs/bin/puppet --version

git clone https://github.com/michaelarichard/liatrio-jenkins-nexus.git
sudo /opt/puppetlabs/bin/puppet apply liatrio-jenkins-nexus/puppet/jenkins_server.pp

sudo docker ps -a
