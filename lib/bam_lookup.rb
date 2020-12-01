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

module BamLookup
  extend Configure

  class Error < StandardError; end

  class Main
    include ActionView::Helpers::NumberHelper

    def initialize(options)
      @options = options
    end

    def bam_lookup
      raw_data = get_data(get_rows)

      if raw_data.empty?
        puts('No Data')
        return
      end

      detail_rows, detail_headers = Views::Details.new(raw_data).call

      table = TTY::Table.new header: detail_headers, rows: detail_rows
      renderer = TTY::Table::Renderer::Unicode.new(table, alignments: %i[left left left left left right left left])

      puts renderer.render

      summary_rows, summary_headers = Views::Summary.new(raw_data).call

      table = TTY::Table.new header: summary_headers, rows: summary_rows
      renderer = TTY::Table::Renderer::Unicode.new(table, alignments: %i[left left right])

      puts renderer.render

      monthly_rows, monthly_headers = Views::Monthly.new(raw_data).call

      table = TTY::Table.new header: monthly_headers, rows: monthly_rows
      renderer = TTY::Table::Renderer::Unicode.new(table, alignments: %i[left left right right])

      puts renderer.render
    end

    def expressions
      if options.expression =~ /,/
        Regexp.new(options.expression.split(',').join('|'), Regexp::IGNORECASE)
      elsif options.expression =~ /\+/
        exp = options.expression.split('+').map do |word|
          ".*(#{word})"
        end.join
        exp << '.*'
        Regexp.new(exp, Regexp::IGNORECASE)
      else
        Regexp.new(options.expression, Regexp::IGNORECASE)
      end
    end

    private

    attr_reader :options

    def get_rows
      rows = []

      puts('Searching...') if options.verbose

      csv_files_directory = options.source_directory || BamLookup.configuration.file_directory

      Dir["#{csv_files_directory}/**/*.csv"].each do |file|
        CSV.foreach(file) do |row|
          if row.join =~ expressions
            directories = File.dirname(file).split('/')
            rows << row + [
              "#{directories[-2]}/#{directories[-1]}", File.basename(file)
            ]
          end
        end
      end

      rows
    end

    def get_data(rows)
      data = []

      rows.each do |row|
        label = Lookups::Label.new(row, expressions).call
        next unless label

        date = Lookups::Date.new(row).call
        next unless date

        amount = Lookups::Amount.new(row).call
        next unless amount

        info = { date: nil, amount: nil, amount_formatted: nil, source_dir: nil, source_file: nil }

        info[:date] = date

        info[:amount] = amount
        info[:amount_formatted] = number_to_currency(info[:amount], unit: '€', separator: '.', delimiter: ',')

        info[:label] = options.label || label[0..options.trunk]

        info[:source_dir]  = row[-2]
        info[:source_file] = row[-1] if options.source_file

        data << info
      end

      data
    end
  end
end
