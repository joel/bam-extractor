# frozen_string_literal: true

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

require 'csv'
require 'monetize'
require 'action_view'
require 'tty-table'

Monetize.assume_from_symbol = true
Money.default_currency = 'EUR'
Money.rounding_mode = BigDecimal::ROUND_HALF_UP

module ExtractValue
  extend Configure

  class Error < StandardError; end

  class Main
    include ActionView::Helpers::NumberHelper

    def initialize(options)
      @options = options
    end

    def expressions
      Regexp.new(options.expression.split(',').join('|'), Regexp::IGNORECASE)
    end

    def get_rows
      rows = []

      puts('Searching...') if options.verbose

      Dir['../**/*.csv'].each do |file|
        CSV.foreach(file) do |row|
          if row.join =~ expressions
            rows << row + [File.dirname(file).gsub('../', ''), File.basename(file)]
          end
        end
      end

      rows
    end

    def extract_value
      rows = get_rows

      raw_data = []

      rows.each do |row|
        label = Extractors::LabelExtractor.new(row, expressions).call
        next unless label

        date = Extractors::DateExtractor.new(row).call
        next unless date

        amount = Extractors::AmountExtractor.new(row).call
        next unless amount

        info = { date: nil, amount: nil, amount_formatted: nil, source_dir: nil, source_file: nil }

        info[:date] = date

        info[:amount] = amount
        info[:amount_formatted] = number_to_currency(info[:amount], unit: '€', separator: '.', delimiter: ',')

        info[:label] = label[0..options.trunk]

        info[:source_dir]  = row[row.size - 2]
        info[:source_file] = row[row.size - 1]

        raw_data << info
      end

      if raw_data.empty?
        puts('No Data')
        return
      end

      detail_rows, detail_headers = Outputs::Details.new(raw_data).call

      table = TTY::Table.new header: detail_headers, rows: detail_rows
      renderer = TTY::Table::Renderer::Unicode.new(table, alignments: %i[left left left left left right left left])

      puts renderer.render

      summary_rows, summary_headers = Outputs::Summary.new(raw_data).call

      table = TTY::Table.new header: summary_headers, rows: summary_rows
      renderer = TTY::Table::Renderer::Unicode.new(table, alignments: %i[left left right])

      puts renderer.render

      monthly_rows, monthly_headers = Outputs::Monthly.new(raw_data).call

      table = TTY::Table.new header: monthly_headers, rows: monthly_rows
      renderer = TTY::Table::Renderer::Unicode.new(table, alignments: %i[left left right right])

      puts renderer.render
    end

    private

    attr_reader :options
  end
end
