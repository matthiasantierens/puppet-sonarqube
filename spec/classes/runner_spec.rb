require 'spec_helper'

describe 'sonarqube::runner' do
  context 'when installing' do
    it { is_expected.to create_class('sonarqube::runner::install') }
    it { is_expected.to create_class('sonarqube::runner::config') }
  end
end
