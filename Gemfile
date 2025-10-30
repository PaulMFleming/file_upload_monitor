source 'https://rubygems.org'

ruby '3.3.0'

# Core application
gem 'sequel'
gem 'pg'
gem 'sidekiq'
gem 'redis'
gem 'aws-sdk-s3'

# Config
gem 'dotenv'

# Development and testing
group :development, :test do
  gem 'rspec'
  gem 'fabrication'
  gem 'database-cleaner-sequel'
  gem 'rubocop'
  gem 'pry'
  gem 'pry-byebug'
end

group :development do
  gem 'rake'
end