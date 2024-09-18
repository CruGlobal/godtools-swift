module Resources
  module Project

    def list_project(project_group_id)
      get("/project-groups/#{project_group_id}/projects")
    end

    def create_project(project_group_id, params)
      post("/project-groups/#{project_group_id}/projects", params)
    end

    def project(project_id)
      Onesky::Project.new(self, project_id)
    end

  end
end
