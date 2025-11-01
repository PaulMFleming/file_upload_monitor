# frozen_string_literal: true

module FileUploadMonitor
  class FileDetector
    def initialize(watch_directory)
      @watch_directory = watch_directory
    end

    def scan_for_new_files
      files = Dir.glob("#{@watch_directory}/*")

      files.each do |file_path|
        FileUploadMonitor::FileUploadWorker.perform_async(file_path)
     end

     files
    end
  end
end