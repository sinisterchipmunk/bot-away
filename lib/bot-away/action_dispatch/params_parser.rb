require 'action_dispatch/middleware/params_parser'

# We're overriding ActionDispatch::ParamsParser
# instead of just attaching a custom param parser so that others' custom param parsers can do
# their jobs without conflict. Also, overriding the parser allows us to deobfuscate all params,
# not just the ones I'm smart enough to predict will be used.
class ActionDispatch::ParamsParser
  def parse_formatted_parameters_with_deobfuscation(env)
    request = ActionDispatch::Request.new(env)
    params = parse_formatted_parameters_without_deobfuscation(env)
    if params
      BotAway::ParamParser.new(request.ip, params).params
    else
      request_parameters = request.parameters.dup
      request.parameters.clear
      request.parameters.merge! BotAway::ParamParser.new(request.ip, request_parameters).params
      params
    end
  end

  alias_method_chain :parse_formatted_parameters, :deobfuscation
end
