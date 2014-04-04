require 'winrm' unless Puppet.run_mode.master?

module PuppetX::Puppetlabs::Transport
  class Winrm
    attr_accessor :winrm
    attr_reader :name

    def initialize(opts)
      @name = opts[:name]
      options = opts[:options] || {}
      @options = options.inject({}){|h, (k, v)| h[k.to_sym] = v; h}

      port = @options.fetch(:port, 5985)
      @connection = @options.fetch(:connection, :plaintext)
      @timeout    = @options.fetch(:timeout, 60)
      case @connection
      when :plaintext
        @endpoint = "http://#{opts[:server]}:#{port}/wsman"
        @options[:user] = opts[:username]
        @options[:pass] = opts[:password]
        @options[:disable_sspi] ||= true unless @options[:basic_auth_only]
      when :ssl
        @endpoint = "https://#{opts[:server]}:#{port}/wsman"
        @options[:user] = opts[:username]
        @options[:pass] = opts[:password]
        @options[:disable_sspi] ||= true unless @options[:basic_auth_only]
      when :kerberos
        @endpoint = "https://#{opts[:server]}:#{port}/wsman"
      end
      Puppet.debug("#{self.class} initializing connection to: #{@options[:host]}")
    end

    def connect
      @winrm ||= WinRM::WinRMWebService.new(
        @endpoint,
        @connection,
        @options
      )
      @winrm.set_timeout(@timeout)
    end

    def powershell(cmd)
      Puppet.debug("Executing on #{@host}:\n#{cmd}")
      @winrm.powershell(cmd)
    end
  end
end
