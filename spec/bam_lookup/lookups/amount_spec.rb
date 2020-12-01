module BamLookup
  module Lookups
    RSpec.describe Amount do
      describe '#call' do
        let(:amount) { subject.call }

        subject do
          BamLookup.configure do |conf|
            conf.options = OpenStruct.new(min: min, max: max)
            # conf.verbose = true
          end
          described_class.new(row)
        end

        describe '#call' do
          let(:raw_amount)  { '-3,745.89' }

          let(:row) { [ raw_amount ] }

          context 'in the range' do
            let(:min) { -4000 }
            let(:max) { -3000 }

            it do
              expect(amount).not_to be_nil
              expect(Monetize.parse(amount).fractional).to eql(-374589)
            end
          end

          context 'out the range min' do
            let(:min) { -3000 }
            let(:max) { 0 }
            it do
              expect(amount).to be_nil
            end
          end

          context 'out the range max' do
            let(:min) { -4000 }
            let(:max) { -3800 }

            it do
              expect(amount).to be_nil
            end
          end
        end

      end
    end
  end
end
