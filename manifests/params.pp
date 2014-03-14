# Copyright (C) 2013 VMware, Inc.
class transport::params {

  if $::puppetversion =~ /Puppet Enterprise/ {
    $provider  = 'pe_gem'
    $ruby_path = '/opt/puppet/bin/ruby'
  } else {
    $provider  = 'gem'
    $ruby_path = '/usr/bin/env ruby'
  }

}
