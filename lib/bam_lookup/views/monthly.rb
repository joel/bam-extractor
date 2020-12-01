# frozen_string_literal: true

require 'action_view'

module BamLookup
  module Views
    class Monthly
      include ActionView::Helpers::NumberHelper

      def headers
        %w[Year Month Average Sum]
      end

      def initialize(rows)
        @rows = rows
      end

      def call
        sum_per_month = Hash.new { |hash, key| hash[key] = { sum: 0, average: 0, year: nil, month: nil, entries: 0 } }
        current_date = nil

        begin
          rows.each do |row|
            current_date ||= row[:date].strftime('%Y-%B')

            if current_date != row[:date].strftime('%Y-%B')
              sum_per_month[current_date][:average] = sum_per_month[current_date][:sum] / sum_per_month[current_date][:entries]
              current_date = row[:date].strftime('%Y-%B')
            end

            sum_per_month[current_date][:sum]     += row[:amount]
            sum_per_month[current_date][:entries] += 1
            sum_per_month[current_date][:year]     = row[:date].strftime('%Y')
            sum_per_month[current_date][:month]    = row[:date].strftime('%B')
          end

          mapped_rows = sum_per_month.values.map do |v|
            [
              v[:year],
              v[:month],
              number_to_currency(v[:average].round(2), unit: '€', separator: '.', delimiter: ','),
              number_to_currency(v[:sum].round(2), unit: '€', separator: '.', delimiter: ',')
            ]
          end

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
