module BotAway
  class Middleware
    def initialize app
      @app = app
    end
    
    def call env
      request = ActionDispatch::Request.new env

      if request.post? || request.put? || request.patch?
        post = single_level_params_hash request
        BotAway::ParamParser.new post
        request.env['rack.input'] = encode_params_hash post
      end
      
      @app.call env
    end

    # Returns a StringIO with form-encoded data built from the `post`
    # argument.
    #
    # Example:
    #
    #     io = encode_params_hash({ "a" => "1", "b" => "2" })
    #     #=> StringIO<"a=1&b=2">
    #
    def encode_params_hash post
      StringIO.new post.collect { |k,v| "#{k}=#{v}" }.join("&")
    end

    # Returns a hash of params, where the name is the form element's complete
    # name and the value is the submitted value. For example, instead of the
    # Rails-style `{ "account" => { "name" => "..." } }` hash, this method
    # returns simply `{ "account[name]" => "..." }`.
    #
    # The return value of this method is guaranteed not to include nested
    # hashes.
    def single_level_params_hash request
      data = request.env['rack.input'].read
      data.split(/&/).inject({}) do |params, key_value|
        key, value = *key_value.split('=')
        params[key] = value
        params
      end
    end
  end
end
