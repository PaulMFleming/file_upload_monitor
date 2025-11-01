# frozen_string_literal: true

require 'logger'
require 'sidekiq'

module FileUploadMonitor

end

# Load the worker
require_relative 'file_upload_monitor/file_upload_worker'