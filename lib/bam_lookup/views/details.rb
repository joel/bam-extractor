# frozen_string_literal: true

module BamLookup
  module Views
    class Details

      def headers
        [ 'Label', 'Date', 'Year', 'Month', 'Day', 'Amount', 'Source Dir', 'Source File' ]
      end

      def initialize(rows)
        @rows = rows
      end

      def call
        sort!

        [ mapped_rows, headers ]
      end

      private

      attr_reader :rows

      def sort!(field: :date)
        rows.sort! do |x, y|
          x[field] <=> y[field]
        end
        nil
      end

      def mapped_rows
        @mapped_rows ||= begin
          data = []

          rows.each do |row|
            data << [
              (row[:label]).to_s,
              row[:date].strftime('%Y/%m/%d'),
              row[:date].strftime('%Y'),
              row[:date].strftime('%B'),
              row[:date].strftime('%A'),
              (row[:amount_formatted]).to_s,
              row[:source_dir],
              row[:source_file]
            ]
          end

          data.sort! do |x, y|
            x[1] <=> y[1] # Sort by date
          end

          data
        end
      end

    end
  end
end
