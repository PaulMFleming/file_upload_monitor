# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FileUploadMonitor::FileUploadWorker do
  let(:valid_file_path) { '/tmp/test_file.txt' }
  let(:invalid_file_path) { '/nonexistent/file.txt' }

  describe '#perform' do
    let(:worker) { described_class.new }

    context 'with valid file path' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(valid_file_path).and_return(true)
      end

      it 'logs processing message at info level' do
        expect_any_instance_of(Logger).to receive(:info).with("Processing file: #{valid_file_path}")

        worker.perform(valid_file_path)
      end
    end

    context 'with invalid file path' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(invalid_file_path).and_return(false)
      end

      it 'logs error message' do
        expect_any_instance_of(Logger).to receive(:error).with("File not found: #{invalid_file_path}")

        worker.perform(invalid_file_path)
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

  describe 'job processing' do
    it 'processed queued jobs when drained' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(valid_file_path).and_return(true)
      expect_any_instance_of(Logger).to receive(:info).with("Processing file: #{valid_file_path}")

      described_class.perform_async(valid_file_path)
      described_class.drain
    end
  end

  describe 'job retry behaviour' do
    describe 'file not found retries' do
      it 'retries up to 5 times when file does not exist' do
        non_existent_file = '/tmp/does_not_exist.txt'

        expect(FileUploadMonitor::FileUploadWorker).to receive(:sidekiq_options).with(retry: 5)

        worker = FileUploadMonitor::FileUploadWorker.new

        expect {
          worker.perform(non_existent_file)
        }.to raise_error(FileUploadMonitor::FileNotFoundError)

        expect(Sidekiq::RetrySet.new.size).to eq(1)
      end

      it 'logs error message when file not found' do
        non_existant_file = '/tmp/does_not_exist.txt'
        worker = FileUploadMonitor::FileUploadWorker.new

        expect_any_instance_of(Logger).to receive(:error).with("File not found: #{non_existant_file}")

        expect {
          worker.perform(non_existant_file)
      }.to raise_error(FileUploadMonitor::FileNotFoundError)
      end
    end
  end
end
