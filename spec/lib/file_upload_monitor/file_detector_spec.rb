# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FileUploadMonitor::FileDetector do
  let(:watch_directory) { 'tmp/uploads' }
  let(:detector) { described_class.new(watch_directory) }
  let(:test_file) { File.join(watch_directory, 'test_upload.txt') }

  describe '#scan_for_new_files' do
    before do
      allow(Dir).to receive(:glob).with("#{watch_directory}/*").and_return([test_file])
    end

    it 'detects new files in watch directory' do
      files = detector.scan_for_new_files

      expect(files).to include(test_file)
    end

    it 'queues FileUploadWorker jobs for each file' do
      expect {
        detector.scan_for_new_files
    }.to change(FileUploadMonitor::FileUploadWorker.jobs, :size).by(1)

    expect(FileUploadMonitor::FileUploadWorker.jobs.last['args']).to eq([test_file])
    end
  end
end
