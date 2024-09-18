module Resources
  module Project
    module Quotation

      def show_quotation(params = {})
        get("#{project_path}/quotations", params)
      end

    end
  end
end
