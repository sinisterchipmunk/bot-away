module BotAway::TestCase::ControllerTestCase
  # note that this only matters for TEST requests; real ones use the params parser.
  module ::ActionController::TestCase::Behavior
    def process_with_deobfuscation(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
      parameters = BotAway::ParamParser.new(request.ip, (parameters || {}).with_indifferent_access).params
      process_without_deobfuscation(action, parameters, session, flash, http_method)
    end

    alias_method_chain :process, :deobfuscation
  end
end
