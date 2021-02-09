require "bundler/setup"
require "bam_lookup"

begin
  require 'pry'
rescue LoadError
end

BamLookup.configure do |conf|
  conf.file_directory = '../fixtures'
end

RSpec.configure do |config|
  # config.around(:each) do |example|
  #   puts "around each before"
  #   example.run
  #   puts "around each after"
  # end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
  end
end
