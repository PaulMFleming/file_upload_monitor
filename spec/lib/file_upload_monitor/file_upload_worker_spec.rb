# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FileUploadMonitor::FileUploadWorker do
  let(:valid_file_path) { '/tmp/test_file.txt' }
  let(:invalid_file_path) { '/nonexistent/file.txt' }

  describe '.perform' do
    context 'with valid file path' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(valid_file_path).and_return(true)
      end

      it 'logs processing message at info level' do
        expect_any_instance_of(Logger).to receive(:info).with("Processing file: #{valid_file_path}")

        described_class.perform(valid_file_path)
      end
    end

    context 'with invalid file path' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(invalid_file_path).and_return(false)
      end

      it 'logs error message' do
        expect_any_instance_of(Logger).to receive(:error).with("File not found: #{invalid_file_path}")

        described_class.perform(invalid_file_path)
      end
    end
  end

  describe '.perform_async' do
    it 'enqueus a job in Sidekiq' do
      expect {
        described_class.perform_async(valid_file_path)
    }.to change(described_class.jobs, :size).by(1)
    end

    it 'enqueues with correct arguements' do
      described_class.perform_async(valid_file_path)

      expect(described_class.jobs.last['args']).to eq([valid_file_path])
    end
  end
end