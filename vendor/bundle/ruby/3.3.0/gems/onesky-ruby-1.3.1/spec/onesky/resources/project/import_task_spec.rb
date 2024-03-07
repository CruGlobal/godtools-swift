require 'spec_helper'

describe 'Project::ImportTask' do

  let(:api_key) {'api_key'}
  let(:api_secret) {'api_secret'}
  let(:client) {Onesky::Client.new(api_key, api_secret)}
  let(:project_id) {1}
  let(:project) {client.project(project_id)}

  describe 'list_import_task' do
    it 'should list import tasks of the project' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/import-tasks", api_key, api_secret))
        .to_return(body: "{}")
      response = project.list_import_task
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'show_import_task' do
    let(:import_task_id) {1}

    it 'should show an import task details' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/import-tasks/#{import_task_id}", api_key, api_secret))
        .to_return(body: "{}")
      response = project.show_import_task(import_task_id)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

end
