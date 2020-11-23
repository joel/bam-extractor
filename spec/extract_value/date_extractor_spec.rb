module ExtractValue
  RSpec.describe DateExtractor do
    describe '#call' do
      let(:date) { subject.call }

      subject { described_class.new(row) }

      context 'With a Date Given' do
        [
          {
            bank_name: 'N26',
            raw_date: '2020-01-31'
          },{
            bank_name: 'ING Direct',
            raw_date: '01/31/2020'
          },{
            bank_name: 'HelloBank',
            raw_date: '31/01/2020'
          }
        ].each do |info|
          let(:row) { [ info[:bank_name], info[:raw_date] ] }

          context "Bank [#{info[:bank_name]}]" do
            it do
              expect(date).to be_a(DateTime)
              expect(date.strftime('%Y/%m/%d')).to eql('2020/01/31')
            end
          end
        end
      end

      [ 'N26', 'ING Direct', 'HelloBank' ].each do |bank_name|
        context 'With Bad Date' do
          let(:row) { [ bank_name, 'This is not a Valid Date' ] }

          context "Bank [#{bank_name}]" do
            it do
              expect(date).to be_nil
            end
          end
        end
      end

      context 'With Unknown Bank' do
        let(:raw_date)  { '2020-01-31' }
        let(:bank_name) { 'Bank Name Unknown' }

        let(:row) { [ bank_name, raw_date ] }

        context "Date [2020-01-31]" do
          it do
            expect { date }.to raise_error
          end
        end
      end

    end
  end
end
