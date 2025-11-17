# frozen_string_literal: true

module FileUploadMonitor
  class FileUploadWorker
    include Sidekiq::Worker

    sidekiq_options retry: 5

    def perform(file_path)
      logger = Logger.new($stdout)

      unless File.exist?(file_path)
        logger.error("File not found: #{file_path}")
        raise FileNotFoundError, "File not found: #{file_path}"
      end

      logger.info("Processing file: #{file_path}")
    end
  end
end
