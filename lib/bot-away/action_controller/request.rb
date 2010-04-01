class ActionController::Request < Rack::Request
  def parameters_with_deobfuscation
    @parameters ||= BotAway::ParamParser.new(ip, parameters_without_deobfuscation).params
  end

  alias_method_chain :parameters, :deobfuscation
  alias_method :params, :parameters
end
