require "extract_value/version"
require 'csv'
require 'chronic'
require 'monetize'
require 'action_view'

Monetize.assume_from_symbol = true
Money.default_currency = 'EUR'
# Money.rounding_mode = 'ROUND_HALF_EVEN'

# ExtractValue::Main.new.extract_value!

module ExtractValue
  class Error < StandardError; end

  class Main
    include ActionView::Helpers::NumberHelper

    def extract_value!
      rows = []

      Dir['../**/*.csv'].each do |file|
        CSV.foreach(file) do |row|
          if row.join =~ /endesa/i
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
            puts("FOUND DATE: #{cell}")
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
            puts("FOUND AMOUNT: #{cell}")
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
      end

      headers = [ 'Date', 'Amount' ]
      CSV.open('extract.csv', 'w') do |csv|
        csv << headers

        hash.select { |k,v| !k.nil? }.each do |date, info|
          csv << [ info[:date], "#{info[:amount]}" ]
        end
      end

    end
  end
end
