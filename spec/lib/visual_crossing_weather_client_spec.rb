require 'rails_helper'

RSpec.describe VisualCrossingWeatherClient do
  subject { described_class.new(api_key: 'fake_key') }

  describe '#initialize' do
    it 'requires an api_key to be passed in' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  describe '#get_weather' do
    it 'requires an address to be passed in' do
      expect { subject.get_weather }.to raise_error(ArgumentError)
    end
  end

  describe '#set_path' do
    it 'encodes the address, start_date and end_date in the URI' do
      subject.send(:set_path, 'New York', '2020-01-01', '2020-01-02')
      expect(subject.instance_variable_get(:@uri).path).to eq('/VisualCrossingWebServices/rest/services/timeline/New%20York/2020-01-01/2020-01-02')
    end
  end
end