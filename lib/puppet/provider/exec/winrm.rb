require 'puppet/provider/exec'

begin
  require 'puppet_x/puppetlabs/transport'
  require 'puppet_x/puppetlabs/transport/winrm'
rescue LoadError => e
  unless Kernel.respond_to?(:require_relative)
    module Kernel
      def require_relative(path)
        require File.join(File.dirname(caller[0]), path.to_str)
      end
    end
  end

  require_relative '../../../puppet_x/puppetlabs/transport'
  require_relative '../../../puppet_x/puppetlabs/transport/winrm'
end

Puppet::Type.type(:exec).provide(:winrm, :parent => Puppet::Provider::Exec) do
  include PuppetX::Puppetlabs::Transport

  # We need to simulate command $?.exitstatus:
  ExitStatus = Struct.new(:exitstatus)

  def run(command, check = false)
    output = transport.powershell(command)
    stdout = output[:data].collect{|line| line[:stdout]}.compact.join("\n")
    stderr = output[:data].collect{|line| line[:stderr]}.compact.join("\n")
    Puppet.debug("WinRM output:\n#{stdout+stderr}")
    # This is required to provide exitstatus for parent provider
    exitcode = ExitStatus.new(output[:exitcode])
    [stdout+stderr, exitcode]
  end

  def checkexe(command)
  end

  def validatecmd(command)
    true
  end

  private

  def native_path(path)
    path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
  end

  # not inuse, require monkey patch of winrm gem.
  def args
    '-NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass'
  end
end
