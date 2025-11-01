# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.0'

# Core application
gem 'aws-sdk-s3'
gem 'pg'
gem 'redis'
gem 'sequel'
gem 'sidekiq'

# Config
gem 'dotenv'

# Development and testing
group :development, :test do
  gem 'database_cleaner-sequel'
  gem 'fabrication'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec'
  gem 'rubocop'
end

group :development do
  gem 'rake'
end
