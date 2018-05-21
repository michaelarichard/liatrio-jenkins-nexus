#!/bin/bash
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppet-agent git
sudo /opt/puppetlabs/bin/puppet --version

git clone https://github.com/michaelarichard/liatrio-jenkins-nexus.git
sudo /opt/puppetlabs/bin/puppet apply liatrio-jenkins-nexus/puppet/jenkins_server.pp

sudo docker ps -a

pw=`sudo cat /var/lib/docker/volumes/jenkins_home/_data/secrets/initialAdminPassword`

echo #########
echo #
echo #
echo "# The Initial Jenkins PW is ${pw}"
echo #
echo #
echo ########
