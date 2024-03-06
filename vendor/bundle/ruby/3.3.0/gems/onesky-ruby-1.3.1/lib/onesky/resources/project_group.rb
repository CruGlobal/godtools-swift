module Resources
  module ProjectGroup

    def list_project_group
      get('/project-groups')
    end

    def show_project_group(project_group_id)
      get("/project-groups/#{project_group_id}")
    end

    def create_project_group(params)
      post('/project-groups', params)
    end

    def delete_project_group(project_group_id)
      delete("/project-groups/#{project_group_id}")
    end

    def list_project_group_languages(project_group_id)
      get("/project-groups/#{project_group_id}/languages")
    end

  end
end
