# file_upload_monitor

A file upload monitor built in Ruby

## Learning Goals/Patterns Used

- **Sidekiq Workers**: Background job processing patterns
- **Redis Operations**: Job queues and duplicate detection with Sets
- **File Monitoring**: Directory scanning and change detection
- **TDD with Async Code**: Testing background jobs and Redis interactions

## Learning Goals Progress

- [x] Understand Sidekiq worker lifecycle
- [x] Practice Redis queue operations
- [x] Implement duplicate detection with Redis Sets
- [ ] Add job retry logic
- [ ] Job scheduling patterns
- [ ] Monitor job status
- [ ] Handle job failures gracefully

## Architecture

```
File System → FileDetector → Sidekiq Queue → FileUploadWorker
                ↓
            Redis Sets (duplicate tracking)
```

## Getting Started

### Prerequisites

```bash
# Install dependencies
bundle install

# Start Redis (required for Sidekiq)
brew services start valkey  # or redis-server
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific component tests
bundle exec rspec spec/lib/file_upload_monitor/file_upload_worker_spec.rb
bundle exec rspec spec/lib/file_upload_monitor/file_detector_spec.rb
```

### Basic Usage

```ruby
# Detect files and queue background jobs
detector = FileUploadMonitor::FileDetector.new('/path/to/uploads')
detector.scan_for_new_files

# Process queued jobs (in tests)
FileUploadMonitor::FileUploadWorker.drain
```
