module UnionStationHooks
  module Rails
    module ActionControllerExtension
      def process_action(action, *args)
        options = {
          :controller_name => self.class.name,
          :action_name => action_name,
          :method => request.request_method
        }
        UnionStationHooks.report_controller_action(request.env, options) do
          super
        end
      end

      def render(*args)
        UnionStationHooks.report_view_rendering(request.env) do
          super
        end
      end
    end
  end # module Rails
end # module UnionStationHooks

ActionController::Base.class_eval do
  include UnionStationHooks::Rails::ActionControllerExtension
end
