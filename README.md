# Transport Library for Puppet Modules

[![Build Status](https://travis-ci.org/nanliu/puppet-transport.png?branch=master)](https://travis-ci.org/nanliu/puppet-transport)

Transport allows puppet to communicate with remote Systems/APIs and manage them as resources. By default the connectivity credentials is stored in the transport resource and the connection used is specified via the transport metaparameter. Alternatives providers can be implemented to provider the connectivity credentials such as device.conf.

The transport module implements support for:

* ssh/scp (via net/ssh)
* REST
* WinRM

This module is based on [vmware-vmware_lib](https://github.com/vmware/vmware-vmware_lib.git)

## Usage

## Examples

Exec resource WinRM provider:
```puppet
transport { 'winrm':
  server   => '192.168.1.1',
  username => 'administrator',
  password => 'password',
}

exec { 'Set-ExecutionPolicy Unrestricted':
  unless    => '$result = (Get-ExecutionPolicy); $result -eq "Unrestricted"',
  logoutput => on_failure,
  provider  => 'winrm',
  transport => Transport['winrm'],
}
```
## Puppet Developers

Use transport module builtin connectivity:
```ruby
transport_type = :ssh

require 'pathname' # workaround not necessary in newer versions of Puppet
mod = Puppet::Module.find('transport', Puppet[:environment].to_s)
require File.join mod.path, 'lib/puppet_x/puppetlabs/transport'
require File.join mod.path, "lib/puppet_x/puppetlabs/transport/#{transport_type}"

Puppet::Type.type(:custom_type).provide(transport_type) do
  include PuppetX::Puppetlabs::Transport

  # transport method will establish connection
end
```

Create custom transport ... (for now see VMware vCenter & vShield (vCNS) modules).

## Known issues

Error message:
```
Could not evaluate: Bad HTTP response returned from server (401)
```

Update WinRM configuration to match authentication methods (see [WinRM documentation](https://github.com/WinRb/WinRM)):
```powershell
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```

Error message:
* PSRemoting Transport Exception
* OutOfMemory Exception
* Could not reserve enough space for object heap

The WinRM provider process is limited to 150 MB by default. Some useful configuration settings:

```powershell
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=1024}'
winrm set winrm/config/winrs '@{MaxShellsPerUser=30}'
winrm set winrm/config/winrs '@{MaxProcessesPerShell=15}'
```

If the MaxMemoryPerShellMB configuration appears to be ignored, please see [KB2842230](http://support.microsoft.com/kb/2842230). The hotfix for Windows 8/Windows 2012 x64 is available at the following [link](http://hotfixv4.microsoft.com/Windows%208%20RTM/nosp/Fix452763/9200/free/463941_intl_x64_zip.exe).
