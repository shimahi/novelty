CarrierWave.configure do |config|
  if Rails.env.production?
    config.fog_credentials = {
      :provider => 'OpenStack',
      :openstack_tenant => Rails.application.credentials.conoha[:tenant_name],
      :openstack_username => Rails.application.credentials.conoha[:user_name],
      :openstack_api_key => Rails.application.credentials.conoha[:password],
      :openstack_auth_url => Rails.application.credentials.conoha[:auth_url],
    }
    config.fog_directory = 'design'
    config.storage :fog
    config.cache_storage = :fog
    config.asset_host = Rails.application.credentials.conoha[:container]
  else
    config.cache_storage = :file
  end
end

