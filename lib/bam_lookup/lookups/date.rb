# frozen_string_literal: true

require 'chronic'

module BamLookup
  module Lookups
    class Date

      class Error < StandardError; end

      def initialize(row)
        @row = row
      end

      # Find Date in the row
      def call
        formatted_date = nil

        row.each do |cell|
          next unless Chronic.parse(cell) # Filter Out DATE

          log("DATE FOUND: [#{cell}]")

          begin
            case row.join
            when /n26/i
              formatted_date = DateTime.strptime(cell, '%Y-%m-%d')
            when /.*(ing).*(direct).*/i
              formatted_date = DateTime.strptime(cell, '%m/%d/%Y')
            when /joint\sbank\saccount/i
              formatted_date = DateTime.strptime(cell, '%m/%d/%Y')
            when /personal\sbank\saccount/i
              formatted_date = DateTime.strptime(cell, '%m/%d/%Y')
            when /hellobank/i
              formatted_date = DateTime.strptime(cell, '%d/%m/%Y')
            else
              return Chronic.parse(cell) if options.date_fallback

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
        BamLookup.configuration.logger.info(msg)
      end

      def options
        BamLookup.configuration.options
      end
    end
  end
end
