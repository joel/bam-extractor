module BamLookup
  module Views
    RSpec.describe Summary do
      describe '#call' do
        let(:output) { subject.call }

        subject { described_class.new(rows) }

        let(:rows) do
          [
            { amount: -25.0 },
            { amount: -25.0 },
            { amount: -25.0 },
            { amount: -25.0 },
          ]
        end

        it do
          expect(output).not_to be_nil

          expect(output[0]).to eql([
            [ "-€25.00", "-€100.00" ]
          ])

          expect(output[1]).to eql(
            %w[ Average Sum ]
          )
        end

      end
    end
  end
end
