module Resources
  module Project
    module Order

      def list_order(params = {})
        get("#{project_path}/orders", params)
      end

      def show_order(order_id)
        get("#{project_path}/orders/#{order_id}")
      end

      def create_order(params)
        post("#{project_path}/orders", params)
      end

    end
  end
end
