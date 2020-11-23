# frozen_string_literal: true

require 'chronic'

module ExtractValue
  class DateExtractor

    def initialize(row)
      @row = row
    end

    # Find Date in the row
    def call()
      formatted_date = nil

      row.each do |cell|
        next unless Chronic.parse(cell) # Filter Out DATE

        log("DATE FOUND: [#{cell}]")

        begin
          case row.join
          when /n26/i
            formatted_date = DateTime.strptime(cell, '%Y-%m-%d')
          when /ing direct/i
            formatted_date = DateTime.strptime(cell, '%m/%d/%Y')
          when /hellobank/i
            formatted_date = DateTime.strptime(cell, '%d/%m/%Y')
          else
            raise "Impossible to match a date format for [#{row}], please enter one"
          end
        rescue Date::Error => e
          log("ERROR: [#{cell}] => #{e.message} SOURCE: #{row.join}")
        end

        break if formatted_date # Stop iteration, date is found
      end

      formatted_date
    end

    private

    attr_reader :row

    def log(msg)
      ExtractValue.configuration.logger.info(msg)
    end
  end
end
