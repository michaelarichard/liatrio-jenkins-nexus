#!/bin/bash
echo 'Checking Vagrant version...'
vagrant --version
# else install/upgrade
[ $? -eq 0 ] && echo "Vagrant found. Beginning 'vagrant up'" || echo "NOT FOUND. CORRECT \$PATH or INSTALL from https://www.vagrantup.com/downloads.html"

vagrant up
