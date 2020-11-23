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
        next unless Chronic.parse(cell) # Filter out what is not date

        log("FOUND DATE: #{cell}")

        begin
          case row.join
          when /n26/i
            formatted_date = DateTime.strptime(cell, '%Y-%m-%d')
          when /ing direct/i
            formatted_date = DateTime.strptime(cell, '%m/%d/%Y')
          when /hellobank/i
            formatted_date = DateTime.strptime(cell, '%d/%m/%Y')
          else
            raise "Date Format Unknown [#{row[row.size - 1]}]"
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
