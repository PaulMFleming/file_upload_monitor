# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tempfile'

RSpec.describe 'File Processing Pipeline', type: :integration do
  let(:temp_dir) { Dir.mktmpdir }
  let(:test_file_path) { File.join(temp_dir, 'test_upload.txt') }

  before do
    File.write(test_file_path, 'test file content')
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  it 'detects files and processes them end-to-end' do
    detector = FileUploadMonitor::FileDetector.new(temp_dir)

    expect {
      detector.scan_for_new_files
    }.to change(FileUploadMonitor::FileUploadWorker.jobs, :size).by(1)

    expect_any_instance_of(Logger).to receive(:info).with("Processing file: #{test_file_path}")

    FileUploadMonitor::FileUploadWorker.drain
  end
end
