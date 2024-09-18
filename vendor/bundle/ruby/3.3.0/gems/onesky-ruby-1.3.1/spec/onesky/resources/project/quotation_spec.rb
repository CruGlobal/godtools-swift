require 'spec_helper'

describe 'Project::Quotation' do

  let(:api_key) {'api_key'}
  let(:api_secret) {'api_secret'}
  let(:client) {Onesky::Client.new(api_key, api_secret)}
  let(:project_id) {1}
  let(:project) {client.project(project_id)}

  describe 'show_quotation' do
    let(:params) {{files: ['en.yml', 'en2.yml'], to_locale: 'ja'}}
    let(:params_as_query_string) {'&files[]=en.yml&files[]=en2.yml&to_locale=ja'}

    it 'should show quotation details' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/quotations", api_key, api_secret) + params_as_query_string)
        .to_return(status: 200)
      response = project.show_quotation(params)
      expect(response.code).to eq(200)
    end
  end

end
