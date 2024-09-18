module Resources
  module Project
    module ImportTask

      def list_import_task(params = {})
        get("#{project_path}/import-tasks", params)
      end

      def show_import_task(import_task_id)
        get("#{project_path}/import-tasks/#{import_task_id}")
      end

    end
  end
end
