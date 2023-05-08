require 'puppet'
require 'net/http'
require 'json'
require 'puppet_x/gms/provider'

Puppet::Type.type(:git_integration).provide(:gitlab) do
  include PuppetX::GMS::Provider

  defaultfor :gitlab => :exists

  def self.prefetch

    Puppet.debug("Hello, world!")

  end

  def self.instances

    Puppet.debug("Hello, world!")

  end

  def self.instancesd

    project_id = get_project_id

    integration_hash = Hash.new
    url = "#{gms_server}/api/#{api_version}/projects/#{project_id}/integrations/#{name}"

    response = api_call('GET', url)

    integration_json = JSON.parse(response.body)

    if integration_json['active'] == true
      Puppet.debug "XXXX gitlab_integration::#{calling_method}: Integration is already active as specified in calling resource block."
      new( :name => :name,
           :ensure => :present
         )
    end

  end

  # Return the URL to the Gitlab Server if variable, 'sever_url" is defined,
  # otherwise return https://gitlab.com.
  def gms_server
    return resource[:server_url].strip unless resource[:server_url].nil?
    return 'https://gitlab.com'
  end

  def api_version
    return resource[:gitlab_api_version]
  end

  def calling_method
    # Get calling method and clean it up for good reporting
    cm = String.new
    cm = caller[0].split(" ").last
    cm.tr!('\'', '')
    cm.tr!('\`','')
    cm
  end

  def api_call(action,url,data = nil)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)

    if uri.port == 443 or uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    else
      http.use_ssl = false
    end

    if Puppet[:debug] == true
      http.set_debug_output($stdout)
    end

    if action =~ /post/i
      req = Net::HTTP::Post.new(uri.request_uri)
    elsif action =~ /put/i
      req = Net::HTTP::Put.new(uri.request_uri)
    elsif action =~ /delete/i
      req = Net::HTTP::Delete.new(uri.request_uri)
    else
      req = Net::HTTP::Get.new(uri.request_uri)
    end

    req.set_content_type('application/json')
    req.add_field('PRIVATE-TOKEN', get_token)

    if data
      req.body = data.to_json
    end

    Puppet.debug("gitlab_integration::#{calling_method}: REST API #{req.method} Endpoint: #{uri.to_s}")
    Puppet.debug("gitlab_integration::#{calling_method}: REST API #{req.method} Request: #{req.inspect}")

    response = http.request(req)

    Puppet.debug("gitlab_integration::#{calling_method}: REST API #{req.method} Response: #{response.inspect}")

    response
  end

  def exists?

    Puppet.debug("@property_hash[:ensure] = #{@property_hash[:ensure]}.")
    # The self.instances will initialize first and if the Google Chat integration is enabled, we'll return :present 
    @property_hash[:ensure] == :present  # does :ensure equal present?

  end

  def get_project_id
    return resource[:project_id].to_i unless resource[:project_id].nil?

    if resource[:project_name].nil?
      raise(Puppet::Error, "gitlab_integration::#{calling_method}: Must provide at least one of the following attributes: project_id or project_name")
    end

    project_name = resource[:project_name].strip.gsub('/','%2F')

    url = "#{gms_server}/api/#{api_version}/projects/#{project_name}"

    begin
      response = api_call('GET', url)
      return JSON.parse(response.body)['id'].to_i
    rescue Exception => e
      fail(Puppet::Error, "gitlab_integration::#{calling_method}: #{e.message}")
      return nil
    end

  end

  def get_integration_id
    project_id = get_project_id

    integration_hash = Hash.new

    url = "#{gms_server}/api/#{api_version}/projects/#{project_id}/integrations/#{name}"

    response = api_call('GET', url)

    integration_json = JSON.parse(response.body)

    # If the Gitlab integration has never been activated then the API will return an empty set.
    # If the Gitlab integration has EVER been activated then we'll get a hash that returns the 
    # property 'active' with true or false.
    if integration_json.active?
        return integration_json['active']
    end

    return nil
  end

  def create
#    project_id = get_project_id
#    Puppet.debug("XXX: issues_events = #{resource[:issues_events]}.") 
#
#    url = "#{gms_server}/api/#{api_version}/projects/#{project_id}/integrations/#{name}"
#
#    begin
#      opts = { 'webhook' => resource[:webhook].strip }
#      opts['branches_to_be_notified'] = resource[:branches_to_be_notified]
#      opts['confidential_issues_events'] = resource[:confidential_issues_events]
#      opts['confidential_note_events'] = resource[:confidential_note_events]
#      opts['issues_events'] = resource[:issues_events]
#      opts['merge_requests_events'] = resource[:merge_requests_events]
#      opts['note_events'] = resource[:note_events]
#      opts['notify_only_broken_pipelines'] = resource[:notify_only_broken_pipelines]
#      opts['notify_only_default_branch'] = resource[:notify_only_default_branch]
#      opts['pipeline_events'] = resource[:pipeline_events]
#      opts['push_events'] = resource[:push_events]
#      opts['tag_push_events'] = resource[:tag_push_events]
#      opts['wiki_page_events'] = resource[:wiki_page_events]
#
#      response = api_call('PUT', url, opts)
#
#      if (response.class == Net::HTTPOK)
#        return true
#      else
#        raise(Puppet::Error, "gitlab_integration::#{calling_method}: #{response.inspect}")
#      end
#    rescue Exception => e
#      raise(Puppet::Error, "gitlab_integration::#{calling_method}: #{e.message}")
#    end
  end

  def destroy
    project_id = get_project_id

      url = "#{gms_server}/api/#{api_version}/projects/#{project_id}/integrations/#{name}"

      begin
        response = api_call('DELETE', url)

        if (response.class == Net::HTTPNoContent)
          return true
        else
          raise(Puppet::Error, "gitlab_integration::#{calling_method}: #{response.inspect}")
        end
      rescue Exception => e
        raise(Puppet::Error, "gitlab_integration::#{calling_method}: #{e.message}")
      end

  end

  def push_events
    return resource[:push_events]
  end

  def push_events=(value)
    opts['push_events'] = value
    Puppet.debug("XXX: push_events = #{value} #{resource[:push_events]}.") 
  end

  def disable_ssl_verify
    return resource[:disable_ssl_verify]
  end

  def disable_ssl_verify=(value)
        if resource[:disable_ssl_verify] == true
          opts['enable_ssl_verification'] = 'false'
        else
          opts['enable_ssl_verification'] = 'true'
        end
  end

  def branches_to_be_notified
    return resource[:branches_to_be_notified]
  end

  def branches_to_be_notified=(value)
    opts['branches_to_be_notified'] = value
  end

  def issues_events
    return resource[:issues_events]
  end

  def issues_events=(value)
    opts['issues_events'] = value
    Puppet.debug("XXX: issues_events = #{value} #{resource[:issues_events]}.") 
  end

end
