#!/usr/bin/env rspec
# Copyright (C) 2013 VMware, Inc.

require 'spec_helper'

module PuppetX::Puppetlabs::Transport
  class Dummy
    include Util

    attr_reader :name, :user, :password, :host

    def initialize(option)
      @name     = option[:name]
      @user     = option[:username]
      @password = option[:password]
      @host     = option[:server]
    end

    def connect
    end

    def close
    end
  end
end

describe PuppetX::Puppetlabs::Transport do

  before(:all) do
    @catalog = Puppet::Resource::Catalog.new
    ('a'..'c').to_a.each do |x|
      @catalog.add_resource(Puppet::Type.type(:transport).new({
        :name => "conn_#{x}",
        :username => "user_#{x}",
        :password => "pass_#{x}",
        :server   => "server_#{x}",
      }))
    end
  end

  it 'initializes connection via catalog' do
    @dummy = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => "Transport[conn_a]", :catalog => @catalog, :provider => 'dummy')
    @dummy.class.should == PuppetX::Puppetlabs::Transport::Dummy
    @dummy.name.should == 'conn_a'
    @dummy.user.should == 'user_a'
    @dummy.password.should == 'pass_a'
    @dummy.host.should == 'server_a'
  end

  it 'raise error when transport is invalid' do
    expect{
      PuppetX::Puppetlabs::Transport.retrieve(
        :resource_ref => "Transport[bad]",
        :catalog => @catalog,
        :provider => 'dummy'
      )
    }.to raise_error(ArgumentError)
  end

  it 'reuse existing transport' do
    dummy1 = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => "Transport[conn_a]", :catalog => @catalog, :provider => 'dummy')
    dummy2 = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => "Transport[conn_a]", :catalog => @catalog, :provider => 'dummy')
    dummy1.should == dummy2
  end

  it 'find existing transport' do
    dummy1 = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => "Transport[conn_a]", :catalog => @catalog, :provider => 'dummy')
    PuppetX::Puppetlabs::Transport.find('conn_a', 'dummy').should == dummy1
  end

  it 'closes connections on cleanup' do
    dummy1 = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => "Transport[conn_a]", :catalog => @catalog, :provider => 'dummy')
    dummy2 = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => "Transport[conn_b]", :catalog => @catalog, :provider => 'dummy')
    dummy1.expects(:close)
    dummy2.expects(:close)
    PuppetX::Puppetlabs::Transport.cleanup
  end

  it 'cleanup connections after catalog apply' do
    PuppetX::Puppetlabs::Transport.expects(:cleanup)

    # catalog.apply writes result files, so testing with transaction directly.
    @transaction = nil
    begin
      @transaction = Puppet::Transaction.new(@catalog)
    rescue
      @transaction = Puppet::Transaction.new(@catalog, nil, nil)
    end
    @transaction.evaluate
  end

  it 'filters secrets' do
    @transport = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => "Transport[conn_a]", :catalog => @catalog, :provider => 'dummy')
    @transport.add_secret(['xyzcorp', 'b'])
    @transport.add_secret('abc')
    @transport.add_secret('xyz')

    message = @transport.filter_secrets('a secret message from xyzcorp to xyz')
    message.should == 'a secret message from ******* to ***'
  end
end
