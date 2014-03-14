#!/usr/bin/env rspec

require 'spec_helper'

describe Puppet::Type.type(:exec).provider(:winrm) do
  context 'when exec command over wirm' do
    let :cmd do
      'get-process'
    end
    let :resource do
      Puppet::Type::Exec.new({
        :name => 'list process',
        :command => cmd,
        :provider => 'winrm'
      })
    end
    let(:provider) { resource.provider }

    before do
      @wirnm = mock('winrm')
      provider.class.stubs(:transport).returns(@winrm)
    end

    describe '#run' do
      it 'should process powershell results' do
        @winrm.stubs(:powershell).with(cmd).returns({
          :data => my_fixture_read('ps_process').split("\n").collect{ |line| {:stdout => line} },
          :exitcode => 0
        })

        output, status = provider.run(cmd)
        output.should == my_fixture_read('ps_process').chomp
        status.exitstatus.should == 0
      end

      it 'should propagate powershell errors' do
        @winrm.stubs(:powershell).with(cmd).returns({
          :data => [
            {:stderr => 'Get-Process : A parameter cannot be found that matches parameter name'},
            {:stderr => 'At line:1 char:13'},
          ],
          :exitcode => 1096
        })
        output, status = provider.run(cmd)
        output.should == "Get-Process : A parameter cannot be found that matches parameter name\nAt line:1 char:13"
        status.exitstatus.should == 1096
      end
    end

    describe "#checkexe" do
      it "should skip checking the exe" do
        provider.checkexe(cmd).should be_nil
      end
    end

    describe '#validatecmd' do
      it 'should always validate command' do
        provider.validatecmd('get-process').should be_true
      end
    end
  end
end
