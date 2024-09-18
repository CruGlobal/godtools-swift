require 'spec_helper'

describe 'Locale' do

  let(:api_key) {'api_key'}
  let(:api_secret) {'api_secret'}
  let(:client) {Onesky::Client.new(api_key, api_secret)}

  describe 'list_locale' do
    it 'should list all available locales' do
      stub_request(:get, full_path_with_auth_hash('/locales', api_key, api_secret))
        .to_return(body: "{}")
      response = client.list_locale
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

end
