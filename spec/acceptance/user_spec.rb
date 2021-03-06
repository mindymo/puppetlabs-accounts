require 'spec_helper_acceptance'

describe 'accounts::user define', :unless => UNSUPPORTED_PLATFORMS.include?(fact("osfamily")) do
  describe 'main tests' do
    describe user('hunner') do
      it 'creates groups of matching names, assigns non-matching group, manages homedir, manages other properties, gives key, makes dotfiles' do
        pp = <<-EOS
          accounts::user { 'hunner':
            groups   => ['root'],
            password => 'hi',
            shell    => '/bin/true',
            home     => '/tmp/hunner',
            sshkeys  => [
              'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant',
            ],
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end
      it { should exist }
      it { should belong_to_group 'hunner' }
      it { should belong_to_group 'root' }
      it { should have_login_shell '/bin/true' }
      it { should have_home_directory '/tmp/hunner' }
      it { should have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant' }
    end
    describe file('/tmp/hunner') do
      it { should be_directory }
      it { should be_mode 700 }
      it { should be_owned_by 'hunner' }
      it { should be_grouped_into 'hunner' }
    end
    describe file('/tmp/hunner/.bashrc') do
      its(:content) { should match(/managed by Puppet/) }
    end
    describe file('/tmp/hunner/.bash_profile') do
      its(:content) { should match(/Get the aliases and functions/) }
    end
    describe file('/tmp/hunner/.vim') do
      it { should be_directory }
    end
  end
  describe 'locking users' do
    describe user('hunner') do
      it 'locks a user' do
        pp = <<-EOS
          accounts::user { 'hunner':
            locked => true,
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end
      it { 
        case fact('osfamily')
        when 'Debian'
          should have_login_shell '/usr/sbin/nologin'
        when 'Solaris'
          should have_login_shell '/usr/bin/false'
        else
          should have_login_shell '/sbin/nologin'
        end
      }
    end
  end
end
