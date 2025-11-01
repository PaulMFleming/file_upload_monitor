# frozen_string_literal: true

require 'dotenv/load'
require 'rspec'
require 'pry'
require 'logger'
require 'sidekiq/testing'
require 'redis'

# Load our application
require_relative '../lib/file_upload_monitor'

# Configure Sidekiq for testing
Sidekiq::Testing.fake!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
