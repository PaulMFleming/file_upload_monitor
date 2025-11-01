# frozen_string_literal: true

module FileUploadMonitor
  class FileUploadWorker
    include Sidekiq::Worker

    def perform(file_path)
      logger = Logger.new($stdout)

      if File.exist?(file_path)
        logger.info("Processing file: #{file_path}")
      else
        logger.error("File not found: #{file_path}")
      end
    end
  end
end
