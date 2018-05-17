class base_packages {

  package { 'screen':
    ensure => 'installed',
  }
  $base_packages = [
    'vim',
    'strace',
    'sudo',
    'bind-utils',
    'docker'
  ]
  package { $base_packages:  ensure => 'installed'}

}

class jenkins {

  package { 'java-1.8.0-openjdk': ensure => 'installed' }

  yumrepo { 'jenkins_repo':
    enabled  => 1,
    descr    => 'Local repo holding jenkins application packages',
    baseurl  => 'http://pkg.jenkins.io/redhat',
    gpgcheck => 1,
    gpgkey   => 'https://jenkins-ci.org/redhat/jenkins-ci.org.key'
  } ->


  package { 'jenkins':   ensure => 'installed' }

}

include base_packages
include jenkins
