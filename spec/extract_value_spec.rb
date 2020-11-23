module ExtractValue
  RSpec.describe Main do
    describe '#expressions' do
      let(:options) { OpenStruct.new(expression: expression) }

      subject do
        ExtractValue.configure do |conf|
          conf.verbose = true
        end
        described_class.new(options)
      end

      context 'OR' do
        let(:expression) { 'prime,amazon' }

        it do
          expect(subject.expressions).to eql(/prime|amazon/i)
        end
      end

      context 'AND' do
        let(:expression) { 'amazon+prime' }

        it do
          expect(subject.expressions).to eql(/.*(amazon).*(prime).*/i)
        end
      end

    end

    describe '#extract_value' do
      let(:rows) do
        [
          [
            '05/05/2020',
            'Otros gastos',
            'Transferencias',
            'Transferencia emitida a CONTAINER STORAGE MALLORCA SL EMAYA Primer Recibo',
            nil,
            '€379.60',
            nil,
            '-€48.86',
            nil,
            nil,
            nil,
            'ING Direct/Isa - Joel - Joint Bank Account/2020 Isa - Joel - Joint Bank Account',
            '2020-05-May-ING-Direct-Common-2020-05-31_35-CONVERTED.csv'
          ],
          ['2019-09-29', 'Amazon Prime*MO0ZI7FF4', '', 'MasterCard Payment', '', 'Media & Electronics', '-36.0', '-36.0', 'EUR', '1.0', 'N26/2019', '2019-10 October N26 - n26-csv-transactions.csv'],
          ['2020-08-30', 'Amazon Prime*PQ0B55NZ5', '', 'MasterCard Payment', '', 'Media & Electronics', '-36.0', '-36.0', 'EUR', '1.0', 'N26/2020', '2020-08 August N26 - n26-csv-transactions.csv'],
          ['02/09/2019', 'PAIEMENT CB', 'FACTURE CARTE', 'FACTURE CARTE DU 300819 AMAZON PRIME*MA CARTE 4974XXXXXXXX1716 LUX 36,00EUR', '-36.00', nil, 'HelloBank', '2019-2020 Hellobank.csv']
        ]
      end

      let(:data) do
        [
          {
            date: DateTime.strptime('05/05/2020', '%m/%d/%Y'),
            amount: -48.86,
            amount_formatted: '-€48.86',
            source_dir: 'ING Direct/Isa - Joel - Joint Bank Account/2020 Isa - Joel - Joint Bank Account',
            source_file: '2020-05-May-ING-Direct-Common-2020-05-31_35-CONVERTED.csv',
            label: 'Transferencia emitida a CONTAINER STORAGE MALLORCA SL EMAYA Primer Recibo'
          },
          { date: DateTime.strptime('2019-09-29', '%Y-%m-%d'), amount: -36.0, amount_formatted: '-€36.00', source_dir: 'N26/2019', source_file: '2019-10 October N26 - n26-csv-transactions.csv', label: 'Amazon Prime*MO0ZI7FF4' },
          { date: DateTime.strptime('2020-08-30', '%Y-%m-%d'), amount: -36.0, amount_formatted: '-€36.00', source_dir: 'N26/2020', source_file: '2020-08 August N26 - n26-csv-transactions.csv', label: 'Amazon Prime*PQ0B55NZ5' },
          { date: DateTime.strptime('02/09/2019', '%d/%m/%Y'), amount: -36.0, amount_formatted: '-€36.00', source_dir: 'HelloBank', source_file: '2019-2020 Hellobank.csv', label: 'FACTURE CARTE DU 300819 AMAZON PRIME*MA CARTE 4974XXXXXXXX1716 LUX 36,00EUR' }
        ]
      end

      subject do
        ExtractValue.configure do |conf|
          conf.options = OpenStruct.new(min: -50, max: 0)
          conf.verbose = false
        end
        described_class.new(options)
      end

      context 'Example 1' do
        let(:expression) { 'prime' }
        let(:options) { OpenStruct.new(expression: expression, source_file: true) }

        it do
          expect(subject).to receive(:get_rows) { rows }
          info = subject.get_rows
          expect(subject.get_data(info)).to eql(data)
        end
      end
    end
  end
end
