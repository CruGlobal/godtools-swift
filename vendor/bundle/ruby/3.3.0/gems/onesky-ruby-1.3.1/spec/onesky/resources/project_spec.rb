require 'spec_helper'

describe 'Project' do

  let(:api_key) {'api_key'}
  let(:api_secret) {'api_secret'}
  let(:client) {Onesky::Client.new(api_key, api_secret)}

  describe 'list_project' do
    let(:project_group_id) {1}

    it 'should list all projects of a project group' do
      stub_request(:get, full_path_with_auth_hash("/project-groups/#{project_group_id}/projects", api_key, api_secret))
        .to_return(body: "{}")
      response = client.list_project(project_group_id)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'create_project' do
    let(:project_group_id) {1}
    let(:params) {{project_type: 'website'}}

    it 'should list all projects of a project group' do
      stub_request(:post, full_path_with_auth_hash("/project-groups/#{project_group_id}/projects", api_key, api_secret))
        .with(body: params.to_json, headers: {'Content_Type' => 'application/json'})
        .to_return(body: "{}")
      response = client.create_project(project_group_id, params)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'project' do
    let(:project_id) {1}

    it 'get project object' do
      expect(client.project(project_id)).to be_an_instance_of(Onesky::Project)
    end
  end

end
