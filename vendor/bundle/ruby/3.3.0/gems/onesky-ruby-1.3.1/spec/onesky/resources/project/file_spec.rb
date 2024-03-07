require 'spec_helper'

describe 'Project::File' do

  let(:api_key) {'api_key'}
  let(:api_secret) {'api_secret'}
  let(:client) {Onesky::Client.new(api_key, api_secret)}
  let(:project_id) {1}
  let(:project) {client.project(project_id)}

  describe 'list_file' do
    it 'should list files in project' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/files", api_key, api_secret))
        .to_return(body: "{}")
      response = project.list_file
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'upload_file' do
    let(:params) {{file: 'spec/fixture/en.yml', file_format: 'RUBY_YAML'}}

    it 'should upload file to project' do
      stub_request(:post, full_path_with_auth_hash("/projects/#{project_id}/files", api_key, api_secret))
        .to_return(body: "{}")
      response = project.upload_file(params)
      expect(response).to be_an_instance_of(RestClient::Response)
    end

    it 'should raise error when file does not exist' do
      expect {project.upload_file(file: 'spec/fixture/no_file.yml')}.to raise_error(IOError, 'File does not exist')
    end
  end

  describe 'delete_file' do
    let(:params) {{file_name: 'en.yml'}}
    let(:params_as_query_string) {'&file_name=en.yml'}

    it 'should delete file from project' do
      stub_request(:delete, full_path_with_auth_hash("/projects/#{project_id}/files", api_key, api_secret) + params_as_query_string)
        .to_return(body: "{}")
      response = project.delete_file(params)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

end
