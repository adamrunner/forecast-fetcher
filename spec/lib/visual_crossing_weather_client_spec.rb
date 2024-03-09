require 'rails_helper'

RSpec.describe VisualCrossingWeatherClient do
  let(:api_key) { 'fake_key' }
  subject { described_class.new(api_key: api_key) }
  let(:query_params) { URI.encode_www_form({ key: api_key, include: 'current,days'}) }

  describe '#initialize' do
    it 'requires an api_key to be passed in' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'throws an error if a nil api_key is passed in' do
      expect { described_class.new(api_key: nil) }.to raise_error(ArgumentError)
    end
  end

  describe '#get_weather' do
    it 'requires an address to be passed in' do
      expect { subject.get_weather }.to raise_error(ArgumentError)
    end
  end

  describe '#set_path' do
    it 'encodes the address in the URI' do
      subject.send(:set_path, 'New York')
      expect(subject.instance_variable_get(:@uri).path).to eq('/VisualCrossingWebServices/rest/services/timeline/New%20York')
    end

    it 'sets the URI to the VisualCrossing API URL' do
      subject.send(:set_path, 'New York')
      expect(subject.instance_variable_get(:@uri).to_s).to include(VISUAL_CROSSING_API_URL)
    end

    it 'sets the API key and default options in the URI' do
      subject.send(:set_path, 'New York')
      expect(subject.instance_variable_get(:@uri).query).to eq(query_params)
    end
  end
end