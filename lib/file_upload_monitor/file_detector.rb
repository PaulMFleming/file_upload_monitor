# frozen_string_literal: true

module FileUploadMonitor
  class FileDetector
    def initialize(watch_directory)
      @watch_directory = watch_directory
      @redis = Redis.new
    end

    def scan_for_new_files
      files = Dir.glob("#{@watch_directory}/*")
      new_files = []

      files.each do |file_path|
        next if @redis.sismember('processed_files', file_path)

        FileUploadMonitor::FileUploadWorker.perform_async(file_path)
        @redis.sadd('processed_files', file_path)
        new_files << file_path
      end

      files
    end
  end
end
