module ExtractValue
  module Outputs
    RSpec.describe Monthly do
      describe '#call' do
        let(:output) { subject.call }

        subject { described_class.new(rows) }

        let(:rows) do
          [
            { date: DateTime.strptime('2020/01/31', '%Y/%m/%d'), amount: -25.0 },
            { date: DateTime.strptime('2020/01/31', '%Y/%m/%d'), amount: -25.0 },
            { date: DateTime.strptime('2020/03/31', '%Y/%m/%d'), amount: -25.0 },
            { date: DateTime.strptime('2020/05/31', '%Y/%m/%d'), amount: -25.0 },
          ]
        end

        it do
          expect(output).not_to be_nil

          expect(output[0]).to eql([
            [ "2020", "January", "-€25.00", "-€50.00" ],
            [ "2020", "March",   "-€25.00", "-€25.00" ],
            [ "2020", "May",       "€0.00", "-€25.00" ],
          ])

          expect(output[1]).to eql(
            ["Year", "Month", "Average", "Sum"]
          )
        end

      end
    end
  end
end
