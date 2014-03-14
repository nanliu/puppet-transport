# Copyright (C) 2013 VMware, Inc.
class transport::package (
) inherits transport::params {

  # net-ssh gem 2.1.4 (PE3) is incompatible with vcsa 5.5 security settings:
  package { 'net-ssh':
    ensure   => '2.7.0',
    provider => $::transport::params::provider,
  }

  package { 'net-scp':
    ensure   => '1.1.2',
    provider => $::transport::params::provider,
  }

  package { 'winrm':
    provider => $::transport::params::provider,
  }

  package { 'rest-client':
    provider => $::transport::params::provider,
  }

  # hashdiff 1.0.0 is not compatible with PE
  package { 'hashdiff':
    ensure   => '0.0.6',
    provider => $::transport::params::provider,
  }
}
