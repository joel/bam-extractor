# frozen_string_literal: true

require 'chronic'

module ExtractValue
  module Extractors
    class LabelExtractor

      def initialize(row, expressions)
        @row = row
        @expressions = expressions
      end

      # Find the label
      def call
        label = nil

        row.each do |cell|
          next unless cell =~ expressions

          label = cell

          log("LABEL FOUND LABEL: [#{cell}]")

          break
        end

        label
      end

      private

      attr_reader :row, :expressions

      def log(msg)
        ExtractValue.configuration.logger.info(msg)
      end

    end
  end
end
