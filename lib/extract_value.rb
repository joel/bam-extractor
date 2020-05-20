require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

require 'csv'
require 'chronic'
require 'monetize'
require 'action_view'
require 'tty-table'

Monetize.assume_from_symbol = true
Money.default_currency = 'EUR'
# Money.rounding_mode = 'ROUND_HALF_EVEN'

# ExtractValue::Main.new.extract_value!

module ExtractValue
  class Error < StandardError; end

  class Main
    include ActionView::Helpers::NumberHelper

    def initialize(expression:, verbose: false)
      @expression = expression
      @verbose = verbose
    end

    def extract_value
      rows = []

      puts('Searching...') if self.verbose

      Dir['../**/*.csv'].each do |file|
        CSV.foreach(file) do |row|
          if row.join =~ Regexp.new(self.expression, Regexp::IGNORECASE)
            rows << row
          end
        end
      end

      hash = Hash.new { |hash, key| hash[key] = { date: nil, amount: nil, amount_formatted: nil } }

      rows.each do |row|
        date = nil
        date_formatted = nil

        row.each do |cell|
          next if hash[date_formatted][:date]
          date ||= Chronic.parse(cell)
          if date
            puts("FOUND DATE: #{cell}") if self.verbose
            date_formatted = date.strftime('%d-%m-%Y')
            hash[date_formatted][:date] = date_formatted
            break
          end
        end

        amount = nil
        row.each do |cell|
          next if hash[date_formatted][:amount]
          amount ||= Monetize.parse(cell)
          if amount
            puts("FOUND AMOUNT: #{cell}") if self.verbose
            if amount.fractional == 0 || amount.fractional > 30_000
              amount = nil
              next
            else
              hash[date_formatted][:amount] = amount.fractional.to_f / 100
              hash[date_formatted][:amount_formatted] = number_to_currency(hash[date_formatted][:amount], unit: '€', separator: '.', delimiter: ',')
              break
            end
          end
        end

        label = nil
        row.each do |cell|
          next unless cell =~ Regexp.new(self.expression, Regexp::IGNORECASE)
          label ||= cell
          if label
            hash[date_formatted][:label] = cell
            break
          end
        end
      end

      data = []
      hash.select { |k,v| !k.nil? }.each do |date, info|
        data << [ info[:date], "#{info[:amount]}" ]
      end

      header = [ 'Date', 'Amount' ]
      CSV.open('extract.csv', 'w') do |csv|
        csv << header

        data.each do |entry|
          csv << entry
        end
      end

      data = []
      hash.select { |k,v| !k.nil? }.each do |date, info|
        data << [ "#{info[:label][0..150]}", info[:date], "#{info[:amount_formatted]}" ]
      end

      table = TTY::Table.new header: [ 'Label', 'Date', 'Amount' ], rows: data
      renderer = TTY::Table::Renderer::Unicode.new(table, alignments: [:left, :left, :right])

      puts renderer.render

      begin
        sum = hash.select { |k,v| !k.nil? }.map do |date, info|
          info[:amount].abs
        end.reduce(:+)
        average = sum / data.size

        table = TTY::Table.new header: [ 'Average' ], rows: [[average.round(2)]]
        renderer = TTY::Table::Renderer::Unicode.new(table, alignments: [:left, :left, :right])

        puts renderer.render
      rescue
      end

      puts('Done!') if self.verbose
    end

    private

    attr_reader :expression, :verbose

  end
end
