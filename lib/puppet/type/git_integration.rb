require 'puppet/parameter/boolean'
require 'puppet_x/gms/type'

module Puppet
  Puppet::Type.newtype(:git_integration) do
    include PuppetX::GMS::Type

    @doc = "Create a Google Chat hook in Gitlab."

    ensurable do
      defaultvalues
      defaultto :present
    end

    newparam(:name, :namevar => true) do
      desc 'A unique title for the key that will be provided to the prefered Git management system. Required.'
      newvalues(:apple_app_store, :asana, :assembla, :bamboo, :bugzilla, :buildkite, :campfire, :datadog, :'unify-circuit', :pumble, :'webex-teams', :'custom-issue-tracker', :discord, :'drone-ci', :'emails-on-push', :ewm, :confluence, :shimo, :'external-wiki', :github, :'hangouts-chat', :irker, :jira, :'slack-slash-commands', :'mattermost-slash-commands', :packagist, :'pipelines-email', :pivotaltracker, :prometheus, :pushover, :redmine, :slack, :'microsoft-teams', :mattermost, :teamcity, :jenkins, :'jenkins-deprecated', :'mock-ci', :'squash-tm', :youtrack)
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

    newproperty(:notify_only_broken_pipelines, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Send notifications for broken pipelines.'
      defaultto (false)
    end

    property(:notify_only_default_branch, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'DEPRECATED: This parameter has been replaced with branches_to_be_notified.'
      defaultto (false)
    end

    newproperty(:branches_to_be_notified) do
      desc 'Branches to send notifications for. Valid options are all, default, protected, and default_and_protected. The default value is “default”.'
      newvalues(:all, :default, :protected, :default_and_protected)
      defaultto :default
    end

    property(:push_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for push events.'
      defaultto (false)
    end

    newproperty(:issues_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for issue events.'
      defaultto (false)
    end

    newproperty(:confidential_issues_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for confidential issue events.'
      defaultto (false)
    end

    newproperty(:merge_requests_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for merge request events.'
      defaultto (false)
    end

    property(:tag_push_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for tag push events.'
      defaultto (false)
    end

    property(:note_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for note events.'
      defaultto false
    end

    property(:confidential_note_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for confidential note events.'
      defaultto false
    end

    property(:pipeline_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for pipeline events.'
      defaultto false
    end

    property(:wiki_page_events, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Enable notifications for wiki page events.'
      defaultto false
    end

    property(:disable_ssl_verify, :boolean => true, :parent => Puppet::Parameter::Boolean) do
      desc 'Boolean value for disabling SSL verification for this webhook. Optional. NOTE: GitHub only'
      defaultto false
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
