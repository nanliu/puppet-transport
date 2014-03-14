require 'spec_helper'

describe 'transport::package' do
  describe 'for puppet opensource' do
    let(:facts) {{ :puppetversion => '3.4.3' }}
    it 'should install gem packages' do
      %w[net-ssh net-scp winrm rest-client hashdiff].each do |p|
        should contain_package(p).with_provider('gem')
      end
    end
  end

  describe 'for puppet enterprise' do
    let(:facts) {{ :puppetversion => 'Puppet Enterprise 3.0.0' }}

    it 'should install gem packages' do
      %w[net-ssh net-scp winrm rest-client hashdiff].each do |p|
        should contain_package(p).with_provider('pe_gem')
      end
    end
  end
end
