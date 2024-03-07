require 'spec_helper'

describe 'Project Type' do

  let(:api_key) {'api_key'}
  let(:api_secret) {'api_secret'}
  let(:client) {Onesky::Client.new(api_key, api_secret)}

  describe 'list_project_type' do
    it 'should list all available project type' do
      stub_request(:get, full_path_with_auth_hash('/project-types', api_key, api_secret))
        .to_return(body: "{}")
      response = client.list_project_type
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

end
