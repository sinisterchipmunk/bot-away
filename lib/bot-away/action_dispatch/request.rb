# Note to self and anyone else reading this: we're overriding ActionDispatch::ParamsParser
# instead of just attaching a custom param parser so that others' custom param parsers can do
# their jobs without conflict. Also, overriding the parser allows us to deobfuscate all params,
# not just the ones I'm smart enough to predict will be used.
require 'action_dispatch/middleware/params_parser'

class ActionDispatch::ParamsParser
  def parse_formatted_parameters_with_deobfuscation(env)
    BotAway::ParamParser.new(ip, parse_formatted_parameters_without_deobfuscation(env).dup).params
  end

  alias_method_chain :parse_formatted_parameters, :deobfuscation
end
