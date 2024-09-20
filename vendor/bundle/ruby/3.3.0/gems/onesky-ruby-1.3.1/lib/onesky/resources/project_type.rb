module Resources
  module ProjectType

    def list_project_type
      get('/project-types')
    end

  end
end
