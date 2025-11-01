# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FileUploadMonitor::FileDetector do
  let(:watch_directory) { 'tmp/uploads' }
  let(:detector) { described_class.new(watch_directory) }
  let(:test_file) { File.join(watch_directory, 'test_upload.txt') }

  describe '#scan_for_new_files' do
    before do
      allow(Dir).to receive(:glob).with("#{watch_directory}/*").and_return([test_file])

      redis_double = instance_double(Redis)
      allow(Redis).to receive(:new).and_return(redis_double)
      allow(redis_double).to receive(:sismember).with('processed_files', test_file).and_return(false)
      allow(redis_double).to receive(:sadd).with('processed_files', test_file)
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

    it 'does not queue jobs for previously processed files' do
      expect {
        detector.scan_for_new_files
      }.to change(FileUploadMonitor::FileUploadWorker.jobs, :size).by(1)

      redis_double = instance_double(Redis)
      allow(Redis).to receive(:new).and_return(redis_double)
      allow(redis_double).to receive(:sismember).with('processed_files', test_file).and_return(true)

      new_detector = described_class.new(watch_directory)

      expect {
        new_detector.scan_for_new_files
      }.not_to change(FileUploadMonitor::FileUploadWorker.jobs, :size)
    end

    it 'stores processed file paths in Redis' do
      redis_client = instance_double(Redis)
      allow(Redis).to receive(:new).and_return(redis_client)

      expect(redis_client).to receive(:sadd).with('processed_files', test_file)
      expect(redis_client).to receive(:sismember).with('processed_files', test_file).and_return(false)

      detector.scan_for_new_files
    end
  end
end
