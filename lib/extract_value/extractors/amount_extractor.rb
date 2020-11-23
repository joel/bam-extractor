# frozen_string_literal: true

module ExtractValue
  module Extractors
    class AmountExtractor

      def initialize(row)
        @row = row
      end

      # Find the amount (We want to exclude the account balance!)
      def call
        amount = nil

        row.each do |cell|
          next unless cell =~ /\./
          next unless cell.gsub('.', '') =~ /[0-9]/

          amount ||= Monetize.parse(cell)
          next unless amount

          log("AMOUNT FOUND : #{cell}")

          # If the amount is greater to the max defined it might be the balance account
          if amount.fractional == 0 || amount.fractional < options.min * 100 || options.max * 100 < amount.fractional
            log("FILTERED OUT: #{amount.fractional.to_f / 100}")
            amount = nil
            next
          else
            amount = amount.fractional.to_f / 100
            break
          end
        end

        amount
      end

      private

      attr_reader :row

      def log(msg)
        ExtractValue.configuration.logger.info(msg)
      end

      def options
        ExtractValue.configuration.options
      end

    end
  end
end
