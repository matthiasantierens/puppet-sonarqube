require 'spec_helper_acceptance'

describe 'sonarqube' do
  let(:installroot) { '/usr/local/sonar' }
  let(:home) { '/var/local/sonar' }

  before(:all) do
    apply_manifest(%(
      java::adopt { 'jdk11':
        ensure        => 'present',
        java          => 'jdk',
        version_major => '11.0.6',
        version_minor => '10',
      }
      -> file { '/usr/bin/java':
        ensure => link,
        target => '/usr/java/jdk-11.0.6+10/bin/java',
      }
      #class { 'maven::maven': }
    ), catch_failures: true)
  end

  shared_examples :sonar_common do
    let(:pp) do
      %(class { 'sonarqube':
          version => '#{version}'
      })
    end

    it { apply_manifest(pp, catch_failures: true) }
    it { expect(file("#{installroot}/data")).to be_linked_to("#{home}/data") }
    it { expect(file("#{home}/data")).to be_directory }
    it { expect(file("#{installroot}/conf/sonar.properties").content).not_to match(%r{^ldap}) }

    describe service('sonar') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'when installing LTS version' do
    let(:version) { '7.9' }

    it_behaves_like :sonar_common

    context 'using LDAP' do
      let(:pp) do
        %($ldap = {
          url          => 'ldap://myserver.mycompany.com',
          user_base_dn => 'ou=Users,dc=mycompany,dc=com',
          local_users  => ['foo', 'bar'],
        }

        class { 'sonarqube' :
          version => '#{version}',
          ldap    => $ldap,
        })
      end

      it { apply_manifest(pp, catch_failures: true) }
      # XXX: plugin installation no longer working on recent versions
      # it { expect(file("#{home}/extensions/plugins/sonar-ldap-plugin-1.4.jar")).to be_file }
      it { expect(file("#{installroot}/conf/sonar.properties").content).to match(%r{^ldap.url=ldap://myserver.mycompany.com}) }
      it { expect(file("#{installroot}/conf/sonar.properties").content).to match(%r{^sonar.security.localUsers=foo,bar}) }
    end
  end
end
