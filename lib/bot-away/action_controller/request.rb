if defined?(Rails::VERSION) && Rails::VERSION::STRING >= "3.0"
  # Rails 3.0
  module ActionDispatch
    class ParamsParser
      def call_with_deobfuscation(env)
        if params = parse_formatted_parameters(env)
          env["action_dispatch.request.request_parameters"] = BotAway::ParamParser.new(ip, params).params
        end
  
        @app.call(env)
      end
  
      alias_method_chain :call, :deobfuscation
    end
  end
else
  if defined?(ActionController::ParamsParser)
    # Rails 2.3.x (as early as 2.3.5, not tested with earlier than that)
    module ActionController
      class ParamsParser
        def call_with_deobfuscation(env)
          if params = parse_formatted_parameters(env)
            env["action_controller.request.request_parameters"] = BotAway::ParamParser.new(ip, params).params
          end
  
          @app.call(env)
        end
  
        alias_method_chain :call, :deobfuscation
      end
    end
  else
    # Rails 2.x, not sure which version. At some point this stopped working.
    class ActionController::Request < Rack::Request
      def parameters_with_deobfuscation
        @deobfuscated_parameters ||= begin
          BotAway::ParamParser.new(ip, parameters_without_deobfuscation.dup).params
        end 
      end
  
      alias_method_chain :parameters, :deobfuscation
      alias_method :params, :parameters
    end
  end
end
