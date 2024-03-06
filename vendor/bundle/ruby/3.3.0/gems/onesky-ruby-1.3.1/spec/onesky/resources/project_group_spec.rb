require 'spec_helper'

describe 'Project Group' do

  let(:api_key) {'api_key'}
  let(:api_secret) {'api_secret'}
  let(:client) {Onesky::Client.new(api_key, api_secret)}

  describe 'list_project_group' do
    it 'should list all available project group' do
      stub_request(:get, full_path_with_auth_hash('/project-groups', api_key, api_secret))
        .to_return(body: "{}")
      response = client.list_project_group
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'show_project_group' do
    let(:project_group_id) {1}

    it 'should show a project group information' do
      stub_request(:get, full_path_with_auth_hash("/project-groups/#{project_group_id}", api_key, api_secret))
        .to_return(body: "{}")
      response = client.show_project_group(project_group_id)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'create_project_group' do
    let(:params) {{name: 'New Project Group'}}

    it 'should create a project group' do
      stub_request(:post, full_path_with_auth_hash('/project-groups', api_key, api_secret))
        .with(body: params.to_json, headers: {'Content_Type' => 'application/json'})
        .to_return(body: "{}")
      response = client.create_project_group(params)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'delete_project_group' do
    let(:project_group_id) {1}

    it 'should delete a project group' do
      stub_request(:delete, full_path_with_auth_hash("/project-groups/#{project_group_id}", api_key, api_secret))
        .to_return(body: "{}")
      response = client.delete_project_group(project_group_id)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'list_project_group_languages' do
    let(:project_group_id) {1}

    it 'should list languages activated of a project group' do
      stub_request(:get, full_path_with_auth_hash("/project-groups/#{project_group_id}/languages", api_key, api_secret))
        .to_return(body: "{}")
      response = client.list_project_group_languages(project_group_id)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

end
