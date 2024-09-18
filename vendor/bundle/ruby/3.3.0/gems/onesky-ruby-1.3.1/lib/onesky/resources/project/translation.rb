module Resources
  module Project
    module Translation

      def export_translation(params)
        get("#{project_path}/translations", params)
      end

      def export_multilingual(params)
        get("#{project_path}/translations/multilingual", params)
      end

      def export_app_description(params)
        get("#{project_path}/translations/app-descriptions", params)
      end

      def get_translation_status(params)
        get("#{project_path}/translations/status", params)
      end

    end
  end
end
