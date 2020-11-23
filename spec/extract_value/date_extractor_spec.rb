module ExtractValue
  RSpec.describe DateExtractor do
    describe '#call' do
      let(:row)  { [ bank_name, raw_date ] }
      let(:date) { subject.call }

      subject { DateExtractor.new(row) }

      context 'Example 1' do
        let(:raw_date)  { '2020-01-31' }
        let(:bank_name) { 'n26' }

        it do
          expect(date).to be_a(DateTime)
          expect(date.strftime('%Y/%m/%d')).to eql('2020/01/31')
        end
      end
    end
  end
end
