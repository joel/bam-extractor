# frozen_string_literal: true

module ExtractValue
  class Logger
    def info(msg)
      return unless ExtractValue.configuration.verbose

      puts(msg)
    end
  end
end
