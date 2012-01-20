module BotAway
  class Middleware
    def initialize(app)
      @app = app
    end
    
    def call(env)
      request = ActionDispatch::Request.new(env)

      # ignore GET params
      unless (post = request.POST).empty?
        post.merge! BotAway::ParamParser.new(request.ip, post).params
      end
      
      @app.call env
    end
  end
end
