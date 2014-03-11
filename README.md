# Transport Library for Puppet Modules

[![Build Status](https://travis-ci.org/nanliu/puppet-transport.png?branch=master)](https://travis-ci.org/nanliu/puppet-transport)

Transport allows puppet to communicate with remote Systems/APIs and manage them as resources. By default the connectivity credentials is stored in the transport resource, but it can be retrieved by alternative providers from locations such as device.conf.

The transport module implements support for:
    * ssh/scp (via net/ssh)
    * REST
    * WinRM

This module is based on [vmware-vmware_lib](https://github.com/vmware/vmware-vmware_lib.git)

## Usage

WinRM Exec provider:
```puppet
transport { 'winrm':
  server   => '192.168.1.1',
  username => 'administrator',
  password => 'password',
}

exec { 'Set-ExecutionPolicy Unrestricted':
  unless    => '$result = (Get-ExecutionPolicy); $result -eq "Unrestricted"',
  logoutput => on_failure,
  provider  => 'winrm_ps',
  transport => Transport['winrm'],
}
```
