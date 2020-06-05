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
Money.rounding_mode = BigDecimal::ROUND_HALF_UP

# ExtractValue::Main.new.extract_value!

module ExtractValue
  class Error < StandardError; end

  class Main
    include ActionView::Helpers::NumberHelper

    def initialize(options)
      @options = options
    end

    def extract_value
      rows = []

      puts('Searching...') if self.options.verbose

      Dir['../**/*.csv'].each do |file|
        CSV.foreach(file) do |row|
          if row.join =~ Regexp.new(self.options.expression, Regexp::IGNORECASE)
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
            puts("FOUND DATE: #{cell}") if self.options.verbose
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
            puts("FOUND AMOUNT: #{cell}") if self.options.verbose
            if amount.fractional == 0 || amount.fractional.abs > self.options.max * 100
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
          next unless cell =~ Regexp.new(self.options.expression, Regexp::IGNORECASE)
          label ||= cell
          if label
            puts("FOUND LABEL: [#{cell}]") if self.options.verbose
            hash[date_formatted][:label] = substitute(cell)
            break
          end
        end
      end

      data = []
      hash.select { |k,v| !k.nil? }.each do |date, info|
        data << [ info[:date], "#{info[:amount]}" ]
      end

      data.sort! do |x,y|
        Chronic.parse(x[0]) <=> Chronic.parse(y[0])
      end

      if self.options.write
        header = [ 'Date', 'Amount' ]
        CSV.open('extract.csv', 'w') do |csv|
          csv << header

          data.each do |entry|
            csv << entry
          end
        end
      end

      data = []
      hash.select { |k,v| !k.nil? }.each do |date, info|
        data << [ "#{info[:label][0..150]}", info[:date], "#{info[:amount_formatted]}" ]
      end

      data.sort! do |x,y|
        Chronic.parse(x[1]) <=> Chronic.parse(y[1])
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

      puts('Done!') if self.options.verbose
    end

    private

    def substitute(content)
      return self.options.label if self.options.label
      REXPRESSIONS.each do |i|
        return i[:r] if content =~ Regexp.new(i[:exp], Regexp::IGNORECASE)
      end
      content
    end

    # Regexp.escape("Pago ADY\*NETFLIX 1016GD AMSTERNL(.*)")
    REXPRESSIONS = [
      {
        exp: "NETFLIX",
        r: "Pago NETFLIX"
      }
    ].freeze

    attr_reader :options
  end
end
