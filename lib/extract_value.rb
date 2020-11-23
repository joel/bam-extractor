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
        label = LabelExtractor.new(row, expressions).call
        next unless label

        date = DateExtractor.new(row).call
        next unless date

        amount = AmountExtractor.new(row).call
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

      raw_data.sort! do |x, y|
        x[:date] <=> y[:date]
      end

      if options.write
        header = %w[Date Amount Source]
        CSV.open('extract.csv', 'w') do |csv|
          csv << header

          raw_data.each do |entry|
            csv << [entry[:date], entry[:amount], entry[:source_file]]
          end
        end
      end

      data = []
      raw_data.each do |info|
        data << [
          (info[:label]).to_s,
          info[:date].strftime('%Y/%m/%d'),
          info[:date].strftime('%Y'),
          info[:date].strftime('%B'),
          info[:date].strftime('%A'),
          (info[:amount_formatted]).to_s,
          info[:source_dir],
          info[:source_file]
        ]
      end

      data.sort! do |x, y|
        x[1] <=> y[1]
      end

      table = TTY::Table.new header: ['Label', 'Date', 'Year', 'Month', 'Day', 'Amount', 'Source Dir', 'Source File'], rows: data
      renderer = TTY::Table::Renderer::Unicode.new(table, alignments: %i[left left left left left right left left])

      puts renderer.render

      begin
        sum = raw_data.map do |info|
          info[:amount]
        end.reduce(:+)
        average = sum / raw_data.size

        table = TTY::Table.new header: %w[Average Sum], rows: [[
          number_to_currency(average.round(2), unit: '€', separator: '.', delimiter: ','),
          number_to_currency(sum.round(2), unit: '€', separator: '.', delimiter: ',')
        ]]
        renderer = TTY::Table::Renderer::Unicode.new(table, alignments: %i[left left right])

        puts renderer.render

        sum_per_month = Hash.new { |hash, key| hash[key] = { sum: 0, average: 0, year: nil, month: nil } }
        current_date = nil

        sum = raw_data.each do |info|
          current_date ||= info[:date].strftime('%Y-%B')
          if current_date != info[:date].strftime('%Y-%B')
            sum_per_month[current_date][:average] = sum_per_month[current_date][:sum] / sum_per_month[current_date].size
            current_date = info[:date].strftime('%Y-%B')
          end
          sum_per_month[current_date][:sum] += info[:amount]
          sum_per_month[current_date][:year]  = info[:date].strftime('%Y')
          sum_per_month[current_date][:month] = info[:date].strftime('%B')
        end

        d = sum_per_month.values.map do |v|
          [
            v[:year],
            v[:month],
            number_to_currency(v[:average].round(2), unit: '€', separator: '.', delimiter: ','),
            number_to_currency(v[:sum].round(2), unit: '€', separator: '.', delimiter: ',')
          ]
        end

        table = TTY::Table.new header: %w[Year Month Average Sum], rows: d
        renderer = TTY::Table::Renderer::Unicode.new(table, alignments: %i[left left right right])

        puts renderer.render
      rescue StandardError => e
        puts("ERROR: [#{e.message}]")
      end

      puts('Done!') if options.verbose
    end

    private

    attr_reader :options
  end
end
