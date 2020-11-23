module ExtractValue
  module Outputs
    RSpec.describe Details do
      describe '#call' do
        let(:output) { subject.call }

        subject { described_class.new(rows) }

        let(:row) do
          {
            date: DateTime.strptime('2020/01/31', '%Y/%m/%d'),
            amount: -36.0,
            amount_formatted: "-€36.00",
            source_dir: "N26/2019",
            source_file: "2019-10 October N26 - n26-csv-transactions.csv",
            label: "Amazon Prime*MO0ZI7FF4"
          }
        end

        let(:rows) { [ row ] }

        it do
          expect(output).not_to be_nil

          expect(output[0]).to eql([
            [
              "Amazon Prime*MO0ZI7FF4",
              "2020/01/31",
              "2020",
              "January",
              "Friday",
              "-€36.00",
              "N26/2019",
              "2019-10 October N26 - n26-csv-transactions.csv"
            ]
          ])

          expect(output[1]).to eql(
            [ 'Label', 'Date', 'Year', 'Month', 'Day', 'Amount', 'Source Dir', 'Source File' ]
          )
        end

      end
    end
  end
end
