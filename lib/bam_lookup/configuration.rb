# frozen_string_literal: true

require 'securerandom'

module BamLookup
  class Configuration
    attr_accessor :verbose, :logger, :options, :file_directory

    def initialize
      self.verbose = false
      self.logger = Logger.new
      self.options = {}
      self.file_directory = './fixtures'
    end
  end
end
