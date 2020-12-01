module BamLookup
  module Lookups
    RSpec.describe Label do
      describe '#call' do
        let(:label) { subject.call }

        subject { described_class.new(row, expressions) }

        describe '#call' do
          let(:row) { [ 'Edison General Electric' ] }

          context 'with multi labels' do
            let(:expressions) { /electric|tesla/i } # OR

            it do
              expect(label).not_to be_nil
              expect(label).to eql('Edison General Electric')
            end
          end

          context 'with found label' do
            let(:expressions) { /edison/i }

            it do
              expect(label).not_to be_nil
              expect(label).to eql('Edison General Electric')
            end
          end

          context 'with not found label' do
            let(:expressions) { /xyz/i }

            it do
              expect(label).to be_nil
            end
          end

        end
      end
    end
  end
end
