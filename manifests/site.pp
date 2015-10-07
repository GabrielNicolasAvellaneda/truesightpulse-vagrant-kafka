# Explictly set to avoid warning message
Package {
  allow_virtual => false,
}

node /ubuntu/ {

  file { 'bash_profile':
    path    => '/home/vagrant/.bash_profile',
    ensure  => file,
    source  => '/vagrant/manifests/bash_profile',
    before => Class['kafka']
  }

  exec { 'update-apt-packages':
    command => '/usr/bin/apt-get update -y',
  }

  # Install Zookeeper at 127.0.0.1
  class { 'zookeeper':
    client_ip => $::ipaddress_lo,
    require => Exec['update-apt-packages'],
    before => Class['kafka']
  }

  # Configure a Kafka Broker
  class {'kafka':
    version => $::kafka_version,
    scala_version => $::scala_version,
    install_dir => "/opt/kafka-bin",
    require => Class['zookeeper'],
    before => Class['kafka::broker']
  }

  class {'kafka::broker':
    config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' },
    require => Class['kafka']
  }

  class { 'boundary':
    token => $::boundary_api_token,
  }

}

# Separate the Cento 7.0 install until the boundary meter puppet package is fixed
node /^centos-7-0/ {
  file { 'bash_profile':
    path    => '/home/vagrant/.bash_profile',
    ensure  => file,
    source  => '/vagrant/manifests/bash_profile',
    before => Class['kafka']
  }

  exec { 'update-rpm-packages':
    command => '/usr/bin/yum update -y',
  }

  package {'epel-release':
    ensure => 'installed',
    require => Exec['update-rpm-packages'],
  }

  # Install Zookeeper at 127.0.0.1
  class { 'zookeeper':
    repo => 'cloudera',
    packages => ['zookeeper', 'zookeeper-server'],
    service_name => 'zookeeper-server',
    initialize_datastore => true,
    client_ip => $::ipaddress_lo,
    require => Exec['update-rpm-packages'],
    before => Class['kafka']
  }

  # Configure a Kafka Broker
  class {'kafka':
    version => $::kafka_version,
    scala_version => $::scala_version,
    install_dir => "/opt/kafka-bin",
    require => Class['zookeeper'],
    before => Class['kafka::broker']
  }

  class {'kafka::broker':
    config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' },
    require => Class['kafka']
  }

}

node /^centos/ {

  file { 'bash_profile':
    path    => '/home/vagrant/.bash_profile',
    ensure  => file,
    source  => '/vagrant/manifests/bash_profile',
    before => Class['kafka']
  }

  exec { 'update-rpm-packages':
    command => '/usr/bin/yum update -y',
  }

  # Install Zookeeper at 127.0.0.1
  class { 'zookeeper':
    repo => 'cloudera',
    packages => ['zookeeper', 'zookeeper-server'],
    service_name => 'zookeeper-server',
    initialize_datastore => true,
    client_ip => $::ipaddress_lo,
    require => Exec['update-rpm-packages'],
    before => Class['kafka']
  }

  # Configure a Kafka Broker
  class {'kafka':
    version => $::kafka_version,
    scala_version => $::scala_version,
    install_dir => "/opt/kafka-bin",
    require => Class['zookeeper'],
    before => Class['kafka::broker']
  }

  class {'kafka::broker':
    config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' },
    require => Class['kafka']
  }

  class { 'boundary':
    token => $::boundary_api_token
  }

}
