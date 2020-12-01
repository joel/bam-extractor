# frozen_string_literal: true

require 'action_view'

module BamLookup
  module Views
    class Summary
      include ActionView::Helpers::NumberHelper

      def headers
        %w[ Average Sum ]
      end

      def initialize(rows)
        @rows = rows
      end

      def call
        mapped_rows = nil

        begin
          sum = rows.map do |row|
            row[:amount]
          end.reduce(:+)
          average = sum / rows.size

          mapped_rows = [
            [
              number_to_currency(average.round(2), unit: '€', separator: '.', delimiter: ','),
              number_to_currency(sum.round(2), unit: '€', separator: '.', delimiter: ',')
            ]
          ]
        rescue StandardError => e
          puts("ERROR: [#{e.message}]")
        end

        [ mapped_rows, headers ]
      end

      private

      attr_reader :rows

    end
  end
end
