require 'spec_helper'

describe 'Project::Translation' do

  let(:api_key) {'api_key'}
  let(:api_secret) {'api_secret'}
  let(:client) {Onesky::Client.new(api_key, api_secret)}
  let(:project_id) {1}
  let(:project) {client.project(project_id)}

  describe 'export_translation' do
    let(:params) {{source_file_name: 'en.yml', locale: 'ja'}}
    let(:params_as_query_string) {'&source_file_name=en.yml&locale=ja'}

    it 'should export translation' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/translations", api_key, api_secret) + params_as_query_string)
        .to_return(status: 200, body: 'file content')
      response = project.export_translation(params)
      expect(response.code).to eq(200)
    end
  end

  describe 'export_multilingual' do
    let(:params) {{source_file_name: 'en.yml'}}
    let(:params_as_query_string) {'&source_file_name=en.yml'}

    it 'should export multilingual' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/translations/multilingual", api_key, api_secret) + params_as_query_string)
        .to_return(status: 200, body: 'file content')
      response = project.export_multilingual(params)
      expect(response.code).to eq(200)
    end
  end

  describe 'export_app_description' do
    let(:params) {{locale: 'ja'}}
    let(:params_as_query_string) {'&locale=ja'}

    it 'should export app description' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/translations/app-descriptions", api_key, api_secret) + params_as_query_string)
        .to_return(status: 200, body: 'file content')
      response = project.export_app_description(params)
      expect(response.code).to eq(200)
    end
  end

  describe 'get_translation_status' do
    let(:params) {{file_name: 'en.yml', locale: 'ja'}}
    let(:params_as_query_string) {'&file_name=en.yml&locale=ja'}

    it 'should show translation status' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/translations/status", api_key, api_secret) + params_as_query_string)
        .to_return(body: "{}")
      response = project.get_translation_status(params)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

end
