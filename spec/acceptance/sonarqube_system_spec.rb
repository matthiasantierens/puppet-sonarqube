require 'spec_helper_acceptance'

describe 'sonarqube' do
  let(:installroot) { '/usr/local/sonar' }
  let(:home) { '/var/local/sonar' }

  before(:all) do
    apply_manifest(%(
      java::adopt { 'jdk11' :
        ensure        => 'present',
        java          => 'jdk',
        version_major => '11.0.6',
        version_minor => '10',
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
    it { file("#{installroot}/data").should be_linked_to("#{home}/data") }
    it { file("#{home}/data").should be_directory }
    it { file("#{installroot}/conf/sonar.properties").content.should_not match(%r{^ldap}) }

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
      #it { file("#{home}/extensions/plugins/sonar-ldap-plugin-1.4.jar").should be_file }
      it { file("#{installroot}/conf/sonar.properties").content.should match(%r{^ldap.url=ldap://myserver.mycompany.com}) }
      it { file("#{installroot}/conf/sonar.properties").content.should match(%r{^sonar.security.localUsers=foo,bar}) }
    end
  end
end
