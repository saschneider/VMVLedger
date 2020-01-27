#
# Production environment file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and your application in memory, allowing both threaded web servers and those relying on copy on write to
  # perform better. Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"] or in config/master.key. This key is used to decrypt credentials (and other
  # encrypted files).
  config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor  = :uglifier
  config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on S3 (see config/storage.yml for options).
  config.active_storage.service = :aws

  # Force all access to the app over SSL (except for the health check and CERTBOT), use Strict-Transport-Security and secure cookies.
  config.force_ssl   = true
  config.ssl_options = {
    redirect: {
      exclude: -> request { (request.path =~ /healthcheck/) || (request.path =~ /\.well-known/) }
    }
  }

  # Use the lowest log level to ensure availability of diagnostic information when problems arise.
  config.log_level = :warn

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use memcached if available.
  if Rails.application.credentials.dig(Rails.env.to_sym, :cache, :servers).nil?
    # Use a file store so that the cache is shared across processes (e.g. delayed_job).
    config.cache_store = :file_store, "#{Rails.root}/tmp/cache/"
  else
    config.cache_store = :dalli_store, Rails.application.credentials.dig(Rails.env.to_sym, :cache, :servers),
      { value_max_bytes: 104857600, compress: true, pool_size: 5 } # Modify memcached parameter group max_item_size.
  end

  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter     = :delayed_job
  config.active_job.queue_name_prefix = 'vmv'

  # Set up the mail host.
  mail_protocol                            = Rails.application.credentials.dig(Rails.env.to_sym, :mail, :protocol)
  mail_host                                = Rails.application.credentials.dig(Rails.env.to_sym, :mail, :host)
  config.action_mailer.default_url_options = { protocol: mail_protocol, host: mail_host }
  config.action_mailer.asset_host          = "#{mail_protocol}://#{mail_host}"
  config.action_mailer.delivery_method     = :smtp
  config.action_mailer.smtp_settings       = {
    address:              Rails.application.credentials.dig(Rails.env.to_sym, :mail, :address),
    port:                 Rails.application.credentials.dig(Rails.env.to_sym, :mail, :port),
    domain:               Rails.application.credentials.dig(Rails.env.to_sym, :mail, :domain),
    user_name:            Rails.application.credentials.dig(Rails.env.to_sym, :mail, :username),
    password:             Rails.application.credentials.dig(Rails.env.to_sym, :mail, :password),
    authentication:       :plain,
    enable_starttls_auto: true
  }
  config.action_mailer.perform_caching     = false

  # Ignore bad email addresses and do not raise email delivery errors.
  config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
