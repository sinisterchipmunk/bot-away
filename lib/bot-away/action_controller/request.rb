class ActionController::Request < Rack::Request
  def parameters_with_deobfuscation
    @parameters ||= BotAway::ParamParser.new(ip, parameters_without_deobfuscation).params
  end

  class << self
    def unfiltered_params(*keys)
      unfiltered_params = instance_variable_get("@unfiltered_params") || instance_variable_set("@unfiltered_params", [])
      unfiltered_params.concat keys.flatten.collect { |k| k.to_s }
      unfiltered_params
    end

    alias_method :accepts_unfiltered_params, :unfiltered_params
  end

  delegate :accepts_unfiltered_params, :unfiltered_params, :to => :"self.class"
  alias_method_chain :parameters, :deobfuscation
  alias_method :params, :parameters
end
