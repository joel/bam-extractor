# frozen_string_literal: true

require 'securerandom'

module ExtractValue
  class Configuration
    attr_accessor :verbose, :logger

    def initialize
      self.verbose = false
      self.logger = Logger.new
    end
  end
end
