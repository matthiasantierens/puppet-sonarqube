require 'spec_helper'

describe 'sonarqube::runner::install' do
  let :params do
    {
      package_name: 'sonar-runner',
      version: '2.4',
      download_url: 'http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist',
      installroot: '/usr/local',
    }
  end

  context 'contain wget' do
    it { is_expected.to contain_class('wget') }
  end

  context 'when installing version 2.4' do
    it { is_expected.to contain_wget__fetch('download-sonar-runner').with_source('http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/2.4/sonar-runner-dist-2.4.zip') }
  end

  context 'check directory link' do
    it { is_expected.to contain_file('/usr/local/sonar-runner') }
  end
end
