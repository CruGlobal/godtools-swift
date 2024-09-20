require 'spec_helper'

describe 'Project::Order' do

  let(:api_key) {'api_key'}
  let(:api_secret) {'api_secret'}
  let(:client) {Onesky::Client.new(api_key, api_secret)}
  let(:project_id) {1}
  let(:project) {client.project(project_id)}

  describe 'list_order' do
    it 'should list orders in project' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/orders", api_key, api_secret))
        .to_return(status: 200, body: "{}")
      response = project.list_order
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'show_order' do
    let(:order_id) {1}

    it 'should show an order details' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/orders/#{order_id}", api_key, api_secret))
        .to_return(status: 200, body: "{}")
      response = project.show_order(order_id)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

  describe 'create_order' do
    let(:files) {['en.yml', 'en2.yml']}
    let(:to_locale) {'ja'}
    let(:params) {{files: files, to_locale: to_locale}}

    it 'should create an order' do
      stub_request(:post, full_path_with_auth_hash("/projects/#{project_id}/orders", api_key, api_secret))
        .with(body: params.to_json, headers: {'Content_Type' => 'application/json'})
        .to_return(status: 200, body: "{}")
      response = project.create_order(params)
      expect(response).to be_an_instance_of(RestClient::Response)
    end
  end

end
