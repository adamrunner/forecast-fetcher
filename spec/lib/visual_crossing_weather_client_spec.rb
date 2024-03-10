require 'rails_helper'

RSpec.describe VisualCrossingWeatherClient do
  let(:api_key) { 'fake_key' }
  subject { described_class.new(api_key: api_key) }

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

    it "merges the response data with a flag indicating if the response was cached" do
      allow(subject).to receive(:send_request).and_return({})
      allow(Rails.cache).to receive(:exist?).and_return(true)
      expect(subject.get_weather(address: 'New York', cache: true)).to eq({ cached: true })
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
      let(:query_params) { URI.encode_www_form({ key: api_key, include: 'current,days'}) }
      subject.send(:set_path, 'New York')
      expect(subject.instance_variable_get(:@uri).query).to eq(query_params)
    end
  end

  describe '#handle_response' do
    let(:valid_response_body) { {"currentConditions": { "temp":49.0, "feelslike":49.0,"humidity":63.7 }, "days": []}.with_indifferent_access }

    it 'raises an error if the response is a client error' do
      response = Net::HTTPBadRequest.new('1.1', '400', 'Bad Request')
      expect { subject.send(:handle_response, response) }.to raise_error(ArgumentError)
    end

    it 'raises an error if the response is a server error' do
      response = Net::HTTPBadGateway.new('1.1', '502', 'Bad Gateway')
      expect { subject.send(:handle_response, response) }.to raise_error(StandardError)
    end

    it 'returns the parsed JSON response if the response is successful' do
      response = Net::HTTPOK.new('1.1', '200', 'OK')
      expect(response).to receive(:body).and_return(valid_response_body.to_json)
      expect(subject.send(:handle_response, response)).to eq(valid_response_body)
    end
  end

  describe '#strip_address' do
    it 'returns the zip code if it is present at the end of the address' do
      expect(subject.send(:strip_address, 'New York, NY 10001')).to eq('10001')
    end

    it 'returns the address if a zip code is not present' do
      expect(subject.send(:strip_address, 'New York')).to eq('New York')
    end
  end
end