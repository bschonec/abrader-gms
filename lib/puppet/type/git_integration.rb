require 'puppet/parameter/boolean'
require 'puppet_x/gms/type'

module Puppet
  Puppet::Type.newtype(:git_integration) do
    include PuppetX::GMS::Type

    ensurable do
      defaultvalues
      defaultto :present
    end

    newparam(:name, :namevar => true) do
      desc 'A unique title for the key that will be provided to the prefered Git management system. Required.'
    end

    newparam(:webhook) do
      desc 'The Hangouts Chat webhook. For example, https://chat.googleapis.com/v1/spaces...  Required. NOTE: GitLab only.'
      validate do |value|
        unless value =~ /^(https?:\/\/)?(\S*\:\S*\@)?(\S*)\.?(\S*)\.?(\w*):?(\d*)\/?(\S*)$/
          raise(Puppet::Error, "Google Hangouts/Chat webhook URL must be fully qualified, not '#{value}'")
        end
      end
    end

    add_parameter_token
    add_parameter_token_file
    add_parameter_username
    add_parameter_password

    newparam(:project_id) do
      desc 'The project ID associated with the project.'
      munge do |value|
        Integer(value)
      end
    end

    newparam(:project_name) do
      desc 'The project name associated with the project. Required.'
      munge do |value|
        String(value)
      end
    end

    newproperty(:wiki_page_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for wiki page events.'
      defaultto :false
    end

    newparam(:server_url) do
      desc 'The URL path to the Git management system server. Required.'
      validate do |value|
        #unless value =~ /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
        unless value =~ /^(https?:\/\/).*:?.*\/?$/
          raise(Puppet::Error, "Git server URL must be fully qualified, not '#{value}'")
        end
      end
    end

    newparam(:gitlab_api_version) do
      desc 'The api version to use with gitlab.'
      defaultto :v4
      newvalues(:v3, :v4)
    end

    validate do
      validate_token_or_token_file
    end
  end
end
