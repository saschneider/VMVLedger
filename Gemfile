#
# Rails Gem file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Rails 5.2.
gem 'rails', '~> 5.2.2'
gem 'rails-i18n', '~> 5.1'
gem 'i18n_data', '~> 0.8'
gem 'countries', '~> 2.1'
gem 'tzinfo', '~> 1.2'

# Use Puma as the app server.
gem 'puma', '~> 3.12'

# Reduces boot times through caching; required in config/boot.rb.
gem 'bootsnap', '>= 1.1.0', require: false

# Use CoffeeScript for .coffee assets and views.
gem 'coffee-rails', '~> 4.2'

# Use Uglifier as compressor for JavaScript assets.
gem 'uglifier', '>= 4.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder.
gem 'jbuilder', '~> 2.8'

# View template languages and support.
gem 'sass-rails', '~> 5.0'
gem 'haml-rails', '~> 1.0.0'
gem 'bootstrap', '~> 4.3'
gem "bootstrap_form", '>= 4.1'
gem 'data-confirm-modal', '~> 1.6', '>= 1.6.2'

# JavaScript variables.
gem 'gon', '~> 6.2'

# Pagination and navigation.
gem 'kaminari', '~> 1.1.1'
gem 'breadcrumbs_on_rails', '~> 3.0', '>= 3.0.1'

# Use Mini Magick for ActiveStorage.
gem 'mini_magick', '~> 4.9'

# Run background jobs using delayed_job.
gem 'delayed_job_active_record', '~> 4.1', '>= 4.1.3'
gem 'daemons', '~> 1.2', '>= 1.2.3'

# Use authentication via Devise and permissions with pundit.
gem 'bcrypt', '~> 3.1'
gem 'devise', '~> 4.6.1'
gem 'pundit', '~> 2.0'

# To customise the robots.txt file per environment.
gem 'roboto', '~> 1.0'

# Be able to run command line programmes.
gem 'terrapin', '~> 0.6'

# Be able to parse XML.
gem 'nokogiri', '~> 1.10'

# Posting multi-part form data.
gem 'multipart-post', '~> 2.0'

# Connect to Ethereum/Quorum nodes.
gem 'ethereum.rb', '~> 2.2'

group :development, :test do
  # Use sqlite3 as the database for ActiveRecord.
  gem 'sqlite3', '~> 1.3'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console.
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.7'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring.
  gem 'spring', '~> 2.0'
  gem 'spring-watcher-listen', '~> 2.0'
end

group :test do
  # Mocking.
  gem 'webmock', '~> 3.5'
  gem 'mocha', '~> 1.8'

  # Assigns testing.
  gem 'rails-controller-testing', '~> 1.0'

  # Use minitest reporters for RubyMine.
  gem 'minitest-reporters', '~> 1.3'
end

group :production do
  # Use ActiveStorage variant.
  gem 'aws-sdk', '~> 3.0'

  # AWS health check for load balancing.
  gem 'aws-healthcheck', '~> 1.0'

  # AWS instances have an older version of Node.js, so we use mini racer for JavaScript support.
  gem 'mini_racer', '~> 0.2'

  # Memchached caching.
  gem 'dalli', '~> 2.7', '>= 2.7.9'
  gem 'connection_pool', '~> 2.2', '>= 2.2.2'
end

group :docker, :production do
  # PostgreSQL database.
  gem 'pg', '~> 1.1'
end
