# frozen_string_literal: true

require 'logger'
require 'sidekiq'

module FileUploadMonitor
end

# Load components
require_relative 'file_upload_monitor/file_upload_worker'
require_relative 'file_upload_monitor/file_detector'
