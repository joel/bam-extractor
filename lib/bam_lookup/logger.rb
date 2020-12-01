# frozen_string_literal: true

module BamLookup
  class Logger
    def info(msg)
      return unless BamLookup.configuration.verbose

      puts(msg)
    end
  end
end
